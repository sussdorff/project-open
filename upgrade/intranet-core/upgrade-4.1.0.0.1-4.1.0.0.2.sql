-- upgrade-4.1.0.0.1-4.1.0.0.2.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.0.0.1-4.1.0.0.2.sql','');


create or replace function inline_0 () 
returns integer as $body$
DECLARE
	v_count			integer;
	v_num_main_projects	integer;
	v_num_template_projects	integer;
BEGIN
	-- Check that template_p exists in the database
	select	count(*) into v_count 
	from	user_tab_columns 
	where	lower(table_name) = 'im_projects' and
		lower(column_name) = 'template_p';
	IF v_count = 0  THEN return 1; END IF; 

	-- Set the default to false
	alter table im_projects alter column template_p set default 'f';

	-- Check if the majority of main projects is a template.
	-- This is an indicator that the configuration was wrong.
	select count(*) into v_num_main_projects from im_projects where parent_id is null;
	select count(*) into v_num_template_projects from im_projects where parent_id is null and template_p = 't';
	IF v_num_template_projects > 0.5 * v_num_main_projects THEN 

		-- reset all template information
		update im_projects set template_p = 'f';

	END IF;

	return 0;
END;$body$ language 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();

