-- upgrade-3.2.5.0.0-3.2.6.0.0.sql

SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-3.2.5.0.0-3.2.6.0.0.sql','');


-- Project WF Display
--
SELECT im_component_plugin__new (
        null,                           -- plugin_id
        'im_component_plugin',                   -- object_type
        now(),                          -- creation_date
        null,                           -- creation_user
        null,                           -- creation_ip
        null,                           -- context_id
        'Project Workflow Graph',       -- plugin_name
        'intranet-workflow',            -- package_name
        'right',                        -- location
        '/intranet/projects/view',     -- page_url
        null,                           -- view_name
        20,                              -- sort_order
        'im_workflow_graph_component -object_id $project_id'
);


-- Project WF Journal
--
SELECT im_component_plugin__new (
        null,                           -- plugin_id
        'im_component_plugin',                   -- object_type
        now(),                          -- creation_date
        null,                           -- creation_user
        null,                           -- creation_ip
        null,                           -- context_id
        'Project Workflow Journal',     -- plugin_name
        'intranet-workflow',            -- package_name
        'bottom',                       -- location
        '/intranet/projects/view',      -- page_url
        null,                           -- view_name
        60,                             -- sort_order
        'im_workflow_journal_component -object_id $project_id'
);



