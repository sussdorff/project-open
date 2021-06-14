-- upgrade-3.4.1.0.5-3.4.1.0.6.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-3.4.1.0.5-3.4.1.0.6.sql','');


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

