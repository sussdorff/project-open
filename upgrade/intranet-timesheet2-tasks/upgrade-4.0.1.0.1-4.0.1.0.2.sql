-- upgrade-4.0.1.0.1-4.0.1.0.2.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.0.1.0.1-4.0.1.0.2.sql','');


-- Does the user have the right to edit task estimates?
select acs_privilege__create_privilege(
	'edit_timesheet_task_completion',
	'Edit Timesheet Completion',
	'Edit Timesheet Completion'
);
select acs_privilege__add_child('admin', 'edit_timesheet_task_completion');
select im_priv_create('edit_timesheet_task_completion', 'Employees');

