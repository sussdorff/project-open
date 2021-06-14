-- /packages/intranet-cost/sql/postgres/upgrade/upgrade-3.1.4.0.0-3.2.0.0.0.sql
--
-- Cost Core
-- 040207 frank.bergmann@project-open.com
--
-- Copyright (C) 2004 - 2009 ]project-open[
--
-- All rights including reserved. To inquire license terms please 
-- refer to http://www.project-open.com/modules/<module-key>

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-3.1.4.0.0-3.2.0.0.0.sql','');


\i ../../../../intranet-core/sql/postgresql/upgrade/upgrade-3.0.0.0.first.sql


-------------------------------------------------------------
-- 
---------------------------------------------------------

-- Add cache fields for expenses


create or replace function inline_0 ()
returns integer as '
declare
	v_count			integer;
begin
        select	count(*) into v_count from user_tab_columns
	where	table_name = ''IM_PROJECTS'' and column_name = ''COST_EXPENSE_PLANNED_CACHE'';
	if v_count > 0 then return 0; end if;

	alter table im_projects add     cost_expense_planned_cache	numeric(12,2);
	alter table im_projects alter	cost_expense_planned_cache	set default 0;

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count			integer;
begin
        select	count(*) into v_count from user_tab_columns
	where	table_name = ''IM_PROJECTS'' and column_name = ''COST_EXPENSE_LOGGED_CACHE'';
	if v_count > 0 then return 0; end if;

	alter table im_projects add     cost_expense_logged_cache	numeric(12,2);
	alter table im_projects alter	cost_expense_logged_cache	set default 0;

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



SELECT IM_CATEGORY_NEW (3720, 'Expense Item','Intranet Cost Type');
SELECT IM_CATEGORY_NEW (3722, 'Expense Report','Intranet Cost Type');
SELECT IM_CATEGORY_NEW (3724, 'Delivery Note','Intranet Cost Type');


create or replace function inline_0 ()
returns integer as '
declare
	v_count			integer;
begin
        select	count(*) into v_count from pg_trigger
	where	lower(tgname) = ''im_payments_audit_tr'';
	if v_count = 0 then return 0; end if;

	drop trigger im_payments_audit_tr on im_payments;

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count			integer;
begin
        select	count(*) into v_count from pg_proc
	where	lower(proname) = ''im_payments_audit_tr'';
	if v_count = 0 then return 0; end if;

	drop function im_payments_audit_tr();

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




create or replace function im_payments_audit_tr () returns opaque as '
begin
        insert into im_payments_audit (
               payment_id,
               cost_id,
               company_id,
               provider_id,
               received_date,
               start_block,
               payment_type_id,
               payment_status_id,
               amount,
               currency,
               note,
               last_modified,
               last_modifying_user,
               modified_ip_address
        ) values (
               old.payment_id,
               old.cost_id,
               old.company_id,
               old.provider_id,
               old.received_date,
               old.start_block,
               old.payment_type_id,
               old.payment_status_id,
               old.amount,
               old.currency,
               old.note,
               old.last_modified,
               old.last_modifying_user,
               old.modified_ip_address
        );
        return new;
end;' language 'plpgsql';



-- 060720 Frank Bergmann: Does work!
--
create trigger im_payments_audit_tr
before update or delete on im_payments
for each row execute procedure im_payments_audit_tr ();

