
SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-4.1.0.0.2-4.1.0.0.3.sql','');

update im_categories set aux_string1 = 'invoice' where category_id = 3700;
update im_categories set aux_string1 = 'quote' where category_id = 3702;
update im_categories set aux_string1 = 'order' where category_id = 3703;
update im_categories set aux_string1 = 'bill' where category_id = 3704;
update im_categories set aux_string1 = 'po' where category_id = 3706;
update im_categories set aux_string1 = 'employee' where category_id = 3714;
update im_categories set aux_string1 = 'repcost' where category_id = 3716;
update im_categories set aux_string1 = 'timesheet' where category_id = 3718;
update im_categories set aux_string1 = 'expitem' where category_id = 3720;
update im_categories set aux_string1 = 'exbundle' where category_id = 3722;
update im_categories set aux_string1 = 'delnote' where category_id = 3724;
update im_categories set aux_string1 = 'correction' where category_id = 3725;
update im_categories set aux_string1 = 'timebudget' where category_id = 3726;
update im_categories set aux_string1 = 'explanned' where category_id = 3728;
update im_categories set aux_string1 = 'interco_invoices' where category_id = 3730;
update im_categories set aux_string1 = 'interco_quotes' where category_id = 3732;
update im_categories set aux_string1 = 'prov_receipt' where category_id = 3734;
	
drop view im_cost_types;
create or replace view im_cost_types as
select	category_id as cost_type_id, 
	category as cost_type,
	CASE 
	    WHEN category_id = 3700 THEN 'fi_read_invoices'
	    WHEN category_id = 3702 THEN 'fi_read_quotes'
	    WHEN category_id = 3704 THEN 'fi_read_bills'
	    WHEN category_id = 3706 THEN 'fi_read_pos'
	    WHEN category_id = 3716 THEN 'fi_read_repeatings'
	    WHEN category_id = 3718 THEN 'fi_read_timesheets'
	    WHEN category_id = 3720 THEN 'fi_read_expense_items'
	    WHEN category_id = 3722 THEN 'fi_read_expense_bundles'
	    WHEN category_id = 3724 THEN 'fi_read_delivery_notes'
	    WHEN category_id = 3730 THEN 'fi_read_interco_invoices'
            WHEN category_id = 3732 THEN 'fi_read_interco_quotes'
	    ELSE 'fi_read_all'
	END as read_privilege,
	CASE 
	    WHEN category_id = 3700 THEN 'fi_write_invoices'
	    WHEN category_id = 3702 THEN 'fi_write_quotes'
	    WHEN category_id = 3704 THEN 'fi_write_bills'
	    WHEN category_id = 3706 THEN 'fi_write_pos'
	    WHEN category_id = 3716 THEN 'fi_write_repeatings'
	    WHEN category_id = 3718 THEN 'fi_write_timesheets'
	    WHEN category_id = 3720 THEN 'fi_write_expense_items'
	    WHEN category_id = 3722 THEN 'fi_write_expense_bundles'
	    WHEN category_id = 3724 THEN 'fi_write_delivery_notes'
	    WHEN category_id = 3730 THEN 'fi_write_interco_invoices'
	    WHEN category_id = 3732 THEN 'fi_write_interco_quotes'
	    ELSE 'fi_write_all'
	END as write_privilege,
aux_string1 as short_name
from 	im_categories
where 	category_type = 'Intranet Cost Type';



