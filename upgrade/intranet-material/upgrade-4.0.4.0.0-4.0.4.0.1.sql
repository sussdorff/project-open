-- upgrade-4.0.4.0.0-4.0.4.0.1.sql

SELECT acs_log__debug('/packages/intranet-material/sql/postgresql/upgrade/upgrade-4.0.4.0.0-4.0.4.0.1.sql','');


-- Fix the links in the material list page
delete from im_view_columns where column_id in (90000, 90002);

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (90000,900,NULL,'Nr',
'"<a href=/intranet-material/new?form_mode=display&[export_url_vars material_id return_url]>$material_nr</a>"',
'','',0,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (90002,900,NULL,'Name',
'"<a href=/intranet-material/new?form_mode=display&[export_url_vars material_id return_url]>$material_name</a>"',
'','',2,'');


