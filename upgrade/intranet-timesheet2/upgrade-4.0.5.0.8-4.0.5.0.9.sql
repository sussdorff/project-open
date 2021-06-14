-- upgrade-4.0.5.0.8-4.0.5.0.9.sql 

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.0.5.0.8-4.0.5.0.9.sql','');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (20012,200,NULL,'Replacement',
'"$replacement_link"','','',13,'');

