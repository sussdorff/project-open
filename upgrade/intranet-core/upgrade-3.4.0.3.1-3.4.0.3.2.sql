-- upgrade-3.4.0.3.1-3.4.0.3.2.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.3.1-3.4.0.3.2.sql','');




-- Rename Authentication in "LDAP Authentication"
-- for its main purpose
--
update im_menus
set name = 'LDAP Authentication'
where label = 'openacs_auth';



select im_menu__new (
	null,				-- p_menu_id
	'im_menu',			-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id
	'intranet-core',		-- package_name
	'openacs_restart_server',	-- label
	'Restart Server',		-- name
	'/acs-admin/server-restart',	-- url
	190,				-- sort_order
	(select menu_id from im_menus where label = 'openacs'),
	null				-- p_visible_tcl
);


update im_menus
set name = 'Portlet Components'
where url = '/intranet/admin/components/';

