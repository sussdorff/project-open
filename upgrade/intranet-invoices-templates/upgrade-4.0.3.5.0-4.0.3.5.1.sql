-- upgrade-4.0.3.5.0-4.0.3.5.1.sql
SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.0.3.5.0-4.0.3.5.1.sql','');


delete from im_view_columns where column_id in(3098, 3000);
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (3000,30,NULL,'<input type=checkbox name=_dummy onclick=\"acs_ListCheckAll(''cost'',this.checked)\">',
'[if {[string equal "" $payment_amount]} { set ttt "<input type=checkbox name=cost value=$invoice_id id=''cost,$invoice_id''>"}]','','',0,'');

