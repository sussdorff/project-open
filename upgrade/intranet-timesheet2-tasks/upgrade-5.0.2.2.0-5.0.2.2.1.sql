-- upgrade-5.0.2.2.0-5.0.2.2.1.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-5.0.2.2.0-5.0.2.2.1.sql','');



delete from im_view_columns where column_id = 91014;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91014,910,NULL,'Log',
'"[if {$planned_units > 0.0} { set t "
<div align=right><a href=[export_vars -base $timesheet_report_url {project_id {level_of_detail 5}}] target=_blank>
<font color=$log_color>$reported_units_cache / [expr round(100.0 * $reported_units_cache / $planned_units)]%</font></a></div>
" } else { set t "
<div align=right><a href=[export_vars -base $timesheet_report_url {project_id {level_of_detail 5}}] target=_blank>
<font color=$log_color>$reported_units_cache / -</font></a></div>
" }]"',
'CASE WHEN child.reported_hours_cache > child.percent_completed * t.planned_units / 100.0 
THEN ''red'' ELSE ''#235c96'' END as log_color','',240,'');
