-- upgrade-3.1.3.0.0-3.2.0.0.0.sql

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-3.1.3.0.0-3.2.0.0.0.sql','');

delete from im_view_columns where view_id = 35;
delete from im_views where view_id = 35;
insert into im_views (view_id, view_name, visible_for) values (35, 'invoice_list_subtotal', 'view_finance');

-- Invoice List Page - Subtotals
--
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (3501,35,NULL,'Document #',
'','','',1,'');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (3503,35,NULL,'Type',
'','','',3,'');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (3504,35,NULL,'Provider',
'','','',4,'');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (3505,35,NULL,'Customer',
'','','',5,'');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (3507,35,NULL,'Due Date',
'$total_type','','',7,'');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (3511,35,NULL,'Amount',
'"<b>$amount_subtotal</b>"','','',11,'');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (3513,35,NULL,'Paid',
'"<b>$paid_subtotal</b>"','','',13,'');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (3517,35,NULL,'Status',
'','','',17,'');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (3598,35,NULL,'Del',
'','','',99,'');


