-- upgrade-5.0.2.3.0-5.0.2.3.1.sql

SELECT acs_log__debug('/packages/intranet-confdb/sql/postgresql/upgrade/upgrade-5.0.2.3.0-5.0.2.3.1.sql','');


-- -------------------------------------------------------------------
-- ConfItem List Page Configuration
-- -------------------------------------------------------------------

--
-- 940-949              intranet-confdb
--
--
-- Wide View in ConfItemListPage, including Description
--
delete from im_view_columns where view_id = 940;
delete from im_views where view_id = 940;
--
insert into im_views (view_id, view_name, visible_for) values (940, 'im_conf_item_list', 'view_conf_items');


insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (94001,940,NULL, 
'<input type=checkbox name=_dummy onclick="acs_ListCheckAll(''conf_item'',this.checked)">', 
'$action_checkbox', '', '', 1, '');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (94005, 940, NULL, 'Name',
'"<nobr>$indent<a href=$conf_item_url>$conf_item_name</a></nobr>"','','',5,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (94010, 940, NULL, 'Type',
'"<nobr>$conf_item_type</nobr>"','','',10,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (94020, 940, NULL, 'Status',
'"<nobr>$conf_item_status</nobr>"','','',20,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (94030, 940, NULL, 'CC',
'"<nobr>$conf_item_cost_center_name</nobr>"','','',30,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (94040, 940, NULL, 'IP',
'"<nobr>$ip_address</nobr>"','','',40,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (94090, 940, NULL, 'Descr',
'"$description"','','',90,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (94092, 940, NULL, 'Note',
'"$note"','','',92,'');




--
-- short view for ticket and project pages
--
delete from im_view_columns where view_id = 941;
delete from im_views where view_id = 941;
--
insert into im_views (view_id, view_name, visible_for) values (941, 'im_conf_item_list_short', 'view_conf_items');



insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (94101,941,NULL, 
'<input type=checkbox name=_dummy onclick="acs_ListCheckAll(''conf_item'',this.checked)">', 
'$action_checkbox', '', '', 1, '');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (94105, 941, NULL, 'Name',
'"<nobr>$indent<a href=$conf_item_url>$conf_item_name</a></nobr>"','','',5,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (94110, 941, NULL, 'Type',
'"<nobr>$conf_item_type</nobr>"','','',10,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (94120, 941, NULL, 'Status',
'"<nobr>$conf_item_status</nobr>"','','',20,'');

