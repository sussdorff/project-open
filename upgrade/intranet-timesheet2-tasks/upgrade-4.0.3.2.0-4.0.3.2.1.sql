-- upgrade-4.0.3.2.0-4.0.3.2.1.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.0.3.2.0-4.0.3.2.1.sql','');


-- -------------------------------------------------------------------
-- Gamtt Task List
-- -------------------------------------------------------------------

--
-- Wide View in "Tasks" page, including Description
--
delete from im_view_columns where column_id in (91007, 91008);

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91007,910,NULL,'"Start"',
'"<nobr>[string range $start_date 0 9]</nobr><input type=hidden name=start_date.$task_id value=''[string range $start_date 0 15]''>"','','',7,'');



insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91008,910,NULL,'"End"',
'"[if {[string equal t $red_p]} { set t "<nobr><font color=red>[string range $end_date 0 9]</font></nobr>" } else { set t "<nobr>[string range $end_date 0 9]</nobr>" }]<input type=hidden name=end_date.$task_id value=''[string range $end_date 0 15]''>"','(child.end_date < now() and coalesce(child.percent_completed,0) < 100) as red_p','',8,'');


select im_component_plugin__new (
	null,						-- plugin_id
	'im_component_plugin',				-- object_type
	now(),						-- creation_date
	null,						-- creation_user
	null,						-- creattion_ip
	null,						-- context_id

	'Task Hierarchy',				-- plugin_name
	'intranet-timesheet2-tasks',			-- package_name
	'right',					-- location
	'/intranet-timesheet2-tasks/new',		-- page_url
	null,						-- view_name
	0,						-- sort_order
	'im_project_hierarchy_component -project_id $task_id'
);

