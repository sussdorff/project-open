-- upgrade-4.1.0.0.1-4.1.0.0.2.sql

SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-4.1.0.0.1-4.1.0.0.2.sql','');


---------------------------------------------------------
-- Budget Check for Main Project
--

create or replace function inline_0 ()
returns integer as $body$
declare
	v_menu			integer;
	v_main_menu 		integer;
	v_accounting		integer;
	v_senman		integer;
BEGIN
	select group_id into v_senman from groups where group_name = 'Senior Managers';
	select group_id into v_accounting from groups where group_name = 'Accounting';

	select menu_id into v_main_menu	from im_menus
	where label = 'reporting-timesheet';

	v_menu := im_menu__new (
		null,						-- p_menu_id
		'im_menu',					-- object_type
		now(),						-- creation_date
		null,						-- creation_user
		null,						-- creation_ip
		null,						-- context_id
		'intranet-reporting',				-- package_name
		'timesheet-days-per-project-and-month',	-- label
		'Timesheet Days per Month',			-- name
		'/intranet-reporting/timesheet-days-per-project-and-month?',	-- url
		190,						-- sort_order
		v_main_menu,					-- parent_menu_id
		null						-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_senman, 'read');
	PERFORM acs_permission__grant_permission(v_menu, v_accounting, 'read');

	return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

