-- upgrade-5.0.2.5.0-5.0.2.5.1.sql
SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-5.0.2.5.0-5.0.2.5.1.sql','');


-- Delete a single invoice item, if we know its ID...
create or replace function im_invoice_item__delete (integer)
returns integer as $body$
declare
	p_invoice_item_id	alias for $1;
	v_object_exists_p	integer;
begin
	delete from 	im_invoice_items
	where		item_id = p_invoice_item_id;

	-- Compatibility with old version - skip if not yet object...
	select	count(*) into v_object_exists_p
	from	acs_objects
	where	object_id = p_invoice_item_id and object_type = 'im_invoice_item';
	IF v_object_exists_p = 1 THEN
		PERFORM acs_object__delete(p_invoice_item_id);
	END IF;

	return 0;
end; $body$ language 'plpgsql';


