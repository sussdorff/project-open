-- upgrade-5.0.2.4.8-5.0.2.4.9.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.2.4.8-5.0.2.4.9.sql','');


-------------------------------------------------------------
-- Shortcut proc to setup loads of privileges.
--
create or replace function im_priv_create (varchar, varchar)
returns integer as $body$
DECLARE
	p_priv_name		alias for $1;
	p_profile_name		alias for $2;

	v_profile_id		integer;
	v_object_id		integer;
	v_count			integer;
BEGIN
	-- Get the group_id from group_name
	select coalesce(min(group_id),0) into v_profile_id from groups
	where group_name = p_profile_name;

	-- Get the Main Site id, used as the global identified for permissions
	select min(package_id) into v_object_id from apm_packages 
	where package_key='acs-subsite';

	select count(*) into v_count from acs_permissions
	where object_id = v_object_id and grantee_id = v_profile_id and privilege = p_priv_name;

	-- RAISE NOTICE 'im_priv_create: object_id=%, profile_id=%, priv=%, count=%', v_object_id, v_profile_id, p_priv_name, v_count;
	IF 0 != v_profile_id AND 0 = v_count THEN
		-- RAISE NOTICE 'im_priv_create: creating: object_id=%, profile_id=%, priv=%', v_object_id, v_profile_id, p_priv_name;
		PERFORM acs_permission__grant_permission(v_object_id, v_profile_id, p_priv_name);
	END IF;

	return 0;
end;$body$ language 'plpgsql';

