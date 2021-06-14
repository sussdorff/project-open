-- upgrade-4.0.1.0.9-4.0.2.0.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.0.1.0.9-4.0.2.0.0.sql','');



update im_categories
set category_type = 'Intranet Gantt Task Fixed Task Type'
where category_type = 'Intranet Gantt Task Effort Driven Type' or category_type = 'Intranet Timesheet Task Effort Driven Type';


SELECT im_category_new(9720,'Fixed Units', 'Intranet Gantt Task Fixed Task Type');
SELECT im_category_new(9721,'Fixed Duration', 'Intranet Gantt Task Fixed Task Type');
SELECT im_category_new(9722,'Fixed Work', 'Intranet Gantt Task Fixed Task Type');



-- Create MS-Project field for effort_driven_p and
-- effort_driven_type_id.
---
create or replace function inline_0 ()
returns integer as $body$
declare
	v_count		integer;
begin
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_timesheet_tasks' and lower(column_name) = 'scheduling_constraint_id';
	IF v_count = 0 THEN 
		alter table im_timesheet_tasks 
		add column scheduling_constraint_id integer
		constraint im_timesheet_tasks_scheduling_constraint_fk
                references im_categories;
	END IF;

	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_timesheet_tasks' and lower(column_name) = 'scheduling_constraint_date';
	IF v_count = 0 THEN 
		alter table im_timesheet_tasks 
		add column scheduling_constraint_date timestamptz;
	END IF;

	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_timesheet_tasks' and lower(column_name) = 'effort_driven_type_id';
	IF v_count = 0 THEN 
		alter table im_timesheet_tasks 
		add column effort_driven_type_id integer
		constraint im_timesheet_tasks_effort_driven_type_fk
                references im_categories;
	END IF;

	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_timesheet_tasks' and lower(column_name) = 'deadline_date';
	IF v_count = 0 THEN 
		alter table im_timesheet_tasks 
		add column deadline_date timestamptz;
	END IF;

	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_timesheet_tasks' and lower(column_name) = 'effort_driven_p';
	IF v_count = 0 THEN 
		alter table im_timesheet_tasks 
		add column effort_driven_p char(1) default('t')
		constraint im_timesheet_tasks_effort_driven_ck
                check (effort_driven_p in ('t','f'));
	END IF;

	RETURN 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();
