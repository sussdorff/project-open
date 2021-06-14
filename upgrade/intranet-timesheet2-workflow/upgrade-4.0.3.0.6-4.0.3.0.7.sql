-- upgrade-4.0.3.0.6-4.0.3.0.7.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-workflow/sql/postgresql/upgrade/upgrade-4.0.3.0.6-4.0.3.0.7.sql','');

SELECT im_menu__new (
	null,									-- p_menu_id
	'im_menu',								-- object_type
	now(),									-- creation_date
	null,									-- creation_user
	null,									-- creation_ip
	null,									-- context_id
	'intranet-timesheet2-workflow',						-- package_name
	'reporting-unsubmitted-hours',						-- label
	'Timesheet Unsubmitted Hours',						-- name
	'/intranet-timesheet2-workflow/reports/unsubmitted-hours?',		-- url
	140,									-- sort_order
	(select menu_id from im_menus where label = 'reporting-timesheet'),	-- parent_menu_id
	null									-- p_visible_tcl
);

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'reporting-unsubmitted-hours'),
	(select group_id from groups where group_name = 'Employees'),
	'read'
);

