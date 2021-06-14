-- upgrade-4.1.0.0.7-4.1.0.0.8.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.0.0.7-4.1.0.0.8.sql','');

-- PG 8.4 compatibility 

CREATE OR REPLACE FUNCTION im_profile_add_user(character varying, integer)
  RETURNS integer AS
$BODY$
DECLARE
    p_group_name    alias for $1;
    p_grantee_id    alias for $2;

    v_group_id    integer;
    v_rel_id    integer;
BEGIN
    -- Get the group_id from group_name
    select group_id
    into v_group_id
    from groups
    where group_name = p_group_name;

    select membership_rel__new(v_group_id,p_grantee_id) into v_rel_id;

    RETURN v_rel_id;

end;$BODY$
LANGUAGE 'plpgsql'; 
