-- upgrade-3.4.0.8.1-3.4.0.8.2.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-3.4.0.8.1-3.4.0.8.2.sql','');


-- Show "Next Absence" in employee_list

delete from im_view_columns where column_id = 207;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (207, 10, NULL, 'Next Absence',
'"[im_get_next_absence_link $user_id ]"',
'','',10,'');

