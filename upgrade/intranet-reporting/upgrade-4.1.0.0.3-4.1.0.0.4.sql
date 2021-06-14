-- 
-- 
-- 
-- @author Malte Sussdorff (malte.sussdorff@cognovis.de)
-- @creation-date 2013-01-14
-- @cvs-id $Id$
--

SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-4.1.0.0.3-4.1.0.0.4.sql','');


-- ------------------------------------------------------
--------------------------------------------------------------
-- Project Hours View
delete from im_view_columns where view_id = 1014;
delete from im_views where view_id = 1014;

insert into im_views (view_id, view_name, view_label) 
values (1014, 'timesheet_customer_projects_list', 'Timesheet Customer Project Report');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order, variable_name,extra_select,datatype) 
values (1140,1014,'#intranet-core.Customer#','"<a href=''/intranet/companies/view?company_id=$company_id''>$company_name</a>"',1,'company_name','','string');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order,variable_name,datatype) 
values (1141,1014,'#intranet-core.Project#','"<a href=''/intranet/projects/view?project_id=$project_id''>$project_name</a>"',2,'project_name','string');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order,variable_name,datatype) 
values (1142,1014,'#intranet-core.Subproject#','"<a href=''/intranet/projects/view?project_id=$sub_project_id''>$sub_project_name</a>"',3,'sub_project_name','string');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order,variable_name,datatype) 
values (1143,1014,'#intranet-core.User#','"<a href=''/intranet/users/view?user_id=$user_id''>$user_name</a>"',4,'user_name','string');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order,variable_name,datatype) 
values (1144,1014,'#intranet-core.Date#','"$date_pretty"',5,'date_pretty','date');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order,variable_name,datatype) 
values (1145,1014,'#intranet-core.Hours#','"$hours"',6,'hours','float');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order,variable_name,datatype) 
values (1146,1014,'#intranet-core.Rate#','"billing_rate"',7,'billing_rate','float');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order,variable_name,datatype) 
values (1147,1014,'#intranet-core.Note#','"$note"',8,'note','textarea');
