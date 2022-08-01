-- upgrade-5.0.2.5.4-5.0.2.5.5.sql
SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-5.0.2.5.4-5.0.2.5.5.sql','');


-- Delete a single invoice item, if we know its ID...
create or replace function inline_0 ()
returns integer as $body$
declare
	v_exists_p	integer;
begin
	select count(*) into v_exists_p from pg_class where relname = 'im_invoice_items_invoice_idx';
	IF v_exists_p > 0 THEN return 1; END IF;

	create index im_invoice_items_invoice_idx on im_invoice_items(invoice_id);
	return 0;
end; $body$ language 'plpgsql';
select inline_0();
drop function inline_0();

