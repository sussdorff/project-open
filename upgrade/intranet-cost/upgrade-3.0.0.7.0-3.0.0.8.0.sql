-- upgrade-3.0.0.7.0-3.0.0.8.0.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-3.0.0.7.0-3.0.0.8.0.sql','');


-- Show the finance component (summary view) in a projects "Summary" page
--
select  im_component_plugin__new (
        null,                            -- plugin_id
        'im_component_plugin',                    -- object_type
        now(),                           -- creation_date
        null,                            -- creation_user
        null,                            -- creation_ip
        null,                            -- context_id

        'Project Finance Summary Component',     -- plugin_name
        'intranet-cost',                 -- package_name
        'left',                  -- location
        '/intranet/projects/view',       -- page_url
        null,                            -- view_name
        80,                              -- sort_order
        'im_costs_project_finance_component -show_details_p 0 $user_id $project_id'  -- component_tcl
    );




