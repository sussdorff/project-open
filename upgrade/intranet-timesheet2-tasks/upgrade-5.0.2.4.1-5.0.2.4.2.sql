-- upgrade-5.0.2.4.1-5.0.2.4.2.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-5.0.2.4.1-5.0.2.4.2.sql','');



-- -------------------------------------------------------------------
-- Gantt TaskList
-- -------------------------------------------------------------------

delete from im_view_columns where column_id = 91022;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91022,910,NULL, 
'"<input type=checkbox name=_dummy onclick=acs_ListCheckAll(''tasks'',this.checked)>"',
'"<input type=checkbox name=task_id.$task_id id=tasks,$task_id> <input type=hidden name=task_id_form.$task_id>"', '', '', -1, '');


