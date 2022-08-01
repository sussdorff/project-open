-- 
-- 
-- 
-- @author Malte Sussdorff (malte.sussdorff@cognovis.de)
-- @creation-date 2013-01-14
-- @cvs-id $Id$
--

SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-4.1.0.0.0-4.1.0.0.1.sql','');


-- ------------------------------------------------------
--------------------------------------------------------------
-- Project Hours View
delete from im_view_columns where view_id = 1006;
delete from im_views where view_id = 1006;


insert into im_views (view_id, view_name, view_label) 
values (1006, 'timesheet_projects_list', 'Timesheet Project Report');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order, variable_name,extra_select,datatype) 
values (1059,1006,'#intranet-core.User#','"<a href=''/intranet/users/view?user_id=$user_id''>$user_name</a>"',1,'username_pretty','','string');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order,variable_name,datatype) 
values (1060,1006,'#intranet-core.Project#','"<a href=''$project_url''>$project_name</a>"',2,'project_name','string');

update im_menus SET url = '/intranet-reporting/timesheet-projects' where url = '/intranet-timesheet2/reports/actual_hours';
update im_menus SET url = '/intranet-reporting/timesheet-projects' where url = '/intranet-timesheet2/reports/timesheet-projects';

select im_menu__new(NULL,'acs_object',now(),NULL,NULL,NULL,'intranet-reporting','reporting-timesheet-planned-hours-report','Timesheet Planned Hours Report','/intranet-reporting/timesheet-planned-projects','2','25975',NULL);

update im_menus SET url = '/intranet-reporting/timesheet-planned-projects' where url = '/intranet-timesheet2/reports/planning_hours';
update im_menus SET url = '/intranet-reporting/timesheet-planned-projects' where url = '/intranet-timesheet2/reports/timesheet-planned-projects';
