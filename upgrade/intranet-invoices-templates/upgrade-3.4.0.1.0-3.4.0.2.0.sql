-- upgrade-3.4.0.1.0-3.4.0.2.0.sql

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-3.4.0.1.0-3.4.0.2.0.sql','');


-- Delete a single invoice (if we know its ID...)
create or replace function im_invoice__delete (integer)
returns integer as '
declare
        p_invoice_id alias for $1;      -- invoice_id
begin
        -- Erase the im_invoice_item associated with the id
        delete from     im_invoice_items
        where           invoice_id = p_invoice_id;

        -- Delete canned notes values
        delete from     im_dynfield_attr_multi_value
        where           object_id = p_invoice_id;

        -- Erase the invoice itself
        delete from     im_invoices
        where           invoice_id = p_invoice_id;

        -- Erase the CostItem
        PERFORM im_cost__delete(p_invoice_id);
        return 0;
end;' language 'plpgsql';

