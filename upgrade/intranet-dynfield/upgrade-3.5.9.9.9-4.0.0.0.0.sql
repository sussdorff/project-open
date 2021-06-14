-- upgrade-3.5.9.9.9-4.0.0.0.0.sql

SELECT acs_log__debug('/packages/intranet-dynfield/sql/postgresql/upgrade/upgrade-3.5.9.9.9-4.0.0.0.0.sql','');

create or replace function im_dynfield_widget__new (
	integer, varchar, timestamptz, integer, varchar, integer,
	varchar, varchar, varchar, integer, varchar, varchar,
	varchar, varchar, varchar
) returns integer as '
DECLARE
	p_widget_id		alias for $1;
	p_object_type		alias for $2;
	p_creation_date		alias for $3;
	p_creation_user		alias for $4;
	p_creation_ip		alias for $5;
	p_context_id		alias for $6;

	p_widget_name		alias for $7;
	p_pretty_name		alias for $8;
	p_pretty_plural		alias for $9;
	p_storage_type_id	alias for $10;
	p_acs_datatype		alias for $11;
	p_widget		alias for $12;
	p_sql_datatype		alias for $13;
	p_parameters		alias for $14;
	p_deref_plpgsql_function alias for $15;

	v_widget_id		integer;
BEGIN
	select widget_id into v_widget_id from im_dynfield_widgets
	where widget_name = p_widget_name;
	if v_widget_id is not null then return v_widget_id; end if;

	v_widget_id := acs_object__new (
		p_widget_id,
		p_object_type,
		p_creation_date,
		p_creation_user,
		p_creation_ip,
		p_context_id
	);

	insert into im_dynfield_widgets (
		widget_id, widget_name, pretty_name, pretty_plural,
		storage_type_id, acs_datatype, widget, sql_datatype, parameters, deref_plpgsql_function
	) values (
		v_widget_id, p_widget_name, p_pretty_name, p_pretty_plural,
		p_storage_type_id, p_acs_datatype, p_widget, p_sql_datatype, p_parameters, p_deref_plpgsql_function
	);
	return v_widget_id;
end;' language 'plpgsql';




create or replace function im_dynfield_attribute__new_only_dynfield (
	integer, varchar, timestamptz, integer, varchar, integer,
	integer, varchar, char(1), char(1), integer, varchar, char(1), char(1)
) returns integer as '
DECLARE
	p_attribute_id		alias for $1;
	p_object_type		alias for $2;
	p_creation_date		alias for $3;
	p_creation_user		alias for $4;
	p_creation_ip		alias for $5;
	p_context_id		alias for $6;

	p_acs_attribute_id	alias for $7;
	p_widget_name		alias for $8;
	p_deprecated_p		alias for $9;
	p_already_existed_p	alias for $10;
	p_pos_y			alias for $11;
	p_label_style		alias for $12;
	p_also_hard_coded_p	alias for $13;
	p_include_in_search_p	alias for $14;

	v_count			integer;
        v_attribute_id          integer;
	v_type_category 	varchar;

	row			RECORD;
BEGIN
	v_attribute_id := acs_object__new (
		p_attribute_id,
		p_object_type,
		p_creation_date,
		p_creation_user,
		p_creation_ip,
		p_context_id
	);

	insert into im_dynfield_attributes (
		attribute_id, acs_attribute_id, widget_name, also_hard_coded_p,
		deprecated_p, already_existed_p, include_in_search_p
	) values (
		v_attribute_id, p_acs_attribute_id, p_widget_name, p_also_hard_coded_p,
		p_deprecated_p, p_already_existed_p, p_include_in_search_p
	);

	insert into im_dynfield_layout (
		attribute_id, page_url, pos_y, label_style
	) values (
		v_attribute_id, ''default'', p_pos_y, p_label_style
	);


	-- set all im_dynfield_type_attribute_map to "edit"
	select type_category_type into v_type_category from acs_object_types
	where object_type = p_object_type;
	FOR row IN
		select  category_id
		from	im_categories
		where	category_type = v_type_category
	LOOP
		select  count(*) into v_count from im_dynfield_type_attribute_map
		where	object_type_id = row.category_id and attribute_id = v_attribute_id;
		IF 0 = v_count THEN
				insert into im_dynfield_type_attribute_map (
					attribute_id, object_type_id, display_mode
				) values (
					v_attribute_id, row.category_id, ''edit''
				);
		END IF;
	END LOOP;

	PERFORM acs_permission__grant_permission(v_attribute_id, (select group_id from groups where group_name=''Employees''), ''read'');
	PERFORM acs_permission__grant_permission(v_attribute_id, (select group_id from groups where group_name=''Employees''), ''write'');
	PERFORM acs_permission__grant_permission(v_attribute_id, (select group_id from groups where group_name=''Customers''), ''read'');
	PERFORM acs_permission__grant_permission(v_attribute_id, (select group_id from groups where group_name=''Customers''), ''write'');
	PERFORM acs_permission__grant_permission(v_attribute_id, (select group_id from groups where group_name=''Freelancers''), ''read'');
	PERFORM acs_permission__grant_permission(v_attribute_id, (select group_id from groups where group_name=''Freelancers''), ''write'');

	return v_attribute_id;
end;' language 'plpgsql';


CREATE OR REPLACE VIEW ams_attributes as
	select  aa.*,
		da.attribute_id as dynfield_attribute_id,
		da.acs_attribute_id,
		da.widget_name as widget,
		da.already_existed_p,
		da.deprecated_p
	from
		acs_attributes aa
		LEFT JOIN im_dynfield_attributes da ON (aa.attribute_id = da.acs_attribute_id)
;




create or replace function inline_0 ()
returns integer as '
declare
	v_count	integer;
begin
	select count(*) into v_count from acs_datatypes
	where datatype = ''richtext'';
	IF v_count > 0 THEN return 1; END IF;

	insert into acs_datatypes (datatype,max_n_values) values (''richtext'', null);

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




SELECT im_dynfield_widget__new (
	null,
	'im_dynfield_widget',
	now(),
	null,
	null,
	null,
	'richtext',
	'Richtext',
	'Richtexts',
	10007,
	'richtext',
	'richtext',
	'im_name_from_id',
	null
);




-- Add javascript calendar buton on date widget
UPDATE im_dynfield_widgets 
SET parameters = '{format "YYYY-MM-DD"} {after_html {<input type="button" style="height:20px; width:20px; background: url(''/resources/acs-templating/calendar.gif'');" onclick ="return showCalendarWithDateWidget(''$attribute_name'', ''y-m-d'');" ></b>}}' 
WHERE widget_name = 'date';


-- Fix acs_attributes tablename
update acs_attributes set table_name = 'im_projects'
where object_type = 'im_project' and table_name is null;


create or replace function im_dynfield_widget__delete (integer) returns integer as '
DECLARE
	p_widget_id		alias for $1;
BEGIN
	-- Erase the im_dynfield_widgets item associated with the id
	delete from im_dynfield_widgets
	where widget_id = p_widget_id;

	-- Erase all the privileges
	delete from acs_permissions
	where object_id = p_widget_id;

	PERFORM acs_object__delete(v_widget_id);
	return 0;
end;' language 'plpgsql';


create or replace function im_percent_from_number (float)
returns varchar as '
DECLARE
	p_percent	alias for $1;
	v_percent	varchar;
BEGIN
	select to_char(p_percent,''90D99'') || '' %'' into v_percent;
	return v_percent;
END;' language 'plpgsql';


create or replace function im_numeric_from_id(float)
returns varchar as '
DECLARE
	v_result	alias for $1;
BEGIN
	return v_result::varchar;
END;' language 'plpgsql';


UPDATE im_dynfield_widgets 
SET deref_plpgsql_function = 'im_numeric_from_id'
WHERE widget_name ='numeric';
