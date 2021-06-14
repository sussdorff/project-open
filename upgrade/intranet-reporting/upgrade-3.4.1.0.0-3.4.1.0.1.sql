-- upgrade-3.4.1.0.0-3.4.1.0.1.sql

SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-3.4.1.0.0-3.4.1.0.1.sql','');



---------------------------------------------------------
-- Program-EVA
--

create or replace function inline_0 ()
returns integer as $body$
declare
	v_menu			integer;
	v_main_menu 		integer;
	v_employees		integer;
BEGIN
	select group_id into v_employees from groups where group_name = 'Employees';

	select menu_id into v_main_menu
	from im_menus where label = 'reporting';

	v_menu := im_menu__new (
		null,					-- p_menu_id
		'im_menu', 				-- object_type
		now(),					-- creation_date
		null,					-- creation_user
		null,					-- creation_ip
		null,					-- context_id
		'intranet-reporting',			-- package_name
		'reporting-program-portfolio',		-- label
		'Program and Portfolio',		-- name
		'/intranet-reporting/',			-- url
		350,					-- sort_order
		v_main_menu,				-- parent_menu_id
		null					-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');

	v_menu := im_menu__new (
		null,					-- p_menu_id
		'im_menu',				-- object_type
		now(),					-- creation_date
		null,					-- creation_user
		null,					-- creation_ip
		null,					-- context_id
		'intranet-reporting',			-- package_name
		'reporting-program-eva',		-- label
		'Program Earned Value Analysis',		-- name
		'/intranet-reporting/program-eva?',	-- url
		100,					-- sort_order
		v_menu,					-- parent_menu_id
		null					-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');

	return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


