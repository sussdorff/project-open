-- upgrade-5.0.2.2.0-5.0.2.2.1.sql
SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-5.0.2.2.0-5.0.2.2.1.sql','');


delete from im_view_columns where column_id = 93021;
delete from im_view_columns where view_id = 930 and column_name = 'Done';

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (93021,930,NULL, 'Done',
'[expr round(($percent_completed+0) * 10.0) / 10.0]', '','',21,'');

