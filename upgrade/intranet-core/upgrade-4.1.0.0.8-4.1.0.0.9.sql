-- 4.1.0.0.8-4.1.0.0.9.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.0.0.8-4.1.0.0.9.sql','');

-- ------------------------------------------------------
-- Allow to add queues to tickets
--
SELECT	im_component_plugin__new (
	null,				-- plugin_id
	'im_component_plugin',		-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id
	'Add Profile Member',	-- plugin_name
	'intranet-core',		-- package_name
	'right',				-- location
	'/intranet/member-add',		-- page_url
	null,				-- view_name
	30,				-- sort_order
	'im_biz_object_add_profile_component -object_id $object_id'
);

SELECT acs_permission__grant_permission(
        (select plugin_id from im_component_plugins where plugin_name = 'Add Profile Member' and package_name = 'intranet-core'),
        (select group_id from groups where group_name = 'Employees'),
        'read'
);


-- Allow parties (=groups) as employees of a company
update acs_rel_types 
set object_type_two = 'party'
where rel_type = 'im_company_employee_rel';

update acs_rel_types 
set object_type_two = 'party'
where rel_type = 'im_key_account_rel';

