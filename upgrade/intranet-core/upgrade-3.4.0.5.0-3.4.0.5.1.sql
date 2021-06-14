-- upgrade-3.4.0.5.0-3.4.0.5.1.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.5.0-3.4.0.5.1.sql','');


update im_categories set
	enabled_p = 'f'
where
	category = 'lightgreen' and
	category_type = 'Intranet Skin';


-- Add GIFs to menus

create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
        select count(*) into v_count from user_tab_columns
	where table_name = ''IM_MENUS'' and column_name = ''MENU_GIF_SMALL'';
        if v_count > 0 then return 0; end if;

	alter table im_menus add menu_gif_small text;
	alter table im_menus add menu_gif_medium text;
	alter table im_menus add menu_gif_large text;

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



-- Move all menus from "OpenACS" to "Admin"
update im_menus set
	parent_menu_id = (select menu_id from im_menus where label = 'admin')
where
	parent_menu_id = (select menu_id from im_menus where label = 'openacs');

-- Delete the OpenACS menu itself
select im_menu__delete((select menu_id from im_menus where label = 'openacs'));


select im_menu__delete((select menu_id from im_menus where label = 'admin_auth_authorities'));


-- Shorten a few menu names
update im_menus set name = 'LDAP' where name = 'LDAP Authentication';

-- Delete duplicated package manager
select im_menu__delete((select menu_id from im_menus where label = 'openacs_package_manager'));

update im_menus set sort_order =  100 where label = 'admin_home';
update im_menus set sort_order =  200 where label = 'openacs_api_doc';
update im_menus set sort_order =  300 where label = 'admin_auth_authorities';
update im_menus set sort_order =  400 where label = 'admin_backup';
update im_menus set sort_order =  450 where label = 'admin_flush';
update im_menus set sort_order =  500 where label = 'openacs_cache';
update im_menus set sort_order =  600 where label = 'admin_categories';
update im_menus set sort_order =  700 where label = 'admin_cost_centers';
update im_menus set sort_order =  800 where label = 'admin_cost_center_permissions';
update im_menus set sort_order =  900 where label = 'openacs_developer';
update im_menus set sort_order = 1000 where label = 'dynfield_admin';
update im_menus set sort_order = 1100 where label = 'admin_dynview';
update im_menus set sort_order = 1200 where label = 'admin_exchange_rates';
update im_menus set sort_order = 1400 where label = 'openacs_shell';
update im_menus set sort_order = 1500 where label = 'openacs_auth';
update im_menus set sort_order = 1600 where label = 'openacs_l10n';
update im_menus set sort_order = 1700 where label = 'material';
update im_menus set sort_order = 1800 where label = 'admin_menus';
update im_menus set sort_order = 1900 where label = 'admin_packages';
update im_menus set sort_order = 2000 where label = 'admin_parameters';
update im_menus set sort_order = 2100 where label = 'admin_components';
update im_menus set sort_order = 2300 where label = 'openacs_restart_server';
update im_menus set sort_order = 2400 where label = 'openacs_ds';
update im_menus set sort_order = 2500 where label = 'admin_survsimp';
update im_menus set sort_order = 2600 where label = 'openacs_sitemap';
update im_menus set sort_order = 2700 where label = 'software_updates';
update im_menus set sort_order = 2800 where label = 'admin_sysconfig';
update im_menus set sort_order = 2900 where label = 'admin_user_exits';
update im_menus set sort_order = 3000 where label = 'admin_usermatrix';
update im_menus set sort_order = 3050 where label = 'admin_profiles';
update im_menus set sort_order = 3100 where label = 'admin_workflow';


update im_menus set name = 'User Profiles' where label = 'admin_profiles';
update im_menus set name = 'Parameters' where label = 'admin_parameters';
update im_menus set name = 'Package Manager' where label = 'admin_packages';
update im_menus set name = 'Cache Flush' where label = 'admin_flush';