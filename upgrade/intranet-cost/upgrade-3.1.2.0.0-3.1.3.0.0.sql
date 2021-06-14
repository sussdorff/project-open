-- /packages/intranet-cost/sql/postgres/upgrade/upgrade-3.1.2.0.0-3.1.3.0.0.sql
--
-- Cost Core
-- 040207 frank.bergmann@project-open.com
--
-- Copyright (C) 2004 - 2009 ]project-open[
--
-- All rights including reserved. To inquire license terms please 
-- refer to http://www.project-open.com/modules/<module-key>

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-3.1.2.0.0-3.1.3.0.0.sql','');



-------------------------------------------------------------
-- 
---------------------------------------------------------

-- Project Profit & Loss List
-- The "view_id = 21" entry has already been added in intranet_views.sql
--
delete from im_view_columns where column_id > 2100 and column_id < 2199;
--
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2101,21,NULL,'Project Nr',
'"<A HREF=/intranet/projects/view?project_id=$project_id>$project_nr</A>"',
'','',1,'');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2102,21,NULL,'Name',
'"<A HREF=/intranet/projects/view?project_id=$project_id>$project_name</A>"',
'','',2,'');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2103,21,NULL,'Client',
'"<A HREF=/intranet/companies/view?company_id=$company_id>$company_name</A>"',
'','',3,'im_permission $user_id view_companies');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2105,21,NULL,'Type',
'$project_type','','',5,'');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2107,21,NULL,'Status',
'$project_status','','',7,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2111,21,NULL,'Budget',
'"$project_budget $project_budget_currency"','','',11,'');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2113,21,NULL,'Budget Hours',
'$project_budget_hours','','',13,'');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2115,21,NULL,'Perc Compl',
'$percent_completed','','',15,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2131,21,NULL,'Invoices',
'$cost_invoices_cache','','',31,'im_permission $user_id view_finance');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2133,21,NULL,'Bills',
'$cost_bills_cache','','',33,'im_permission $user_id view_finance');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2135,21,NULL,'Time sheet',
'$cost_timesheet_logged_cache','','',35,'im_permission $user_id view_finance');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2137,21,NULL,'Profit',
'[expr [n20 $cost_invoices_cache] - [n20 $cost_bills_cache] - [n20 $cost_timesheet_logged_cache]]',
'','',37,'im_permission $user_id view_finance');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2141,21,NULL,'Quotes',
'$cost_quotes_cache','','',41,'im_permission $user_id view_finance');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2143,21,NULL,'POs',
'$cost_purchase_orders_cache','','',43,'im_permission $user_id view_finance');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2145,21,NULL,'Time plan',
'$cost_timesheet_planned_cache','','',45,'im_permission $user_id view_finance');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2147,21,NULL,'Prelim Profit',
'[expr [n20 $cost_quotes_cache] - [n20 $cost_purchase_orders_cache] - [n20 $cost_timesheet_planned_cache]]',
'','',47,'im_permission $user_id view_finance');



