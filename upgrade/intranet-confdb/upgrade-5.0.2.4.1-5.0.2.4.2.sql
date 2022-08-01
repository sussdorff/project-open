-- upgrade-5.0.2.3.1-5.0.2.3.2.sql

SELECT acs_log__debug('/packages/intranet-confdb/sql/postgresql/upgrade/upgrade-5.0.2.4.1-5.0.2.4.2.sql','');


delete from im_view_columns where column_id in (94101, 94105, 94110);

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (94101,941,NULL,
'"<input type=checkbox name=_dummy onclick=acs_ListCheckAll(''conf_item'',this.checked)>"',
'"<input type=checkbox name=conf_item_id.$conf_item_id id=conf_item,$conf_item_id>"', 
'', '', 1, '');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (94105, 941, NULL, 'Name',
'"<nobr>$indent_short_html$gif_html<a href=$object_url>$conf_item_name</a></nobr>"','','',5,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (94110, 941, NULL, 'Type',
'"<nobr>$conf_item_type</nobr>"','','',10,'');

