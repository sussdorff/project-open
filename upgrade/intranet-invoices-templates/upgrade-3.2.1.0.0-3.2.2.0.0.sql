-- upgrade-3.2.1.0.0-3.2.2.0.0.sql

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-3.2.1.0.0-3.2.2.0.0.sql','');



update im_menus 
set visible_tcl = '[im_cost_type_write_p $user_id 3700]'
where label = 'invoices_customers_new_invoice';


update im_menus 
set visible_tcl = '[im_cost_type_write_p $user_id 3700]'
where label = 'invoices_customers_new_invoice_from_quote';


update im_menus 
set visible_tcl = '[im_cost_type_write_p $user_id 3702]'
where label = 'invoices_customers_new_quote';


update im_menus 
set visible_tcl = '[im_cost_type_write_p $user_id 3704]'
where label = 'invoices_providers_new_bill_from_po';


update im_menus 
set visible_tcl = '[im_cost_type_write_p $user_id 3704]'
where label = 'invoices_providers_new_bill';


