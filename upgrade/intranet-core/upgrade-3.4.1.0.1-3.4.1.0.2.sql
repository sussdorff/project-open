-- upgrade-3.4.1.0.1-3.4.1.0.2.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.1.0.1-3.4.1.0.2.sql','');

-- -----------------------------------------------------
-- Additional Menus for the ProjectListPage
-- -----------------------------------------------------

create or replace function inline_1 ()
returns integer as $body$
declare
	v_menu			integer;
	v_projects_menu		integer;
	v_employees		integer;
begin
	select group_id into v_employees from groups where group_name = 'Employees';

	select menu_id into v_projects_menu
	from im_menus where label = 'projects';

	v_menu := im_menu__new (
		null,					-- p_menu_id
		'im_menu',				-- object_type
		now(),					-- creation_date
		null,					-- creation_user
		null,					-- creation_ip
		null,					-- context_id
		'intranet-core',			-- package_name
		'projects_profit_loss',			-- label
		'Profit &amp; Loss',			-- name
		'/intranet/projects/index?view_name=project_costs', -- url
		-10,					-- sort_order
		v_projects_menu,			-- parent_menu_id
		null					-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');
	return 0;
end;$body$ language 'plpgsql';
select inline_1 ();
drop function inline_1();


-- Disable the old menu
update im_menus set enabled_p = 'f'
where label = 'projects_admin_gantt_resources';
