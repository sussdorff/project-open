-- upgrade-3.4.0.1.0-3.4.0.2.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.1.0-3.4.0.2.0.sql','');




create or replace function acs_privilege__create_privilege (varchar,varchar,varchar)
returns integer as '
declare
	create_privilege__privilege             alias for $1;  
	create_privilege__pretty_name           alias for $2;  -- default null  
	create_privilege__pretty_plural         alias for $3;  -- default null
	v_count					integer;
begin
	select count(*) into v_count from acs_privileges
	where privilege = create_privilege__privilege;
	IF v_count > 0 THEN return 0; END IF;

	insert into acs_privileges (
		privilege, pretty_name, pretty_plural
	) values (
		create_privilege__privilege, 
		create_privilege__pretty_name, 
		create_privilege__pretty_plural
	);

    return 0; 
end;' language 'plpgsql';




create or replace function acs_privilege__add_child (varchar,varchar)
returns integer as '
declare
	add_child__privilege            alias for $1;  
	add_child__child_privilege      alias for $2;  
	v_count				integer;
begin
	select count(*) into v_count from acs_privilege_hierarchy
	where privilege = add_child__privilege and child_privilege = add_child__child_privilege;
	IF v_count > 0 THEN return 0; END IF;
	
	insert into acs_privilege_hierarchy (
		privilege, child_privilege
	) values (
		add_child__privilege, add_child__child_privilege
	);

    return 0; 
end;' language 'plpgsql';




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



select acs_privilege__create_privilege('edit_project_status','Edit Project Status','Edit Project Status');
select acs_privilege__add_child('admin', 'edit_project_status');

select im_priv_create('edit_project_status','Accounting');
select im_priv_create('edit_project_status','P/O Admins');
select im_priv_create('edit_project_status','Senior Managers');


