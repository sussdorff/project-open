-- upgrade-3.4.0.6.1-3.4.0.6.2.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.6.1-3.4.0.6.2.sql','');



-- Get the object status for generic objects
-- This function relies on the information in the OpenACS SQL metadata
-- system, so that errors in the OO configuration will give errors here.
-- Basically, the acs_object_types table contains the name and the column
-- of the table that stores the "status_id" for the given object type.
-- We will pull out this information and then dynamically create a SQL
-- statement to extract this information.
---
CREATE OR REPLACE FUNCTION im_biz_object__get_status_id (integer)
RETURNS integer AS '
DECLARE
	p_object_id		alias for $1;

	v_object_type		varchar;
	v_supertype		varchar;

	v_status_table		varchar;
	v_status_column		varchar;
	v_status_table_id_col	varchar;

	v_query			varchar;
	row			RECORD;
	v_result_id		integer;
BEGIN
	-- Get information from SQL metadata system
	select	ot.object_type, ot.supertype, ot.status_type_table, ot.status_column
	into	v_object_type, v_supertype, v_status_table, v_status_column
	from	acs_objects o, acs_object_types ot
	where	o.object_id = p_object_id and o.object_type = ot.object_type;

	-- In the case that the information about should not be set up correctly:
	-- Check if the object has a supertype and update table and id_column if necessary
	WHILE v_status_table is null AND ''acs_object'' != v_supertype AND ''im_biz_object'' != v_supertype LOOP
		select	ot.supertype, ot.status_type_table, ot.id_column
		into	v_supertype, v_status_table, v_status_table_id_col
		from	acs_object_types ot
		where	ot.object_type = v_supertype;
	END LOOP;

	-- Get the id_column for the v_status_table (not the objects main table...)
	select	distinct aott.id_column into v_status_table_id_col from acs_object_type_tables aott
	where	aott.object_type = v_object_type and aott.table_name = v_status_table;

	-- Avoid reporting an error. However, this may make it more difficult diagnosing errors.
	IF v_status_table is null OR v_status_table_id_col is null OR v_status_column is null THEN
		return 0;
	END IF;

	-- Funny way, but this is the only option to get a value from an EXECUTE in PG 8.0 and below.
	v_query := '' select '' || v_status_column || '' as result_id '' || '' from '' || v_status_table || 
		'' where '' || v_status_table_id_col || '' = '' || p_object_id;
	FOR row IN EXECUTE v_query
        LOOP
		v_result_id := row.result_id;
		EXIT;
	END LOOP;

	return v_result_id;
END;' language 'plpgsql';



update im_component_plugins set
	title_tcl = null
where
	plugin_name in (
		'Home Big Brother Component',
		'Project Configuration Items',
		'User Configuration Items',
		'Conf Item Members',
		'Task Members',
		'User Notifications',
		'Expense Bundle Confirmation Workflow',
		'Discussions',
		'Project Survey Component',
		'Company Survey Component',
		'User Survey Component',
		'Absence Journal',
		'Absence Workflow',
		'Expense Bundle Confirmation Journal',
		'Timesheet Confirmation Workflow',
		'Timesheet Confirmation Journal',
		'Company Translation Prices',
		'Project Translation Error Component',
		'Company Trados Matrix',
		'Project Freelance Tasks',
		'Project Translation Task Status',
		'Project Translation Details',
		'Project Workflow Journal',
		'Home Workflow Component',
		'Project Workflow Graph',
		'Home Workflow Inbox'
	)
;

-- sort order for demo data  



create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = ''persons'' and lower(column_name) = ''demo_sort_order'';
	IF v_count > 0 THEN RETURN 1; END IF;

	alter table persons add column demo_sort_order integer;

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

