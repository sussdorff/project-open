-- upgrade-3.4.0.2.0-3.4.0.2.1.sql

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-3.4.0.2.0-3.4.0.2.1.sql','');


-- Relax unique constraint to include sort_order, in order
-- to avoid errors if an invoice includes several identical lines.

-- Drop the old version of the constraint if exists
create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
        select count(*) into v_count 
	from pg_constraint where lower(conname) = ''im_invoice_items_un'';
        if v_count = 0 then return 0; end if;

	alter table im_invoice_items 
	drop constraint im_invoice_items_un;

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


-- Add the new version of the constraint
alter table im_invoice_items 
add constraint im_invoice_items_un 
unique (item_name, invoice_id, project_id, sort_order, item_uom_id);


-- Update the link to the report to show included timesheet hours
update apm_parameter_values
set attr_value = '/intranet-reporting/timesheet-invoice-hours'
where parameter_id in (
	select	parameter_id
	from	apm_parameters
	where	package_key = 'intranet-invoices' and parameter_name = 'TimesheetInvoiceReport'
);


-- improved rounding (2 digits) invoice items
ALTER TABLE im_invoice_items ALTER COLUMN item_units TYPE numeric(12,2);
