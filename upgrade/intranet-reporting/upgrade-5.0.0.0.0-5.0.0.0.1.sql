-- upgrade-5.0.0.0.0-5.0.0.0.1.sql

SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-5.0.0.0.0-5.0.0.0.1.sql','');

delete from im_view_columns where view_id = 930 and column_id = 93014;
delete from im_view_columns where view_id = 930 and column_name = 'Log';


insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl, extra_select, extra_where, sort_order, visible_for) values (93014,930,NULL,'Log','"<span align=right><a href=[export_vars -base $timesheet_report_url { task_id { project_id $project_id } return_url}]>$reported_units_cache</a></span>"','','',14,'');
