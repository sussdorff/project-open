-- upgrade-5.0.2.5.5-5.0.2.5.6.sql
SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-5.0.2.5.5-5.0.2.5.6.sql','');


create or replace function im_invoice_item__name (integer)
returns varchar as $body$
declare
	p_invoice_item_id alias for $1;
	v_name	varchar;
begin
	select	item_name
	into	v_name
	from	im_invoice_items
	where	item_id = p_invoice_item_id;

	return v_name;
end; $body$ language 'plpgsql';

