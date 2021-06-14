-- upgrade-3.4.0.1.0-3.4.0.2.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-3.4.0.1.0-3.4.0.2.0.sql','');


-- Add start- and enddate to Tasks main view
--
delete from im_view_columns where column_id in (91007,91008);
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91007,910,NULL,'"Start"',
'"[string range $start_date 0 9]"','','',7,'');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91008,910,NULL,'"End"',
'"[if {[string equal t $red_p]} { set t "<font color=red>[string range $end_date 0 9]</font>" } else { set t [string range $end_date 0 9] }]"','(t.end_date < now() and coalesce(t.percent_completed,0) < 100) as red_p','',8,'');


-- Add start- and enddate to tasks short view
--
delete from im_view_columns where column_id in (91102,91103);
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91102,911,NULL,'"Start"',
'"[string range $start_date 0 9]"','','',2,'');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91103,911,NULL,'"End"',
'"[if {[string equal t $red_p]} { set t "<font color=red>[string range $end_date 0 9]</font>" } else { set t [string range $end_date 0 9] }]"','(t.end_date < now() and coalesce(t.percent_completed,0) < 100) as red_p','',3,'');


-- Make Planned and Billable hours editiable - show fields with textboxes
--
delete from im_view_columns where column_id in (91010,91012);

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91010,910,NULL,'Plan',
'"<input type=textbox size=6 name=planned_units.$task_id value=$planned_units>"','','',10,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91012,910,NULL,'Bill',
'"<input type=textbox size=6 name=billable_units.$task_id value=$billable_units>"','','',12,'');



-- Make Status editable

delete from im_view_columns where column_id = 91018;

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91018,910,NULL,'Status',
'"[im_category_select {Intranet Project Status} task_status_id.$task_id $task_status_id]"','','',12,'');

