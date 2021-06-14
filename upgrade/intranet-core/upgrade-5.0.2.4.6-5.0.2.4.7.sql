-- upgrade-5.0.2.4.6-5.0.2.4.7.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.2.4.6-5.0.2.4.7.sql','');


SELECT im_menu__new (
                null, 'im_menu', now(), null, null, null,
                'intranet-core',                                        -- package_name
                'add_tasks_from_template',                              -- label
                'Add Tasks from Template',                              -- name
                '/intranet/projects/add-tasks-from-template',
                100,                                                    -- sort_order
                (select menu_id from im_menus where label = 'projects_admin'),            -- parent_menu_id
                null
);
SELECT acs_permission__grant_permission(
        (select menu_id from im_menus where label = 'master_data'),
        (select group_id from groups where group_name = 'Employees'),
        'read'
);

