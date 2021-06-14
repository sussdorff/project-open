-- 5.0.2.3.0-5.0.2.3.1.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.2.3.0-5.0.2.3.1.sql','');


select im_menu__new (
	null,				-- p_menu_id
	'im_menu',			-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id
	'intranet-core',		-- package_name
	'admin_request_monitor',		-- label
	'Request Monitor',		-- name
	'/request-monitor/index',	-- url
	2200,				-- sort_order
	(select menu_id from im_menus where label = 'admin'),
	'[im_package_exists_p "xotcl-request-monitor"]'				-- p_visible_tcl
);

update im_menus set sort_order = 2200, menu_gif_small = 'arrow_right'	where label = 'openacs_request_monitor';

