SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.1.0.0.7-4.1.0.0.8.sql','');

-- -------------------------------------------------------
-- Create new Absence types for weekends
-- -------------------------------------------------------

CREATE OR REPLACE FUNCTION inline_0 () 
RETURNS INTEGER AS
$$
declare
begin

    perform im_category_new (16001, 'Requested or Active', 'Intranet Absence Status');
    perform im_category_hierarchy_new (16000, 16001);  -- Active <- Requested or Active
    perform im_category_hierarchy_new (16004, 16001);  -- Requested <- Requested or Active

    perform im_component_plugin__delete(plugin_id) 
    from im_component_plugins 
    where plugin_name in ('Absence Calendar');

    perform im_component_plugin__new (
        null,                               -- plugin_id
        'im_component_plugin',              -- object_type
        now(),                              -- creation_date
        null,                               -- creation_user
        null,                               -- creation_ip
        null,                               -- context_id
        'Absence Calendar',                 -- plugin_name
        'intranet-timesheet2',              -- package_name
        'left',                             -- location
        '/intranet/users/view',             -- page_url
        null,                               -- view_name
        20,                                 -- sort_order
        E'im_absence_calendar_component -owner_id [im_coalesce $user_id_from_search [auth::get_user_id]] -absence_status_id [im_user_absence_status_requested_or_active] -year [clock format [clock seconds] -format "%Y"]'     -- component_tcl
    );

    perform acs_permission__grant_permission(
        plugin_id,
        (select group_id from groups where group_name = 'Employees'),
        'read')
    from im_component_plugins 
    where plugin_name in ('Absence Calendar')
    and package_name = 'intranet-timesheet2';

    return 1;

end;
$$ LANGUAGE 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();

