-- upgrade-4.0.2.0.6-4.0.2.0.7.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.0.2.0.6-4.0.2.0.7.sql','');


-- Remove the -restrict_to_task_status_id condition that doesn't work currently
update im_component_plugins set
component_tcl = 'im_timesheet_task_list_component -max_entries_per_page 20 -view_name im_timesheet_task_list_short -restrict_to_mine_p mine'
where plugin_name = 'Home Gantt Tasks' or plugin_name = 'Home Timesheet Tasks';

