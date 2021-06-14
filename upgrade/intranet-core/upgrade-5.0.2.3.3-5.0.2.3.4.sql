-- upgrade-5.0.2.3.3-5.0.2.3.4.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.2.3.3-5.0.2.3.4.sql','');


-- Create menu entry for main user view page,
-- similar to projects
--
select im_menu__new (
	null, 'im_menu', now(), null, null, null,
	'intranet-core',		-- package_name
	'user_page',			-- label
	'User',				-- name
	'/intranet/users/view',		-- url
	30,				-- sort_order
	(select menu_id from im_menus where label = 'top'),
	null				-- p_visible_tcl
);

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'user_page'),
	(select group_id from groups where group_name = 'Employees'),
	'read'
);



select im_menu__new (
	null, 'im_menu', now(), null, null, null,
	'intranet-core',		-- package_name
	'user_summary',			-- label
	'Summary',			-- name
	'/intranet/users/view',		-- url
	10,				-- sort_order
	(select menu_id from im_menus where label = 'user_page'),
	null				-- p_visible_tcl
);

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'user_summary'),
	(select group_id from groups where group_name = 'Employees'),
	'read'
);
