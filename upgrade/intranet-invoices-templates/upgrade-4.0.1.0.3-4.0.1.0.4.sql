-- 
-- packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.0.1.0.3-4.0.1.0.4.sql
-- 
-- Copyright (c) 2011, cognovís GmbH, Hamburg, Germany
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
-- 
-- @author <yourname> (<your email>)
-- @creation-date 2012-01-31
-- @cvs-id $Id$
--

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.0.1.0.3-4.0.1.0.4.sql','');

-- Support for provider and customer views, supporting openoffice
insert into im_views (view_id, view_name, visible_for) 
values (36, 'invoice_customer_list', 'view_finance');
insert into im_views (view_id, view_name, visible_for) 
values (37, 'invoice_provider_list', 'view_finance');

-- Invoice Customer List Page
--
delete from im_view_columns where view_id = 36;
--
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for, variable_name, datatype) values (3021,36,NULL,'Document #',
'"<A HREF=/intranet-invoices/view?invoice_id=$invoice_id>$invoice_nr</A>"',
'','',1,'','invoice_nr','string');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for, variable_name,datatype) values (3022,36,NULL,'CC',
'$cost_center_name','','',2,'','cost_center_name','string');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for, variable_name,datatype) values (3023,36,NULL,'Type',
'<nobr>$cost_type</nobr>','','',3,'','cost_type','string');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for, variable_name,datatype) values (3024,36,NULL,'Customer',
'"<A HREF=/intranet/companies/view?company_id=$customer_id>$customer_name</A>"',
'','',5,'','customer_name','string');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for, variable_name,datatype) values (3025,36,NULL,'Due Date',
'<nobr>[if {$overdue > 0} {
	set t "<font color=red>$due_date_calculated</font>"
} else {
	set t "$due_date_calculated"
}]</nobr>','','',7,'','due_date_calculated','date');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for, variable_name,datatype) values (3026,36,NULL,'Amount',
'"$invoice_amount_formatted $invoice_currency"','','',11,'','invoice_amount_formatted','currency');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for, variable_name,datatype) values (3027,36,NULL,'Paid',
'"$payment_amount $payment_currency"','','',13,'','payment_amount','currency');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for, variable_name,datatype) values (3028,36,NULL,'Status',
'$status_select','','',17,'','invoice_status_id','category_pretty');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for, variable_name,datatype) values (3029,36,NULL,'Del',
'[if {[string equal "" $payment_amount]} {
	set ttt "
		<input type=checkbox name=del_cost value=$invoice_id>
		<input type=hidden name=object_type.$invoice_id value=$object_type>"
}]','','',99,'','','');



-- Invoice Provider List Page
--
delete from im_view_columns where view_id = 37;
--
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for, variable_name, datatype) values (3031,37,NULL,'Document #',
'"<A HREF=/intranet-invoices/view?invoice_id=$invoice_id>$invoice_nr</A>"',
'','',1,'','invoice_nr','string');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for, variable_name,datatype) values (3032,37,NULL,'CC',
'$cost_center_name','','',2,'','cost_center_name','string');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for, variable_name,datatype) values (3033,37,NULL,'Type',
'<nobr>$cost_type</nobr>','','',3,'','cost_type','string');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for, variable_name,datatype) values (3034,37,NULL,'Provider',
'"<A HREF=/intranet/companies/view?company_id=$provider_id>$provider_name</A>"',
'','',5,'','provider_name','string');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for, variable_name,datatype) values (3035,37,NULL,'Due Date',
'<nobr>[if {$overdue > 0} {
	set t "<font color=red>$due_date_calculated</font>"
} else {
	set t "$due_date_calculated"
}]</nobr>','','',7,'','due_date_calculated','date');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for, variable_name,datatype) values (3036,37,NULL,'Amount',
'"$invoice_amount_formatted $invoice_currency"','','',11,'','invoice_amount_formatted','currency');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for, variable_name,datatype) values (3037,37,NULL,'Paid',
'"$payment_amount $payment_currency"','','',13,'','payment_amount','currency');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for, variable_name,datatype) values (3038,37,NULL,'Status',
'$status_select','','',17,'','invoice_status_id','category_pretty');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for, variable_name,datatype) values (3039,37,NULL,'Del',
'[if {[string equal "" $payment_amount]} {
	set ttt "
		<input type=checkbox name=del_cost value=$invoice_id>
		<input type=hidden name=object_type.$invoice_id value=$object_type>"
}]','','',99,'','','');

update im_menus set url = '/intranet-invoices/list?cost_type_id=3710' where menu_id =10923;