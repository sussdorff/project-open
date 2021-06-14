SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.1.0.0.0-4.1.0.0.1.sql','');

create or replace function inline_1 ()
returns integer as '
declare
        v_menu                  integer;
        v_parent_menu    	integer;
        v_admins                integer;
	v_managers		integer;
	v_hr_managers		integer;
begin

    select group_id into v_admins from groups where group_name = ''P/O Admins'';
    select group_id into v_managers from groups where group_name = ''Senior Managers'';
    select group_id into v_hr_managers from groups where group_name = ''HR Managers'';

    select menu_id into v_parent_menu from im_menus where label=''timesheet2_absences'';

    v_menu := im_menu__new (
        null,                   -- p_menu_id
        ''im_menu'',		-- object_type
        now(),                  -- creation_date
        null,                   -- creation_user
        null,                   -- creation_ip
        null,                   -- context_id
        ''intranet-timesheet2'', -- package_name
        ''new-rwh'',  -- label
        ''Reduction in Working Hours'',  -- name
        ''/intranet-timesheet2/absences/new-rwh'', -- url
        70,                    -- sort_order
        v_parent_menu,           -- parent_menu_id
        ''[im_user_is_hr_p $user_id]''                   -- p_visible_tcl
    );

    PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
    PERFORM acs_permission__grant_permission(v_menu, v_managers, ''read'');
    PERFORM acs_permission__grant_permission(v_menu, v_hr_managers, ''read'');

    return 0;
end;' language 'plpgsql';
select inline_1 ();
drop function inline_1();

create or replace function inline_2()
returns void as
$$
begin

    perform im_component_plugin__delete(plugin_id) 
    from im_component_plugins 
    where plugin_name in ('Absence Cube','Graphical View of Absences','Absence Calendar','Calendar View of Absences','Absences List');

    -- Create a plugin for the absence cube
    perform im_component_plugin__new (
        null,				    -- plugin_id
        'im_component_plugin',	-- object_type
        now(),				    -- creation_date
        null,				    -- creation_user
        null,				    -- creation_ip
        null,				    -- context_id
        'Absence Cube',			-- plugin_name
        'intranet-timesheet2',	-- package_name
        'left',				    -- location
        '/intranet/users/view',	-- page_url
        null,				    -- view_name
        20,				        -- sort_order
        'im_absence_cube_component -user_selection [im_coalesce $user_id_from_search [auth::get_user_id]]'	-- component_tcl
    );

    -- Create a plugin for the absence cube
    perform im_component_plugin__new (
        null,				    -- plugin_id
        'im_component_plugin',	-- object_type
        now(),				    -- creation_date
        null,				    -- creation_user
        null,				    -- creation_ip
        null,				    -- context_id
        'Graphical View of Absences',			-- plugin_name
        'intranet-timesheet2',	-- package_name
        'top',				    -- location
        '/intranet-timesheet2/absences/index',	-- page_url
        null,				    -- view_name
        20,				        -- sort_order
        E'im_absence_cube_component \\
                       -absence_status_id $filter_status_id \\
                       -absence_type_id $org_absence_type_id \\
                       -timescale $timescale \\
                       -timescale_date $timescale_date \\
                       -user_selection $user_selection'	-- component_tcl
    );

    -- Create a plugin for the absence calendar for one user
    perform im_component_plugin__new (
        null,				    -- plugin_id
        'im_component_plugin',	-- object_type
        now(),				    -- creation_date
        null,				    -- creation_user
        null,				    -- creation_ip
        null,				    -- context_id
        'Absence Calendar',			-- plugin_name
        'intranet-timesheet2',	-- package_name
        'left',				    -- location
        '/intranet/users/view',	-- page_url
        null,				    -- view_name
        20,				        -- sort_order
        'im_absence_calendar_component -owner_id [im_coalesce $user_id_from_search [auth::get_user_id]] -year [clock format [clock seconds] -format "%Y"]'	-- component_tcl
    );



    -- Create a plugin for the absence calendar for one user
    perform im_component_plugin__new (
        null,				    -- plugin_id
        'im_component_plugin',	-- object_type
        now(),				    -- creation_date
        null,				    -- creation_user
        null,				    -- creation_ip
        null,				    -- context_id
        'Calendar View of Absences',			-- plugin_name
        'intranet-timesheet2',	-- package_name
        'top',				    -- location
        '/intranet-timesheet2/absences/index',	-- page_url
        null,				    -- view_name
        20,				        -- sort_order
        'im_absence_calendar_component -owner_id [im_coalesce $user_id_from_search $user_selection [auth::get_user_id]] -year [im_year_from_date $timescale_date]'	-- component_tcl
    );

    -- Create a plugin for the absence cube
    perform im_component_plugin__new (
        null,				    -- plugin_id
        'im_component_plugin',	-- object_type
        now(),				    -- creation_date
        null,				    -- creation_user
        null,				    -- creation_ip
        null,				    -- context_id
        'Absences List',		-- plugin_name
        'intranet-timesheet2',	-- package_name
        'bottom',				    -- location
        '/intranet-timesheet2/absences/index',	-- page_url
        null,				    -- view_name
        20,				        -- sort_order
        E'im_absence_list_component \\
                       -user_selection $user_selection \\
                       -absence_status_id $filter_status_id \\
                       -absence_type_id $org_absence_type_id \\
                       -timescale $timescale \\
                       -timescale_date $timescale_date \\
                       -order_by $order_by'-- component_tcl
    );

    perform acs_permission__grant_permission(
        plugin_id,
        (select group_id from groups where group_name = 'Employees'),
        'read')
    from im_component_plugins 
    where plugin_name in ('Absence Calendar','Calendar View of Absences','Absence Cube','Graphical View of Absences','Absences List')
    and package_name = 'intranet-timesheet2';

end;
$$ language 'plpgsql';
select inline_2();
drop function inline_2();

