-- upgrade-3.4.1.0.7-3.4.1.0.8.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.1.0.7-3.4.1.0.8.sql','');


-- List objects associated to user
SELECT  im_component_plugin__new (
	null,				-- plugin_id
	'im_component_plugin',		-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	'0.0.0.0',			-- creation_ip
	null,				-- context_id
	'User Related Objects',		-- plugin_name
	'intranet-core',		-- package_name
	'right',			-- location
	'/intranet/users/view',		-- page_url
	null,				-- view_name
	20,				-- sort_order
	'im_biz_object_related_objects_component -include_membership_rels_p 1 -object_id $user_id'	-- component_tcl
);



update im_component_plugins
set enabled_p = 'f'
where page_url = '/intranet/users/view' and plugin_name = 'User Offices';

