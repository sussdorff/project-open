-- upgrade-5.0.0.0.2-5.0.0.0.3.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.0.0.2-5.0.0.0.3.sql','');


CREATE OR REPLACE FUNCTION inline_1 ()
RETURNS INTEGER AS $BODY$
DECLARE
        v_plugin_id             INTEGER;
        v_hr_group_id     	INTEGER;
BEGIN

        SELECT group_id INTO v_hr_group_id FROM groups WHERE group_name = 'HR Managers';

        SELECT  im_component_plugin__new (
        NULL,                           -- plugin_id
        'acs_object',                   -- object_type
        now(),                          -- creation_date
        NULL,                           -- creation_user
        NULL,                           -- creation_ip
        NULL,                           -- context_id
        'Last Projects',   -- plugin_name
        'intranet-core',                -- package_name
        'right',                        -- location
        '/intranet/users/view',      -- page_url
        NULL,                           -- view_name
        20,                             -- sort_order
        'im_biz_object_related_objects_component -show_projects_only 1 -include_membership_rels_p 1 -hide_rel_name_p 1 -hide_object_chk_p 1 -hide_direction_pretty_p 1 -hide_object_type_pretty_p 1 -object_id $user_id -sort_order "" -suppress_invalid_objects_p 1'    -- component_tcl
        ) INTO v_plugin_id;

        -- Set title
        UPDATE im_component_plugins SET title_tcl = 'lang::message::lookup "" intranet-core.LastProjects "Last Projects"' WHERE plugin_id = v_plugin_id;

        -- Permissions
        PERFORM im_grant_permission(v_plugin_id, v_hr_group_id, 'read');

        RETURN 0;

END;$BODY$ LANGUAGE 'plpgsql';
SELECT inline_1 ();
DROP FUNCTION inline_1();


CREATE OR REPLACE FUNCTION inline_1 ()
RETURNS INTEGER AS $BODY$
DECLARE
        v_plugin_id             INTEGER;
        v_hr_group_id           INTEGER;
BEGIN

        SELECT group_id INTO v_hr_group_id FROM groups WHERE group_name = 'HR Managers';

        SELECT  im_component_plugin__new (
        NULL,                           -- plugin_id
        'acs_object',                   -- object_type
        now(),                          -- creation_date
        NULL,                           -- creation_user
        NULL,                           -- creation_ip
        NULL,                           -- context_id
        'Customers worked for',   	-- plugin_name
        'intranet-core',                -- package_name
        'right',                        -- location
        '/intranet/users/view',      	-- page_url
        NULL,                           -- view_name
        20,                             -- sort_order
        'im_biz_object_related_objects_component -show_companies_only 1 -include_membership_rels_p 1 -hide_rel_name_p 1 -hide_object_chk_p 1 -hide_direction_pretty_p 1 -hide_object_type_pretty_p 1 -object_id $user_id -sort_order "o.object_name" -suppress_invalid_objects_p 1'    -- component_tcl
        ) INTO v_plugin_id;

        -- Set title
        UPDATE im_component_plugins SET title_tcl = 'lang::message::lookup "" intranet-core.CustomersWorkedFor "Customers worked for:"' WHERE plugin_id = v_plugin_id;

        -- Permissions
        PERFORM im_grant_permission(v_plugin_id, v_hr_group_id, 'read');

        RETURN 0;

END;$BODY$ LANGUAGE 'plpgsql';
SELECT inline_1 ();
DROP FUNCTION inline_1();
