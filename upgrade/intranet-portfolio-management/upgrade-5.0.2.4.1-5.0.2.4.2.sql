-- upgrade-5.0.2.4.1-5.0.2.4.2.sql

SELECT acs_log__debug('/packages/intranet-portfolio-management/sql/postgresql/upgrade/upgrade-5.0.2.4.1-5.0.2.4.2.sql','');

delete from im_view_columns where column_id = 30010;
insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (30010,300,'Program Name',
'"<A HREF=/intranet/projects/view?project_id=$project_id>[string range $project_name 0 40]</A>"','','',10,'');



