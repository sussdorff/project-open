SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.1.0.0.1-4.1.0.0.2.sql','');

create or replace function inline_1 ()
returns integer as
$$
begin

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
        'im_absence_cube_component -user_selection $user_id'	-- component_tcl
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
        'im_absence_calendar_component -owner_id $user_id -year [clock format [clock seconds] -format "%Y"]'	-- component_tcl
    );

    return 0;
end;
$$ language 'plpgsql';
select inline_1 ();
drop function inline_1();

