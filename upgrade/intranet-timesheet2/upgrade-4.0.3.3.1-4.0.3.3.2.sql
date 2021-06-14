-- upgrade-4.0.3.3.1-4.0.3.3.2.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.0.3.3.1-4.0.3.3.2.sql','');


update im_menus
set url = '/intranet-timesheet2/absences/capacity-planning'
where url = '/intranet-timesheet2/capacity-planning';
