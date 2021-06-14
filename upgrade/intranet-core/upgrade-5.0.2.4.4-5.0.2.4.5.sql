-- upgrade-5.0.2.4.4-5.0.2.4.5.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.2.4.4-5.0.2.4.5.sql','');




create or replace function im_privilege_p (integer, varchar)
returns boolean as $body$
DECLARE
	p_grantee_id		alias for $1;
	p_privilege		alias for $2;

	v_mainsite_id		integer;
BEGIN
	-- Get the mainsite_id
	select	min(object_id) into v_mainsite_id
	from	acs_objects
	where	title = 'Main Site';

	return acs_permission__permission_p(v_mainsite_id, p_grantee_id, p_privilege);
end;$body$ language 'plpgsql';



