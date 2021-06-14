-- upgrade-4.1.0.0.0-4.1.0.0.1.sql
SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-4.1.0.0.3-4.1.0.0.4.sql','');

-- Create new invoice type for invoice corrections
create or replace function inline_0 ()
returns varchar as $body$
DECLARE
	v_exists_p	integer;
BEGIN
	select count(*) into v_exists_p from im_categories
	where category_id = 3813;
	IF v_exists_p = 0 THEN
		insert into im_categories (
			category_id, category, category_type, 
			sort_order) 
		values (3813, 'Replaced', 'Intranet Cost Status', 
			3813);
	END IF;
	PERFORM im_category_hierarchy_new (3813, 3812);
    	
	return 0;
end;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();



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
		WHEN category_id = 3725 THEN 'fi_read_invoices'		
		WHEN category_id = 3730 THEN 'fi_read_interco_invoices'
		WHEN category_id = 3732 THEN 'fi_read_interco_quotes'
		WHEN category_id = 3735 THEN 'fi_read_bills'
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
		WHEN category_id = 3725 THEN 'fi_write_invoices'		
		WHEN category_id = 3730 THEN 'fi_write_interco_invoices'
		WHEN category_id = 3732 THEN 'fi_write_interco_quotes'
		WHEN category_id = 3735 THEN 'fi_write_bills'
		ELSE 'fi_write_all'
	END as write_privilege,
aux_string1 as short_name
from 	im_categories
where 	category_type = 'Intranet Cost Type';

-- Create new invoice type for invoice corrections
create or replace function inline_0 ()
returns varchar as $body$
DECLARE
	v_exists_p	integer;
BEGIN
	PERFORM im_category_hierarchy_new (3725, 3700);
	PERFORM im_category_hierarchy_new (3735, 3704);
	return 0;
end;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();