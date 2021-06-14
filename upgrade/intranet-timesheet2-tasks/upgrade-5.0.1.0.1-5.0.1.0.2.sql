-- upgrade-5.0.1.0.1-5.0.1.0.2.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-5.0.1.0.1-5.0.1.0.2.sql','');



-- -------------------------------------------------------------------
-- Gantt TaskList
-- -------------------------------------------------------------------

--
-- Wide View in "Tasks" page, including Description
--
delete from im_view_columns where view_id = 910;
delete from im_views where view_id = 910;
insert into im_views (view_id, view_name, visible_for) values (910, 'im_timesheet_task_list', 'view_projects');

delete from im_view_columns where column_id = 91022;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91022,910,NULL, 
'"<input type=checkbox name=_dummy onclick=acs_ListCheckAll(''tasks'',this.checked)>"',
'"<input type=checkbox name=task_id.$task_id id=tasks,$task_id> <input type=hidden name=task_id_form.$task_id>"', '', '', -1, '');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91000,910,NULL,
'"<a href=$wiki_url/package-intranet-task-management#task_status>[im_gif help "Progress"]</a>"',
'[im_task_management_color_code_gif $progress_status_color_code]','im_task_management_color_code(t.task_id) as progress_status_color_code',
'',0,'im_package_exists_p "intranet-task-management"');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91002,910,NULL,'"Task Name"',
'"<nobr>$indent_html$gif_html<a href=$object_url target=_blank>$task_name</a></nobr>"','','',20,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91004,910,NULL,'Material',
'"<a href=/intranet-material/new?[export_vars -url {material_id return_url}] target=_blank>$material_nr</a>"',
'','',40,'set a 0');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91006,910,NULL,'"CC"',
'"<a href=/intranet-cost/cost-centers/new?[export_vars -url {cost_center_id return_url}] target=_blank>$cost_center_code</a>"',
'','',60,'set a 0');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91007,910,NULL,'"Start"',
'"<nobr>[string range $start_date 0 9]</nobr>"','','',80,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91008,910,NULL,'"End"',
'"<nobr><font color=$end_date_color>[string range $end_date 0 9]</font></nobr>"',
'CASE WHEN child.end_date < now() and coalesce(child.percent_completed,0) < 100 THEN ''red'' ELSE ''black'' END as end_date_color','',100,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91018,910,NULL,'Status',
'$status_select','','',120,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91010,910,NULL,'Plan',
'$planned_hours_input','','',200,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91012,910,NULL,'Bill',
'"<input type=textbox size=3 name=billable_units.$task_id value=$billable_units>"','','',220,'set a 0');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91014,910,NULL,'Log',
'"<div align=right><a href=[export_vars -base $timesheet_report_url {project_id {level_of_detail 5}}] target=_blank>
<font color=$log_color>$reported_units_cache / [expr round(100.0 * $reported_units_cache / ($planned_units+0.00000001))]%</font></a></div>"',
'CASE WHEN child.reported_hours_cache > child.percent_completed * t.planned_units / 100.0 THEN ''red'' ELSE ''#235c96'' END as log_color','',240,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91016,910,NULL,'UoM',
'$uom','','',260,'set a 0');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91021,910,NULL, 'Done',
'$percent_done_input', '','',400,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91023,910,NULL,'"ETC<br>Plan"',
'"<div align=right>[expr round((100.0 - $percent_completed) * $planned_units * 0.1) / 10.0]</div>"','',
'',500,'im_table_exists im_estimate_to_completes');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91025,910,NULL,'"ETC<br>Earned V."',
'"<div align=right>$etc_eva</div>"','
CASE WHEN child.percent_completed > 0.0 
THEN round((child.reported_hours_cache * 100.0 / child.percent_completed)::numeric,1) 
ELSE 0 END as etc_eva',
'',510,'im_table_exists im_estimate_to_completes');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91027,910,NULL,'"ETC<br>Manual"',
'"<div align=right>$etc_manual</div>"','
round(im_estimate_to_complete__user_etc(child.project_id),1) as etc_manual',
'',520,'im_table_exists im_estimate_to_completes');



-- insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
-- extra_select, extra_where, sort_order, visible_for) values (91020,910,NULL, 'Description', 
-- '[string_truncate -len 80 " $description"]', '','',300,'');




