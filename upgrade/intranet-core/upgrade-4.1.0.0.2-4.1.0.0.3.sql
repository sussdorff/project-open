-- upgrade-4.1.0.0.2-4.1.0.0.3.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.0.0.2-4.1.0.0.3.sql','');


-----------------------------------------------------------
-- "Summary" Sub-menu below Home
--

SELECT im_menu__new (
	null,				-- p_menu_id
	'im_menu',			-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id
	'intranet-core',		-- package_name
	'home_summary',			-- label
	'Summary',			-- name
	'/intranet/index',		-- url
	-10,				-- sort_order
	(select menu_id from im_menus where label = 'home'),
	null				-- p_visible_tcl
);

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'home_summary'), 
	(select group_id from groups where group_name = 'Employees'),
	'read'
);


