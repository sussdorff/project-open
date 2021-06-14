-- upgrade-3.4.1.0.0-3.4.1.0.1.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-3.4.1.0.0-3.4.1.0.1.sql','');



delete from im_view_columns where column_id = 91101;

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91101, 911, NULL, '"Task Name"',
'"<nobr>$indent_short_html$gif_html<a href=$object_url>$task_name</a></nobr>"','','',1,'');


delete from im_view_columns where column_id = 91002;

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91002,910,NULL,'"Task Name"',
'"<nobr>$indent_html$gif_html<a href=$object_url>$task_name</a></nobr>"','','',2,'');





-----------------------------------------------------------
-- Dynfield Widgets
--
SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'project_status', 'Project Status', 'Projop Status',
	10007, 'integer', 'im_category_tree', 'integer',
	'{custom {category_type "Intranet Project Status"}}'
);

SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'project_type', 'Project Type', 'Projop Type',
	10007, 'integer', 'im_category_tree', 'integer',
	'{custom {category_type "Intranet Project Type"}}'
);

SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'units_of_measure', 'Units of Measure', 'Units of Measure',
	10007, 'integer', 'im_category_tree', 'integer',
	'{custom {category_type "Intranet UoM"}}'
);

SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'materials', 'Materials', 'Materials',
	10007, 'integer', 'generic_sql', 'integer',
	'{custom {sql {
		select	m.material_id,
			m.material_name
		from	im_materials m
		where	m.material_status_id not in (select * from im_sub_categories(9102))
		order by 
			lower(material_name) 
	}}}'
);


CREATE or REPLACE FUNCTION im_project_level_spaces(integer)
RETURNS varchar as $body$
DECLARE
	p_level		alias for $1;
	v_result	varchar;
	i		integer;
BEGIN
	v_result := '';
	FOR i IN 1..p_level LOOP
		v_result := v_result || '    ';
	END LOOP;
	RETURN v_result;
END; $body$ LANGUAGE 'plpgsql';


SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'open_projects', 'Open Projects', 'Open Projects',
	10007, 'integer', 'generic_sql', 'integer',
	'{custom {sql {
		select	p.project_id,
			im_project_level_spaces(tree_level(p.tree_sortkey)) || p.project_name
		from	im_projects p
		where	p.project_status_id in (select * from im_sub_categories(76)) and
			p.project_type_id not in (select * from im_sub_categories(100)) and
			p.project_type_id not in (select * from im_sub_categories(101)) and
			p.project_type_id not in (select * from im_sub_categories(2510)) and
			p.project_type_id not in (select * from im_sub_categories(2502))
		order by 
			tree_sortkey
	}}}'
);



-----------------------------------------------------------
-- Hard coded fields
--



-- Shortcut function
CREATE OR REPLACE FUNCTION im_dynfield_attribute_new (
	varchar, varchar, varchar, varchar, varchar, char(1), integer, char(1), varchar
) RETURNS integer as '
DECLARE
	p_object_type		alias for $1;
	p_column_name		alias for $2;
	p_pretty_name		alias for $3;
	p_widget_name		alias for $4;
	p_datatype		alias for $5;
	p_required_p		alias for $6;
	p_pos_y			alias for $7;
	p_also_hard_coded_p	alias for $8;
	p_table_name	 	alias for $9;

	v_dynfield_id		integer;
	v_widget_id		integer;
	v_type_category		varchar;
	row			RECORD;
	v_count			integer;
	v_min_n_value		integer;
BEGIN
	select	widget_id into v_widget_id from im_dynfield_widgets
	where	widget_name = p_widget_name;
	IF v_widget_id is null THEN return 1; END IF;

	select	count(*) from im_dynfield_attributes into v_count
	where	acs_attribute_id in (
			select	attribute_id 
			from	acs_attributes 
			where	attribute_name = p_column_name and
				object_type = p_object_type
		);
	IF v_count > 0 THEN return 1; END IF;

	v_min_n_value := 0;
	IF p_required_p = ''t'' THEN  v_min_n_value := 1; END IF;

	v_dynfield_id := im_dynfield_attribute__new (
		null, ''im_dynfield_attribute'', now(), 0, ''0.0.0.0'', null,
		p_object_type, p_column_name, v_min_n_value, 1, null,
		p_datatype, p_pretty_name, p_pretty_name, p_widget_name,
		''f'', ''f'', p_table_name
	);

	update im_dynfield_attributes set also_hard_coded_p = p_also_hard_coded_p
	where attribute_id = v_dynfield_id;

	insert into im_dynfield_layout (
		attribute_id, page_url, pos_y, label_style
	) values (
		v_dynfield_id, ''default'', p_pos_y, ''table''
	);

	-- set all im_dynfield_type_attribute_map to "edit"
	select type_category_type into v_type_category from acs_object_types
	where object_type = p_object_type;
	FOR row IN
		select	category_id
		from	im_categories
		where	category_type = v_type_category
	LOOP
		select	count(*) into v_count from im_dynfield_type_attribute_map
		where	object_type_id = row.category_id and attribute_id = v_dynfield_id;
		IF 0 = v_count THEN
			insert into im_dynfield_type_attribute_map (
				attribute_id, object_type_id, display_mode
			) values (
				v_dynfield_id, row.category_id, ''edit''
			);
		END IF;
	END LOOP;

	PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name=''Employees''), ''read'');
	PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name=''Employees''), ''write'');
	PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name=''Customers''), ''read'');
	PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name=''Customers''), ''write'');
	PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name=''Freelancers''), ''read'');
	PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name=''Freelancers''), ''write'');

	RETURN v_dynfield_id;
END;' language 'plpgsql';

-- Shortcut function
CREATE OR REPLACE FUNCTION im_dynfield_attribute_new (
	varchar, varchar, varchar, varchar, varchar, char(1), integer, char(1)
) RETURNS integer as '
DECLARE
	p_object_type		alias for $1;
	p_column_name		alias for $2;
	p_pretty_name		alias for $3;
	p_widget_name		alias for $4;
	p_datatype		alias for $5;
	p_required_p		alias for $6;
	p_pos_y			alias for $7;
	p_also_hard_coded_p	alias for $8;

	v_table_name		varchar;
BEGIN
	select table_name into v_table_name
	from acs_object_types where object_type = p_object_type;

	RETURN im_dynfield_attribute_new($1,$2,$3,$4,$5,$6,null,''f'',v_table_name);
END;' language 'plpgsql';

-- Shortcut function
CREATE OR REPLACE FUNCTION im_dynfield_attribute_new (
	varchar, varchar, varchar, varchar, varchar, char(1)
) RETURNS integer as '
BEGIN
	RETURN im_dynfield_attribute_new($1,$2,$3,$4,$5,$6,null,''f'');
END;' language 'plpgsql';



SELECT im_dynfield_attribute_new ('im_timesheet_task', 'project_name', 'Name', 
'textbox_medium', 'string', 'f', 0, 't', 'im_projects');
SELECT im_dynfield_attribute_new ('im_timesheet_task', 'project_nr', 'Nr', 
'textbox_medium', 'string', 'f', 10, 't', 'im_projects');

SELECT im_dynfield_attribute_new ('im_timesheet_task', 'parent_id', 'Super Project', 
'open_projects', 'integer', 'f', 20, 't', 'im_projects');

SELECT im_dynfield_attribute_new ('im_timesheet_task', 'project_status_id', 'Status', 
'project_status', 'integer', 'f', 30, 't', 'im_projects');
SELECT im_dynfield_attribute_new ('im_timesheet_task', 'project_type_id', 'Type', 
'project_type', 'integer', 'f', 40, 't', 'im_projects');



-- Make sure the acs_object_type_tables exist
create or replace function inline_0 ()
returns integer as $body$
declare
        v_count                 integer;
begin
	select	count(*) into v_count from acs_object_type_tables
	where	lower(object_type) = 'im_timesheet_task' and lower(table_name) = 'im_timesheet_tasks';
        IF v_count = 0 THEN
		insert into acs_object_type_tables (object_type,table_name,id_column)
		values ('im_timesheet_task', 'im_timesheet_tasks', 'task_id');
	END IF;

	select	count(*) into v_count from acs_object_type_tables
	where	lower(object_type) = 'im_timesheet_task' and lower(table_name) = 'im_projects';
        IF v_count = 0 THEN
		insert into acs_object_type_tables (object_type,table_name,id_column)
		values ('im_timesheet_task', 'im_projects', 'project_id');
	END IF;

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




SELECT im_dynfield_attribute_new ('im_timesheet_task', 'uom_id', 'Unit of Measure', 
'units_of_measure', 'integer', 'f', 50, 't', 'im_timesheet_tasks');
SELECT im_dynfield_attribute_new ('im_timesheet_task', 'material_id', 'Material', 
'materials', 'integer', 'f', 60, 't', 'im_timesheet_tasks');

