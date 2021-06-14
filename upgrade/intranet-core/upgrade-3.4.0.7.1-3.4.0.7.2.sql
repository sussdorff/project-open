-- upgrade-3.4.0.7.1-3.4.0.7.2.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.7.1-3.4.0.7.2.sql','');



-- -----------------------------------------------------
-- Update the Localization Admin link so that the 
-- Context Help works correctly (thanks Richard!)
-- -----------------------------------------------------

update im_menus set url = '/acs-lang/admin/' where url = '/acs-lang/admin';



-- -----------------------------------------------------
-- DynField Sub-Menus
-- -----------------------------------------------------

create or replace function inline_1 ()
returns integer as '
declare
	v_menu			integer;
	v_admin_menu		integer;
	v_employees		integer;
begin
	select group_id into v_employees from groups where group_name = ''Employees'';
	select menu_id into v_admin_menu from im_menus where label=''dynfield_admin'';

	v_menu := im_menu__new (
		null,				-- p_menu_id
		''im_menu'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-dynfield'',		-- package_name
		''dynfield_object_types'',	-- label
		''Object Types'',		-- name
		''/intranet-dynfield/object-types?'',	-- url
		100,				-- sort_order
		v_admin_menu,			-- parent_menu_id
		null				-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_employees, ''read'');
	return 0;
end;' language 'plpgsql';
-- select inline_1 ();
drop function inline_1();
