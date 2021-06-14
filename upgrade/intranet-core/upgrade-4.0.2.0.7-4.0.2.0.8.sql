-- upgrade-4.0.2.0.7-4.0.2.0.8.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.2.0.7-4.0.2.0.8.sql','');


update im_menus
set enabled_p = 'f'
where label in (
	'openacs_cache',
	'admin_flush',
	'openacs_api_doc',
	'openacs_ds',
	'openacs_sitemap',
	'admin_sysconfig',
	'admin_user_exits',
	'selectors_admin',
	'admin_home',
	'openacs_developer',
	'openacs_shell',
	'openacs_auth',
	'openacs_l10n'
);




SELECT im_menu__new (
	null,						-- p_menu_id
	'im_menu',					-- object_type
	now(),						-- creation_date
	null,						-- creation_user
	null,						-- creation_ip
	null,						-- context_id
	'intranet-core',				-- package_name
	'project_admin_filter_advanced',		-- label
	'Advanced Filtering',				-- name
	'/intranet/projects/index?filter_advanced_p=1',	-- url
	70,						-- sort_order
	(select menu_id from im_menus where label = 'projects_admin'),
	null						-- p_visible_tcl
);

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'project_admin_filter_advanced'), 
	(select group_id from groups where group_name = 'Employees'),
	'read'
);


-- Fix timesheet home component
update im_component_plugins
set component_tcl = 'im_timesheet_task_list_component  -max_entries_per_page 20 -view_name im_timesheet_task_list_short -restrict_to_mine_p mine'
where component_tcl = 'im_timesheet_task_list_component  -max_entries_per_page 20 -view_name im_timesheet_task_list_short -restrict_to_status_id 9600 -restrict_to_mine_p mine';

