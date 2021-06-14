-- upgrade-5.0.2.5.1-5.0.2.5.2.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.2.5.1-5.0.2.5.2.sql','');



select im_menu__new (
	null,				-- p_menu_id
	'im_menu',			-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id
	'intranet-core',		-- package_name
	'admin_nsstats',		-- label
	'NaviServer Stats',		-- name
	'/intranet/admin/nsstats',	-- url
	1850,				-- sort_order
	(select menu_id from im_menus where label = 'admin'),
	null				-- p_visible_tcl
);


