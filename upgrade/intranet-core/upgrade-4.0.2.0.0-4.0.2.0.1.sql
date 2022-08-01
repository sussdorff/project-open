-- upgrade-4.0.2.0.0-4.0.2.0.1.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.2.0.0-4.0.2.0.1.sql','');




-- Shortcut function
CREATE OR REPLACE FUNCTION im_dynfield_attribute_new (
	varchar, varchar, varchar, varchar, varchar, char(1), integer, char(1), varchar
) RETURNS integer as $body$
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
	-- Make sure the specified widget is available
	select	widget_id into v_widget_id from im_dynfield_widgets
	where	widget_name = p_widget_name;
	IF v_widget_id is null THEN 
		RAISE WARNING 'im_dynfield_attribute_new: Did not find widget=%.', p_widget_name;
		return 1; 
	END IF;

        select  count(*) from im_dynfield_attributes into v_count
        where   acs_attribute_id in (
                        select  attribute_id
                        from    acs_attributes
                        where   attribute_name = p_column_name and
                                object_type = p_object_type
                );

	IF v_count > 0 THEN 
		-- RAISE WARNING 'im_dynfield_attribute_new: Attribute=% already exists.', p_column_name;
		return 1; 
	END IF;

	v_min_n_value := 0;
	IF p_required_p = 't' THEN  v_min_n_value := 1; END IF;

	v_dynfield_id := im_dynfield_attribute__new (
		null, 'im_dynfield_attribute', now(), 0, '0.0.0.0', null,
		p_object_type, p_column_name, v_min_n_value, 1, null,
		p_datatype, p_pretty_name, p_pretty_name, p_widget_name,
		'f', 'f', p_table_name
	);

	update im_dynfield_attributes set also_hard_coded_p = p_also_hard_coded_p
	where attribute_id = v_dynfield_id;

	-- Insert a layout entry into the default page
	select	count(*) into v_count
	from	im_dynfield_layout
	where	attribute_id = v_dynfield_id and page_url = 'default';

	IF 0 = v_count THEN
		insert into im_dynfield_layout (
			attribute_id, page_url, pos_y, label_style
		) values (
			v_dynfield_id, 'default', p_pos_y, 'plain'
		);
	END IF;


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
				v_dynfield_id, row.category_id, 'edit'
			);
		END IF;
	END LOOP;

	PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name='Employees'), 'read');
	PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name='Employees'), 'write');
	PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name='Customers'), 'read');
	PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name='Customers'), 'write');
	PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name='Freelancers'), 'read');
	PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name='Freelancers'), 'write');

	RETURN v_dynfield_id;
END;$body$ language 'plpgsql';

-- Shortcut function
CREATE OR REPLACE FUNCTION im_dynfield_attribute_new (
	varchar, varchar, varchar, varchar, varchar, char(1), integer, char(1)
) RETURNS integer as $body$
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

	RETURN im_dynfield_attribute_new($1,$2,$3,$4,$5,$6,null,'f',v_table_name);
END;$body$ language 'plpgsql';

-- Shortcut function
CREATE OR REPLACE FUNCTION im_dynfield_attribute_new (
	varchar, varchar, varchar, varchar, varchar, char(1)
) RETURNS integer as $body$
BEGIN
	RETURN im_dynfield_attribute_new($1,$2,$3,$4,$5,$6,null,'f');
END;$body$ language 'plpgsql';




SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'category_project_type', 'Project Type', 'Project Type',
	10007, 'integer', 'im_category_tree', 'integer',
	'{custom {category_type "Intranet Project Type"}}'
);

SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'category_project_status', 'Project Status', 'Project Status',
	10007, 'integer', 'im_category_tree', 'integer',
	'{custom {category_type "Intranet Project Status"}}'
);

SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'category_project_on_track_status', 'Project On Track Status', 'Project On Track Status',
	10007, 'integer', 'im_category_tree', 'integer',
	'{custom {category_type "Intranet Project On Track Status"}}'
);


SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'project_managers', 'Project Managers', 'Project Managers',
	10007, 'integer', 'generic_sql', 'integer',
	'{custom {sql {select u.user_id, im_name_from_user_id(u.user_id) from registered_users u, group_distinct_member_map gm where u.user_id = gm.member_id and gm.group_id in (select group_id from groups where group_name = ''Project Managers'') order by lower(im_name_from_user_id(u.user_id)) }}}'
);

SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'project_sponsors', 'Project Sponsors', 'Project Sponsors',
	10007, 'integer', 'generic_sql', 'integer',
	'{custom {sql {select u.user_id, im_name_from_user_id(u.user_id) from registered_users u, group_distinct_member_map gm where u.user_id = gm.member_id and gm.group_id in (select group_id from groups where group_name = ''Senior Managers'') order by lower(im_name_from_user_id(u.user_id)) }}}'
);


SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'parent_projects', 'Parent Projects', 'Parent Projects',
	10007, 'integer', 'generic_sql', 'integer',
	'{custom {sql {select project_id, project_name from im_projects where parent_id is null and project_status_id in (select * from im_sub_categories(76)) order by lower(project_name) }}}'
);

SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'customer_companies', 'Customer Companies', 'Customer Companies',
	10007, 'integer', 'generic_sql', 'integer',
	'{custom {sql {select company_id, company_name from im_companies where company_type_id in (select * from im_sub_categories(57)) and company_status_id in (select * from im_sub_categories(46)) order by lower(company_name) }}}'
);





SELECT im_dynfield_attribute_new ('im_company', 'company_name', 'Name', 'textbox_medium', 'string', 'f', 0, 't', 'im_companies');
SELECT im_dynfield_attribute_new ('im_company', 'company_path', 'Path', 'textbox_medium', 'string', 'f', 10, 't', 'im_companies');
SELECT im_dynfield_attribute_new ('im_company', 'main_office_id', 'Main Office', 'offices', 'integer', 'f', 20, 't', 'im_companies');
SELECT im_dynfield_attribute_new ('im_company', 'company_status_id', 'Status', 'category_company_status', 'integer', 'f', 30, 't', 'im_companies');
SELECT im_dynfield_attribute_new ('im_company', 'company_type_id', 'Type', 'category_company_type', 'integer', 'f', 40, 't', 'im_companies');


SELECT im_dynfield_attribute_new ('im_project', 'project_name', 'Name', 'textbox_large', 'string', 'f', 10, 't');
SELECT im_dynfield_attribute_new ('im_project', 'project_nr', 'Nr', 'textbox_medium', 'string', 'f', 10, 't');
SELECT im_dynfield_attribute_new ('im_project', 'project_path', 'Path', 'textbox_medium', 'string', 'f', 10, 't');
SELECT im_dynfield_attribute_new ('im_project', 'parent_id', 'Parent Project', 'parent_projects', 'string', 'f', 10, 't');
SELECT im_dynfield_attribute_new ('im_project', 'company_id', 'Customer', 'customer_companies', 'string', 'f', 10, 't');
SELECT im_dynfield_attribute_new ('im_project', 'project_type_id', 'Project Type', 'category_project_type', 'string', 'f', 10, 't');
SELECT im_dynfield_attribute_new ('im_project', 'project_status_id', 'Project Status', 'category_project_status', 'string', 'f', 10, 't');

SELECT im_dynfield_attribute_new ('im_project', 'description', 'Description', 'textarea_small', 'string', 'f', 10, 't');
SELECT im_dynfield_attribute_new ('im_project', 'note', 'Note', 'textarea_small', 'string', 'f', 10, 't');
SELECT im_dynfield_attribute_new ('im_project', 'project_lead_id', 'Project Manager', 'project_managers', 'string', 'f', 10, 't');
SELECT im_dynfield_attribute_new ('im_project', 'supervisor_id', 'Project Sponsor', 'project_sponsors', 'string', 'f', 10, 't');
SELECT im_dynfield_attribute_new ('im_project', 'project_budget', 'Budget', 'numeric', 'string', 'f', 10, 't');
SELECT im_dynfield_attribute_new ('im_project', 'percent_completed', '% Done', 'numeric', 'string', 'f', 10, 't');



SELECT im_dynfield_attribute_new ('im_project', 'on_track_status_id', 'On Track', 'category_project_on_track_status', 'string', 'f', 10, 't');
SELECT im_dynfield_attribute_new ('im_project', 'project_budget_currency', 'Budget Currency', 'currencies', 'string', 'f', 10, 't');

-- SELECT im_dynfield_attribute_new ('im_project', 'project_budget_hours', 'Budget Hours', 'numeric', 'f', 10, 't');
-- SELECT im_dynfield_attribute_new ('im_project', 'end_date', 'End', 'date', 'f', 10, 't');
-- SELECT im_dynfield_attribute_new ('im_project', 'start_date', 'Start', 'date', 'string', 'f', 10, 't');
-- SELECT im_dynfield_attribute_new ('im_project', 'template_p', 'Template?', 'string', 'f', 10, 't');
-- SELECT im_dynfield_attribute_new ('im_project', 'company_contact_id', 'Customer Contact', 'string', 'f', 10, 't');
-- SELECT im_dynfield_attribute_new ('im_project', 'company_project_nr', 'Customer PO Number', 'string', 'f', 10, 't');
-- SELECT im_dynfield_attribute_new ('im_project', 'confirm_date', 'Confirm Date', 'date', 'string', 'f', 10, 't');
-- SELECT im_dynfield_attribute_new ('im_project', 'release_item_p', 'Release Item?', 'string', 'f', 10, 't');
-- SELECT im_dynfield_attribute_new ('im_project', 'milestone_p', 'Milestone?', 'string', 'f', 10, 't');
-- SELECT im_dynfield_attribute_new ('im_project', 'presales_probability', 'Presales Probability', 'string', 'f', 10, 't');
-- SELECT im_dynfield_attribute_new ('im_project', 'presales_value', 'Presales Value', 'string', 'f', 10, 't');
-- SELECT im_dynfield_attribute_new ('im_project', 'program_id', 'Program', 'string', 'f', 10, 't');
-- SELECT im_dynfield_attribute_new ('im_project', 'project_priority_id', 'Project Priority', 'string', 'f', 10, 't');
