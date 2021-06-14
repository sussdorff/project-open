-- upgrade-4.0.2.0.7-4.0.2.0.8.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.0.2.0.7-4.0.2.0.8.sql','');


-- insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
-- extra_select, extra_where, sort_order, visible_for) values (91112,911,NULL,
-- '"[im_gif del "Delete"]"',
-- '"<input type=checkbox name=task_id.$task_id>"', '', '', -1, '');

-- Move the <checkbox> column to the first position in the short task list
update im_view_columns 
set sort_order = -1
where column_id = 91112;

-- Add a new column with the list of task members
delete from im_view_columns where column_id = 91115;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91115,911,NULL,'Members',
'"[im_biz_object_member_list_format $project_member_list]"','','',15,'');

