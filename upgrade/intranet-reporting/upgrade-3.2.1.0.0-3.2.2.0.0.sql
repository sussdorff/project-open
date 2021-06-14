-- upgrade-3.2.1.0.0-3.2.2.0.0.sql

SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-3.2.1.0.0-3.2.2.0.0.sql','');


-- Copyright (c) 2003-2006 ]project-open[
--
-- All rights reserved. Please check
-- http://www.project-open.com/license/ for details.
--
-- @author frank.bergmann@project-open.com



---------------------------------------------------------
-- Finance - Income Statement
--

create or replace function inline_0 ()
returns integer as '
declare
	v_menu			integer;
	v_main_menu 		integer;
	v_employees		integer;
	v_accounting		integer;
	v_senman		integer;
	v_customers		integer;
	v_freelancers		integer;
	v_proman		integer;
	v_admins		integer;
	v_reg_users		integer;

	v_count			integer;
BEGIN
	select group_id into v_admins from groups where group_name = ''P/O Admins'';
	select group_id into v_senman from groups where group_name = ''Senior Managers'';
	select group_id into v_proman from groups where group_name = ''Project Managers'';
	select group_id into v_accounting from groups where group_name = ''Accounting'';
	select group_id into v_employees from groups where group_name = ''Employees'';
	select group_id into v_customers from groups where group_name = ''Customers'';
	select group_id into v_freelancers from groups where group_name = ''Freelancers'';
	select group_id into v_reg_users from groups where group_name = ''Registered Users'';

	select menu_id into v_main_menu from im_menus where label=''reporting-finance'';

	select menu_id into v_count from im_menus
	where label = ''reporting-finance-income-statement'';
	IF v_count != 0 THEN return 0; END IF;

	v_menu := im_menu__new (
		null,			-- p_menu_id
		''im_menu'',		-- object_type
		now(),			-- creation_date
		null,			-- creation_user
		null,			-- creation_ip
		null,			-- context_id
		''intranet-reporting'', -- package_name
		''reporting-finance-income-statement'',		-- label
		''Finance Income Statement'',				-- name
		''/intranet-reporting/finance-income-statement'', -- url
		60,			-- sort_order
		v_main_menu,		-- parent_menu_id
		null			-- p_visible_tcl
	);
	PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
	PERFORM acs_permission__grant_permission(v_menu, v_senman, ''read'');
	PERFORM acs_permission__grant_permission(v_menu, v_accounting, ''read'');
	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



---------------------------------------------------------
-- Finance - Expenses
--

create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_main_menu 		integer;

	-- Groups
	v_employees		integer;
	v_accounting		integer;
	v_senman		integer;
	v_customers		integer;
	v_freelancers		integer;
	v_proman		integer;
	v_admins		integer;
	v_reg_users		integer;

	v_count			integer;
BEGIN
	select group_id into v_admins from groups where group_name = ''P/O Admins'';
	select group_id into v_senman from groups where group_name = ''Senior Managers'';
	select group_id into v_proman from groups where group_name = ''Project Managers'';
	select group_id into v_accounting from groups where group_name = ''Accounting'';
	select group_id into v_employees from groups where group_name = ''Employees'';
	select group_id into v_customers from groups where group_name = ''Customers'';
	select group_id into v_freelancers from groups where group_name = ''Freelancers'';
	select group_id into v_reg_users from groups where group_name = ''Registered Users'';

	select menu_id into v_main_menu from im_menus
	where label=''reporting-finance'';

	select menu_id into v_count from im_menus
	where label = ''reporting-finance-expenses'';
	IF v_count != 0 THEN return 0; END IF;

	v_menu := im_menu__new (
		null,			-- p_menu_id
		''im_menu'',		-- object_type
		now(),			-- creation_date
		null,			-- creation_user
		null,			-- creation_ip
		null,			-- context_id
		''intranet-reporting'', -- package_name
		''reporting-finance-expenses'',		-- label
		''Finance Expenses'',				-- name
		''/intranet-reporting/finance-expenses'', -- url
		70,			-- sort_order
		v_main_menu,		-- parent_menu_id
		null			-- p_visible_tcl
	);
	PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
	PERFORM acs_permission__grant_permission(v_menu, v_senman, ''read'');
	PERFORM acs_permission__grant_permission(v_menu, v_accounting, ''read'');
	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


---------------------------------------------------------
-- Finance - Trans PM Productivity
--

create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_main_menu 		integer;

	-- Groups
	v_employees		integer;
	v_accounting		integer;
	v_senman		integer;
	v_customers		integer;
	v_freelancers		integer;
	v_proman		integer;
	v_admins		integer;
	v_reg_users		integer;

	v_count			integer;
BEGIN
	select group_id into v_admins from groups where group_name = ''P/O Admins'';
	select group_id into v_senman from groups where group_name = ''Senior Managers'';
	select group_id into v_proman from groups where group_name = ''Project Managers'';
	select group_id into v_accounting from groups where group_name = ''Accounting'';
	select group_id into v_employees from groups where group_name = ''Employees'';
	select group_id into v_customers from groups where group_name = ''Customers'';
	select group_id into v_freelancers from groups where group_name = ''Freelancers'';
	select group_id into v_reg_users from groups where group_name = ''Registered Users'';

	select menu_id into v_main_menu from im_menus
	where label=''reporting-finance'';

	select menu_id into v_count from im_menus
	where label = ''reporting-finance-trans-pm-productivity'';
	IF v_count != 0 THEN return 0; END IF;

	v_menu := im_menu__new (
		null,			-- p_menu_id
		''im_menu'',		-- object_type
		now(),			-- creation_date
		null,			-- creation_user
		null,			-- creation_ip
		null,			-- context_id
		''intranet-reporting'', -- package_name
		''reporting-finance-trans-pm-productivity'',		-- label
		''Translation Project Manager Productivity'',				-- name
		''/intranet-reporting/finance-trans-pm-productivity'', -- url
		80,			-- sort_order
		v_main_menu,		-- parent_menu_id
		null			-- p_visible_tcl
	);
	PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
	PERFORM acs_permission__grant_permission(v_menu, v_senman, ''read'');
	PERFORM acs_permission__grant_permission(v_menu, v_accounting, ''read'');
	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



---------------------------------------------------------
-- Users - Contact Report
--

create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_main_menu 		integer;

	-- Groups
	v_employees		integer;
	v_accounting		integer;
	v_senman		integer;
	v_customers		integer;
	v_freelancers		integer;
	v_proman		integer;
	v_admins		integer;
	v_reg_users		integer;

	v_count			integer;
BEGIN
	select group_id into v_admins from groups where group_name = ''P/O Admins'';
	select group_id into v_senman from groups where group_name = ''Senior Managers'';
	select group_id into v_proman from groups where group_name = ''Project Managers'';
	select group_id into v_accounting from groups where group_name = ''Accounting'';
	select group_id into v_employees from groups where group_name = ''Employees'';
	select group_id into v_customers from groups where group_name = ''Customers'';
	select group_id into v_freelancers from groups where group_name = ''Freelancers'';
	select group_id into v_reg_users from groups where group_name = ''Registered Users'';

	select menu_id into v_main_menu from im_menus
	where label=''reporting-other'';

	select menu_id into v_count from im_menus
	where label = ''reporting-user-contacts'';
	IF v_count != 0 THEN return 0; END IF;

	v_menu := im_menu__new (
		null,			-- p_menu_id
		''im_menu'',		-- object_type
		now(),			-- creation_date
		null,			-- creation_user
		null,			-- creation_ip
		null,			-- context_id
		''intranet-reporting'', -- package_name
		''reporting-user-contacts'',		-- label
		''Users and Contacts'',				-- name
		''/intranet-reporting/user-contacts'', -- url
		20,			-- sort_order
		v_main_menu,		-- parent_menu_id
		null			-- p_visible_tcl
	);
	PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
	PERFORM acs_permission__grant_permission(v_menu, v_senman, ''read'');
	PERFORM acs_permission__grant_permission(v_menu, v_accounting, ''read'');
	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


