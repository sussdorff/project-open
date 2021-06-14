-- upgrade-3.4.0.2.1-3.4.0.5.0.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-3.4.0.2.1-3.4.0.5.0.sql','');


-- ------------------------------------------------
-- Return the final customer name for a cost item
--

create or replace function im_cost_get_final_customer_name(integer)
returns varchar as '
DECLARE
        v_cost_id       alias for $1;
        v_company_name  varchar;
BEGIN
	select	company_name into v_company_name
	from 	im_companies
	where 	company_id in ( 
	        select  company_id
	        from    im_projects
	        where   project_id in (
        	        select  project_id
                	from    im_costs c
	                where   c.cost_id = v_cost_id
        	        )
		);
        return v_company_name;
END;' language 'plpgsql';




-- Interco Invoicing


select acs_privilege__create_privilege('fi_read_interco_invoices','Read Interco Invoices','Read Interco Invoices');
select acs_privilege__create_privilege('fi_write_interco_invoices','Write Interco Invoices','Write Interco Invoices');
select acs_privilege__add_child('fi_read_all', 'fi_read_interco_invoices');
select acs_privilege__add_child('fi_write_all', 'fi_write_interco_invoices');

select acs_privilege__create_privilege('fi_read_interco_quotes','Read Interco Quotes','Read Interco Quotes');
select acs_privilege__create_privilege('fi_write_interco_quotes','Write Interco Quotes','Write Interco Quotes');
select acs_privilege__add_child('fi_read_all', 'fi_read_interco_quotes');
select acs_privilege__add_child('fi_write_all', 'fi_write_interco_quotes');



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
	CASE 
	    WHEN category_id = 3700 THEN 'invoice'
	    WHEN category_id = 3702 THEN 'quote'
	    WHEN category_id = 3704 THEN 'bill'
	    WHEN category_id = 3706 THEN 'po'
	    WHEN category_id = 3716 THEN 'repcost'
	    WHEN category_id = 3718 THEN 'timesheet'
	    WHEN category_id = 3720 THEN 'expitem'
	    WHEN category_id = 3722 THEN 'expbundle'
	    WHEN category_id = 3724 THEN 'delnote'
	    WHEN category_id = 3730 THEN 'interco_invoices'
	    WHEN category_id = 3732 THEN 'interco_quotes'
	    ELSE 'unknown'
	END as short_name
from 	im_categories
where 	category_type = 'Intranet Cost Type';



