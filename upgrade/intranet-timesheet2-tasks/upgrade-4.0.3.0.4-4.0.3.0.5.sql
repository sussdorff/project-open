-- upgrade-4.0.3.0.4-4.0.3.0.5.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.0.3.0.4-4.0.3.0.5.sql','');

delete from im_view_columns where column_id = 91014 and view_id = 910;

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91014,910,NULL,'Log',
'"<p align=right><a href=[export_vars -base $timesheet_report_url { { project_id $project_id } return_url}]>
$reported_units_cache</a></p>"','','',14,'');
