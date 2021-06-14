-- upgrade-3.3.1.0.0-3.3.1.1.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.3.1.0.0-3.3.1.1.0.sql','');

\i upgrade-3.0.0.0.first.sql


-- Fix issue with im_costs__name -> im_cost__name
update acs_object_types set name_method = 'im_cost__name' where object_type = 'im_cost';



create or replace function im_cost__name (integer)
returns varchar as '
DECLARE
	p_cost_id	alias for $1;
	v_name		varchar;
begin
	select  cost_name into v_name from im_costs
	where   cost_id = p_cost_id;

	return v_name;
end;' language 'plpgsql';




-- Set permissions on all Plugin Components for Employees, Freelancers and Customers.
create or replace function inline_0 ()
returns varchar as '
DECLARE
	v_count		integer;
	v_plugin_id	integer;
	row		RECORD;

	v_emp_id	integer;
	v_freel_id	integer;
	v_cust_id	integer;
BEGIN
	select group_id into v_emp_id from groups where group_name = ''Employees'';
	select group_id into v_freel_id from groups where group_name = ''Freelancers'';
	select group_id into v_cust_id from groups where group_name = ''Customers'';

	-- Check if permissions were already configured
	-- Stop if there is just a single configured plugin.
	select	count(*) into v_count
	from	acs_permissions p,
		im_component_plugins pl
	where	p.object_id = pl.plugin_id;
	IF v_count > 0 THEN return 0; END IF;

	-- Add read permissions to all plugins
	FOR row IN
		select	plugin_id
		from	im_component_plugins pl
	LOOP
		PERFORM im_grant_permission(row.plugin_id, v_emp_id, ''read'');
		PERFORM im_grant_permission(row.plugin_id, v_freel_id, ''read'');
		PERFORM im_grant_permission(row.plugin_id, v_cust_id, ''read'');
	END LOOP;

	return 0;
END;' language 'plpgsql';
select inline_0();
drop function inline_0();





-- --------------------------------------------------------
-- Setup object subtypes

update acs_object_types set supertype = 'im_project' where object_type = 'im_timesheet_task';
update acs_object_types set supertype = 'im_cost' where object_type = 'im_invoice';


create or replace function inline_0 ()
returns integer as '
DECLARE
        v_count                 integer;
BEGIN
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = ''acs_object_types'' and lower(column_name) = ''status_column'';
        IF v_count > 0 THEN return 0; END IF;

        alter table acs_object_types
        add status_column character varying(30);

        alter table acs_object_types
        add type_column character varying(30);

        alter table acs_object_types
        add status_type_table character varying(30);

        return 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();




update acs_object_types set 
	status_type_table = 'im_user_absences',
	status_column = 'absence_status_id', 
	type_column = 'absence_type_id' 
where object_type = 'im_user_absence';

update acs_object_types set 
	status_type_table = 'im_companies', 
	status_column = 'company_status_id', 
	type_column = 'company_type_id' 
where object_type = 'im_company';

update acs_object_types set 
	status_type_table = 'im_costs', 
	status_column = 'cost_status_id', 
	type_column = 'cost_type_id' 
where object_type = 'im_cost';

update acs_object_types set 
	status_type_table = 'im_cost_centers', 
	status_column = 'cost_center_status_id', 
	type_column = 'cost_center_type_id' 
where object_type = 'im_cost_center';

update acs_object_types set 
	status_type_table = 'im_costs', 
	status_column = 'cost_status_id', 
	type_column = 'cost_type_id' 
where object_type = 'im_expense';

update acs_object_types set 
	status_type_table = 'im_forum_topics', 
	status_column = 'topic_status_id', 
	type_column = 'topic_type_id' 
where object_type = 'im_forum_topic';

update acs_object_types set 
	status_type_table = 'im_freelance_rfqs', 
	status_column = 'rfq_status_id', 
	type_column = 'rfq_type_id' 
where object_type = 'im_freelance_rfq';

update acs_object_types set 
	status_type_table = 'im_freelance_rfq_answers', 
	status_column = 'answer_status_id', 
	type_column = 'answer_type_id' 
where object_type = 'im_freelance_rfq_answer';

update acs_object_types set 
	status_type_table = 'im_costs', 
	status_column = 'cost_status_id', 
	type_column = 'cost_type_id' 
where object_type = 'im_invoice';

update acs_object_types set 
	status_type_table = 'im_materials', 
	status_column = 'material_status_id', 
	type_column = 'material_type_id' 
where object_type = 'im_material';

update acs_object_types set 
	status_type_table = NULL, 
	status_column = NULL, 
	type_column = NULL 
where object_type = 'im_menu';

update acs_object_types set 
	status_type_table = 'im_notes', 
	status_column = 'note_status_id', 
	type_column = 'note_type_id' 
where object_type = 'im_note';

update acs_object_types set 
	status_type_table = 'im_offices', 
	status_column = 'office_status_id', 
	type_column = 'office_type_id' 
where object_type = 'im_office';

update acs_object_types set 
	status_type_table = 'im_costs', 
	status_column = 'cost_status_id', 
	type_column = 'cost_type_id' 
where object_type = 'im_repeating_cost';

update acs_object_types set 
	status_type_table = 'im_reports', 
	status_column = 'report_status_id', 
	type_column = 'report_type_id' 
where object_type = 'im_report';

update acs_object_types set 
	status_type_table = 'im_costs', 
	status_column = 'cost_status_id', 
	type_column = 'cost_type_id' 
where object_type = 'im_timesheet_invoice';

update acs_object_types set 
	status_type_table = 'im_projects', 
	status_column = 'project_status_id', 
	type_column = 'project_type_id' 
where object_type = 'im_timesheet_task';

update acs_object_types set 
	status_type_table = 'im_projects', 
	status_column = 'project_status_id', 
	type_column = 'project_type_id' 
where object_type = 'im_project';

update acs_object_types set 
	status_type_table = 'im_costs', 
	status_column = 'cost_status_id', 
	type_column = 'cost_type_id' 
where object_type = 'im_trans_invoice';

update acs_object_types set 
	status_type_table = 'im_trans_tasks', 
	status_column = 'task_status_id', 
	type_column = 'task_type_id' 
where object_type = 'im_trans_task';

update acs_object_types set 
	status_type_table = 'im_costs', 
	status_column = 'cost_status_id', 
	type_column = 'cost_type_id' 
where object_type = 'im_investment';



-- ---------------------------------------------------------------


-- ---------------------------------------------------------------
-- Find out the status and type of business objects in a generic way

CREATE OR REPLACE FUNCTION im_biz_object__get_type_id (integer)
RETURNS integer AS '
DECLARE
	p_object_id		alias for $1;

	v_query			varchar;
	v_object_type		varchar;
	v_supertype		varchar;
	v_table			varchar;
	v_id_column		varchar;
	v_type_column		varchar;

	row			RECORD;
	v_result_id		integer;
BEGIN
	-- Get information from SQL metadata system
	select	ot.object_type, ot.supertype, ot.status_type_table, ot.type_column
	into	v_object_type, v_supertype, v_table, v_type_column
	from	acs_objects o, acs_object_types ot
	where	o.object_id = p_object_id
		and o.object_type = ot.object_type;

	-- Check if the object has a supertype and update table necessary
	WHILE v_table is null AND ''acs_object'' != v_supertype AND ''im_biz_object'' != v_supertype LOOP
		select	ot.supertype, ot.table_name
		into	v_supertype, v_table
		from	acs_object_types ot
		where	ot.object_type = v_supertype;
	END LOOP;

	-- Get the id_column for v_table
	select	aott.id_column into v_id_column from acs_object_type_tables aott
	where	aott.object_type = v_object_type and aott.table_name = v_table;

	IF v_table is null OR v_id_column is null OR v_type_column is null THEN
		return 0;
	END IF;

	-- Funny way, but this is the only option to EXECUTE in PG 8.0 and below.
	v_query := '' select '' || v_type_column || '' as result_id '' || '' from '' || v_table || 
		'' where '' || v_id_column || '' = '' || p_object_id;
	FOR row IN EXECUTE v_query
        LOOP
		v_result_id := row.result_id;
		EXIT;
	END LOOP;

	return v_result_id;
END;' language 'plpgsql';



CREATE OR REPLACE FUNCTION im_biz_object__get_status_id (integer)
RETURNS integer AS '
DECLARE
	p_object_id		alias for $1;

	v_query			varchar;
	v_object_type		varchar;
	v_supertype		varchar;
	v_table			varchar;
	v_id_column		varchar;
	v_column		varchar;

	row			RECORD;
	v_result_id		integer;
BEGIN
	-- Get information from SQL metadata system
	select	ot.object_type, ot.supertype, ot.table_name, ot.status_column
	into	v_object_type, v_supertype, v_table, v_column
	from	acs_objects o, acs_object_types ot
	where	o.object_id = p_object_id
		and o.object_type = ot.object_type;

	-- Check if the object has a supertype and update table and id_column if necessary
	WHILE v_table is null AND ''acs_object'' != v_supertype AND ''im_biz_object'' != v_supertype LOOP
		select	ot.supertype, ot.table_name, ot.id_column
		into	v_supertype, v_table, v_id_column
		from	acs_object_types ot
		where	ot.object_type = v_supertype;
	END LOOP;

	-- Get the id_column for v_table
	select	aott.id_column into v_id_column from acs_object_type_tables aott
	where	aott.object_type = v_object_type and aott.table_name = v_table;

	IF v_table is null OR v_id_column is null OR v_column is null THEN
		return 0;
	END IF;

	-- Funny way, but this is the only option to get a value from an EXECUTE in PG 8.0 and below.
	v_query := '' select '' || v_column || '' as result_id '' || '' from '' || v_table || 
		'' where '' || v_id_column || '' = '' || p_object_id;
	FOR row IN EXECUTE v_query
        LOOP
		v_result_id := row.result_id;
		EXIT;
	END LOOP;

	return v_result_id;
END;' language 'plpgsql';



-----------------------------------------------------------------------
-- Set the status of Biz Objects in a generic way


CREATE OR REPLACE FUNCTION im_biz_object__set_status_id (integer, integer) RETURNS integer AS '
DECLARE
	p_object_id		alias for $1;
	p_status_id		alias for $2;
	v_object_type		varchar;
	v_supertype		varchar;	v_table			varchar;
	v_id_column		varchar;	v_column		varchar;
	row			RECORD;
BEGIN
	-- Get information from SQL metadata system
	select	ot.object_type, ot.supertype, ot.table_name, ot.id_column, ot.status_column
	into	v_object_type, v_supertype, v_table, v_id_column, v_column
	from	acs_objects o, acs_object_types ot
	where	o.object_id = p_object_id
		and o.object_type = ot.object_type;

	-- Check if the object has a supertype and update table and id_column if necessary
	WHILE ''acs_object'' != v_supertype AND ''im_biz_object'' != v_supertype LOOP
		select	ot.supertype, ot.table_name, ot.id_column
		into	v_supertype, v_table, v_id_column
		from	acs_object_types ot
		where	ot.object_type = v_supertype;
	END LOOP;

	IF v_table is null OR v_id_column is null OR v_column is null THEN
		RAISE NOTICE ''im_biz_object__set_status_id: Bad metadata: Null value for %'',v_object_type;
		return 0;
	END IF;

	update	acs_objects
	set	last_modified = now()
	where	object_id = p_object_id;

	EXECUTE ''update ''||v_table||'' set ''||v_column||''=''||p_status_id||
		'' where ''||v_id_column||''=''||p_object_id;

	return 0;
END;' language 'plpgsql';



-- compatibility for WF calls
CREATE OR REPLACE FUNCTION im_biz_object__set_status_id (integer, varchar, integer) RETURNS integer AS '
DECLARE
	p_object_id		alias for $1;
	p_dummy			alias for $2;
	p_status_id		alias for $3;
BEGIN
	return im_biz_object__set_status_id (p_object_id, p_status_id::integer);
END;' language 'plpgsql';





-- Return the Cost Center code
create or replace function im_dept_from_user_id(integer)
returns varchar as '
DECLARE
	v_user_id       alias for $1;
	v_dept	varchar;
BEGIN
	select  cost_center_code into v_dept
	from    im_employees e,
		im_cost_centers cc
	where   e.employee_id = v_user_id
		and e.department_id = cc.cost_center_id;

	return v_dept;
END;' language 'plpgsql';
select im_dept_from_user_id(624);




-- -------------------------------------------------------
-- Setup an invisible Admin menu for TimesheetNewPage
--

create or replace function inline_0 ()
returns integer as '
declare
        -- Menu IDs
        v_menu                  integer;
        v_admin_menu            integer;
        v_main_menu             integer;
BEGIN
        select menu_id into v_main_menu
        from im_menus where label = ''timesheet2_timesheet'';

        -- Main admin menu - just an invisible top-menu
        -- for all admin entries links under Projects
        v_admin_menu := im_menu__new (
                null,                   -- p_menu_id
                ''im_menu'',		-- object_type
                now(),                  -- creation_date
                null,                   -- creation_user
                null,                   -- creation_ip
                null,                   -- context_id
                ''intranet-core'',      -- package_name
                ''timesheet_hours_new_admin'',  -- label
                ''Timesheet Hours New Admin'',  -- name
                ''/intranet-timesheet2/hours/'',        -- url
                90,                     -- sort_order
                v_main_menu,            -- parent_menu_id
                ''0''                   -- p_visible_tcl
        );

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

