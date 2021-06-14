-- upgrade-4.0.3.0.4-4.0.3.0.5.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.0.4-4.0.3.0.5.sql','');


-- -----------------------------------------------------
-- Consistency Checks
-- -----------------------------------------------------

create or replace function inline_1 ()
returns integer as $body$
declare
	v_menu			integer;
	v_admin_menu		integer;
	v_admins		integer;
begin
	select group_id into v_admins from groups where group_name = 'P/O Admins';

	select menu_id into v_admin_menu
	from im_menus where label='admin';

	v_menu := im_menu__new (
		null,				-- p_menu_id
		'im_menu',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		'intranet-core',		-- package_name
		'admin_consistency_check',	-- label
		'Consistency Checks',		-- name
		'/intranet/admin/consistency-check',	-- url
		650,				-- sort_order
		v_admin_menu,			-- parent_menu_id
		null				-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_admins, 'read');
	return 0;
end;$body$ language 'plpgsql';
select inline_1 ();
drop function inline_1();



-- fix missing image on menus
update	im_menus 
set	menu_gif_small = 'arrow_right'
where	menu_gif_small is null and
	label like 'admin_%';




-- Set sort_orders
--

update im_menus set sort_order =  100, menu_gif_small = 'arrow_right' where label = 'admin_home';
update im_menus set sort_order =  200, menu_gif_small = 'arrow_right' where label = 'openacs_api_doc';
update im_menus set sort_order =  300, menu_gif_small = 'arrow_right' where label = 'admin_auth_authorities';
update im_menus set sort_order =  400, menu_gif_small = 'arrow_right' where label = 'admin_backup';
update im_menus set sort_order =  450, menu_gif_small = 'arrow_right' where label = 'admin_flush';
update im_menus set sort_order =  500, menu_gif_small = 'arrow_right' where label = 'openacs_cache';
update im_menus set sort_order =  600, menu_gif_small = 'arrow_right' where label = 'admin_categories';
update im_menus set sort_order =  650, menu_gif_small = 'arrow_right' where label = 'admin_consistency_check';
update im_menus set sort_order =  700, menu_gif_small = 'arrow_right' where label = 'admin_cost_centers';
update im_menus set sort_order =  800, menu_gif_small = 'arrow_right' where label = 'admin_cost_center_permissions';
update im_menus set sort_order =  900, menu_gif_small = 'arrow_right' where label = 'openacs_developer';
update im_menus set sort_order = 1000, menu_gif_small = 'arrow_right' where label = 'dynfield_admin';
update im_menus set sort_order = 1100, menu_gif_small = 'arrow_right' where label = 'admin_dynview';
update im_menus set sort_order = 1200, menu_gif_small = 'arrow_right' where label = 'admin_exchange_rates';
update im_menus set sort_order = 1400, menu_gif_small = 'arrow_right' where label = 'openacs_shell';
update im_menus set sort_order = 1500, menu_gif_small = 'arrow_right' where label = 'openacs_auth';
update im_menus set sort_order = 1600, menu_gif_small = 'arrow_right' where label = 'openacs_l10n';
update im_menus set sort_order = 1650, menu_gif_small = 'arrow_right' where label = 'mail_import';
update im_menus set sort_order = 1700, menu_gif_small = 'arrow_right' where label = 'material';
update im_menus set sort_order = 1800, menu_gif_small = 'arrow_right' where label = 'admin_menus';
update im_menus set sort_order = 1900, menu_gif_small = 'arrow_right' where label = 'admin_packages';
update im_menus set sort_order = 2000, menu_gif_small = 'arrow_right' where label = 'admin_parameters';
update im_menus set sort_order = 2100, menu_gif_small = 'arrow_right' where label = 'admin_components';
update im_menus set sort_order = 2300, menu_gif_small = 'arrow_right' where label = 'openacs_restart_server';
update im_menus set sort_order = 2400, menu_gif_small = 'arrow_right' where label = 'openacs_ds';
update im_menus set sort_order = 2500, menu_gif_small = 'arrow_right' where label = 'admin_survsimp';
update im_menus set sort_order = 2600, menu_gif_small = 'arrow_right' where label = 'openacs_sitemap';
update im_menus set sort_order = 2700, menu_gif_small = 'arrow_right' where label = 'software_updates';
update im_menus set sort_order = 2800, menu_gif_small = 'arrow_right' where label = 'admin_sysconfig';
update im_menus set sort_order = 2850, menu_gif_small = 'arrow_right' where label = 'update_server';
update im_menus set sort_order = 2900, menu_gif_small = 'arrow_right' where label = 'admin_user_exits';
update im_menus set sort_order = 3000, menu_gif_small = 'arrow_right' where label = 'admin_usermatrix';
update im_menus set sort_order = 3050, menu_gif_small = 'arrow_right' where label = 'admin_profiles';
update im_menus set sort_order = 3100, menu_gif_small = 'arrow_right' where label = 'admin_workflow';
