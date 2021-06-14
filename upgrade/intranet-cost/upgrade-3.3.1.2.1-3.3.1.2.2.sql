-- upgrade-3.3.1.2.1-3.3.1.2.2.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-3.3.1.2.1-3.3.1.2.2.sql','');

-- drop constraint if exists...
create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from pg_trigger
	where lower(tgname) = ''im_payments_audit_tr'';
	IF v_count = 0 THEN return 0; END IF;

	drop trigger im_payments_audit_tr on im_payments;

	return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();


create trigger im_payments_audit_tr
after update or delete
on im_payments
for each row execute procedure im_payments_audit_tr();

