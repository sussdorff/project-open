-- upgrade-3.3.1.1.0-3.3.1.2.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.3.1.1.0-3.3.1.2.0.sql','');

\i upgrade-3.0.0.0.first.sql



-- Add "require_manual_login" privilege
--
SELECT acs_privilege__create_privilege(
	'require_manual_login',
	'Require manual login - dont allow auto-login',
	'Require manual login - dont allow auto-login'
);
SELECT acs_privilege__add_child('admin', 'require_manual_login');

select im_priv_create('require_manual_login','P/O Admins');
select im_priv_create('require_manual_login','Senior Managers');
select im_priv_create('require_manual_login','Project Managers');
select im_priv_create('require_manual_login','Accounting');
-- select im_priv_create('require_manual_login','Employees');


-- Add a "rounding factor" to currencies.
-- This factor is 100 (2 digits) for EUR, USD, GBP etc,
-- but 20 for CHF (rounding on 0.05 CHF)

create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from user_tab_columns
	where table_name = ''CURRENCY_CODES'' and column_name = ''ROUNDING_FACTOR'';
	IF v_count > 0 THEN return 0; END IF;

	alter table currency_codes
	add rounding_factor integer default 100;

	update currency_codes set rounding_factor = 20 where iso=''CHF'';

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



