-- upgrade-5.0.2.4.1-5.0.2.4.2.sql
SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-5.0.2.4.1-5.0.2.4.2.sql','');



create or replace function inline_0 ()
returns integer as $body$
declare
	-- Menu IDs
	v_menu			integer;
	v_main_menu 		integer;
	v_reporting_menu 	integer;
	v_hr_menu		integer;

	-- Groups
	v_employees		integer;
	v_accounting		integer;
	v_senman		integer;
	v_proman		integer;
BEGIN
	select group_id into v_senman from groups where group_name = 'Senior Managers';
	select group_id into v_proman from groups where group_name = 'Project Managers';
	select group_id into v_accounting from groups where group_name = 'Accounting';
	select group_id into v_employees from groups where group_name = 'Employees';

	select menu_id into v_main_menu from im_menus where label='main';
	select menu_id into v_reporting_menu from im_menus where label='reporting';
	
	v_menu := im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-reporting', 				-- package_name
		'reporting-hr', 				-- label
		'Human Resources',				-- name
		'/intranet-reporting/', 			-- url
		80,						-- sort_order
		v_reporting_menu,				-- parent_menu_id
		null						-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_senman, 'read');
	PERFORM acs_permission__grant_permission(v_menu, v_proman, 'read');
	PERFORM acs_permission__grant_permission(v_menu, v_accounting, 'read');
	PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');

	return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as $body$
declare
	-- Menu IDs
	v_menu			integer;
	v_hr_menu		integer;

	-- Groups
	v_accounting		integer;
	v_senman		integer;
	v_hr			integer;
BEGIN
	select group_id into v_senman from groups where group_name = 'Senior Managers';
	select group_id into v_accounting from groups where group_name = 'Accounting';
	select group_id into v_hr from groups where group_name = 'HR Managers';

	select menu_id into v_hr_menu from im_menus where label='reporting-hr';
	
	v_menu := im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-reporting', 				-- package_name
		'reporting-hr-vacation-balance', 		-- label
		'HR - Vacation Balance',			-- name
		'/intranet-reporting/hr-vacation-balance',	-- url
		100,						-- sort_order
		v_hr_menu,					-- parent_menu_id
		null						-- p_visible_tcl
	);

	IF v_senman is not null THEN PERFORM acs_permission__grant_permission(v_menu, v_senman, 'read'); END IF;
	IF v_accounting is not null THEN PERFORM acs_permission__grant_permission(v_menu, v_accounting, 'read'); END IF;
	IF v_hr is not null THEN PERFORM acs_permission__grant_permission(v_menu, v_hr, 'read'); END IF;

	-- Update some other HR reports
	update im_menus set
		name = 'HR - Users & Contact Information',
		parent_menu_id = v_hr_menu
	where label = 'reporting-user-contacts';

	update im_menus set
		name = 'HR - Groups',
		parent_menu_id = v_hr_menu
	where label = 'groups';

	update im_menus set
		name = 'HR - Recent Registrations',
		parent_menu_id = v_hr_menu
	where label = 'recent_registrations';


	return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

