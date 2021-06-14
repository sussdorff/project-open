-- upgrade-5.0.2.0.1-5.0.2.1.0.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.2.0.1-5.0.2.1.0.sql','');



-- Add admin wizard to bottom of admin page
SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,	-- system params
	'Interactive Administration Guide',			-- plugin_name
	'intranet-core',					-- package_name
	'bottom',						-- location
	'/intranet/admin/index',				-- page_url
	null,							-- view_name
	10,							-- sort_order
	'im_sysconfig_admin_guide',
	'lang::message::lookup "" intranet-core.Interactive_Administration_Guide "Interactive Administration Guide"'
);


