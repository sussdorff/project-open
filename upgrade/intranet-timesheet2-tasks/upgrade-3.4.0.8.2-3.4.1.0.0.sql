-- upgrade-3.4.0.8.2-3.4.1.0.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-3.4.0.8.2-3.4.1.0.0.sql','');


update im_menus
set url = '/intranet-timesheet2-tasks/index?view_name=im_timesheet_task_list'
where url = '/intranet-timesheet2-tasks/index?view_name=im_timesheeet_task_list'
;
