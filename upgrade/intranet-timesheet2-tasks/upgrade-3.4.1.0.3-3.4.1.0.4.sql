-- upgrade-3.4.1.0.3-3.4.1.0.4.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-3.4.1.0.3-3.4.1.0.4.sql','');


update im_view_columns 
set column_render_tcl = '$planned_hours_input'
where column_id = 91010;

update im_view_columns 
set column_render_tcl = '$billable_hours_input'
where column_id = 91012;

update im_view_columns 
set column_render_tcl = '$status_select'
where column_id = 91018;

update im_view_columns 
set column_render_tcl = '$percent_done_input'
where column_id = 91021;

