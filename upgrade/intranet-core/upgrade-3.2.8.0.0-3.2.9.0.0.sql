-- upgrade-3.2.8.0.0-3.2.9.0.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.2.8.0.0-3.2.9.0.0.sql','');

\i upgrade-3.0.0.0.first.sql


create or replace function inline_0 ()
returns integer as '
DECLARE
	v_count		integer;
BEGIN
	select count(*) into v_count
	from user_tab_columns
	where	lower(table_name) = ''persons''
		and lower(column_name) = ''demo_group'';
	IF v_count > 0 THEN return 0; END IF;

	alter table persons add demo_group varchar(50);
	alter table persons add demo_password varchar(50);

	return 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();




-------------------------------------------------------------
-- Slow query for Employees (the most frequent one...)
-- because of missing outer-join reordering in PG 7.4...
-- Now adding the "im_employees" (in extra-from/extra-where)
-- INSIDE the basic query.

update im_view_columns set extra_from = null, extra_where = null where column_id = 5500;



-- Notifications Component for each user
create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from im_component_plugins
	where lower(plugin_name) = lower(''User Notifications'');
	IF v_count > 0 THEN return 0; END IF;

	PERFORM im_component_plugin__new (
		null,				-- plugin_id
		''im_component_plugin'',	-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''User Notifications'',		-- plugin_name
		''intranet'',			-- package_name
		''right'',			-- location
		''/intranet/users/view'',	-- page_url
		null,				-- view_name
		85,				-- sort_order
		''im_notification_user_component -user_id $user_id''   -- component_tcl
	);

	return 1;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




-------------------------------------------------------------
-- Shortcut proc to setup loads of privileges.
--
create or replace function im_priv_create (varchar, varchar)
returns integer as '
DECLARE
	p_priv_name		alias for $1;
	p_profile_name		alias for $2;

	v_profile_id		integer;
	v_object_id		integer;
	v_count			integer;
BEGIN
	-- Get the group_id from group_name
	select group_id into v_profile_id from groups
	where group_name = p_profile_name;

	-- Get the Main Site id, used as the global identified for permissions
	select package_id into v_object_id from apm_packages 
	where package_key=''acs-subsite'';

	select count(*) into v_count from acs_permissions
	where object_id = v_object_id and grantee_id = v_profile_id and privilege = p_priv_name;

	IF NULL != v_profile_id AND 0 = v_count THEN
		PERFORM acs_permission__grant_permission(v_object_id, v_profile_id, p_priv_name);
	END IF;

	return 0;
end;' language 'plpgsql';

