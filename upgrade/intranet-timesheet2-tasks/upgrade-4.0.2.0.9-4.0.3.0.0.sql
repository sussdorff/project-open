-- upgrade-4.0.2.0.9-4.0.3.0.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.0.2.0.9-4.0.3.0.0.sql','');


delete from im_view_columns where column_id = 91112;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91112,911,NULL,
'"<input type=checkbox name=_dummy onclick=acs_ListCheckAll(''tasks'',this.checked)>"',
'"<input type=checkbox name=task_id.$task_id id=tasks,$task_id>"', '', '', -1, '');

delete from im_view_columns where column_id = 91022;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91022,910,NULL,
'"<input type=checkbox name=_dummy onclick=acs_ListCheckAll(''tasks'',this.checked)>"',
'"<input type=checkbox name=task_id.$task_id id=tasks,$task_id>"', '', '', -1, '');


