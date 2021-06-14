-- upgrade-3.5.0.0.0-3.5.0.0.1.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-workflow/sql/postgresql/upgrade/upgrade-4.0.5.0.6-4.0.5.0.7.sql','');


create or replace function inline_1 ()
returns integer as $body$
declare
	v_menu			integer;
	v_parent_menu		integer;
	v_employees		integer;
	v_count			integer;
begin
	select group_id into v_employees from groups where group_name = 'Employees';
	select menu_id into v_parent_menu from im_menus where label='reporting-timesheet';

	select count(*) into v_count
	from im_menus where label = 'reporting-timesheet-unsubmitted-hours';
	IF v_count > 0 THEN return 0; END IF;

	v_menu := im_menu__new (
		null,								-- p_menu_id
		'im_menu',							-- object_type
		now(),								-- creation_date
		null,								-- creation_user
		null,								-- creation_ip
		null,								-- context_id
		'intranet-timesheet2-workflow',					-- package_name
		'reporting-timesheet-unsubmitted-hours',			-- label
		'Timesheet Workflow - Unconfirmed Hours',			-- name
		'/intranet-timesheet2-workflow/reports/unsubmitted-hours.tcl?',	-- url
		180,								-- sort_order
		v_parent_menu,							-- parent_menu_id
		null								-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');

	return 0;
end;$body$ language 'plpgsql';
select inline_1 ();
drop function inline_1();

