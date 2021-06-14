-- upgrade-4.0.2.0.9-4.0.3.0.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.2.0.9-4.0.3.0.0.sql','');

-- Relax the role restriction for business object membership.
-- We now accept groups and possibly even companies as "members".
--
update acs_rel_types 
set object_type_two = 'acs_object' 
where rel_type = 'im_biz_object_member';




-- Return a TCL list of the member_ids of the members of a 
-- business object.
create or replace function im_biz_object_member__list (integer)
returns varchar as $body$
DECLARE
	p_object_id	alias for $1;
	v_members	varchar;
	row		record;
BEGIN
	v_members := '';
	FOR row IN 
		select	r.object_id_two as party_id,
			coalesce(bom.object_role_id::varchar, '""') as role_id,
			coalesce(bom.percentage::varchar, '""') as percentage
		from	acs_rels r,
			im_biz_object_members bom
		where	r.rel_id = bom.rel_id and
			r.object_id_one = p_object_id
		order by party_id
	LOOP
		IF '' != v_members THEN v_members := v_members || ' '; END IF;
		v_members := v_members || '{' || row.party_id || ' ' || row.role_id || ' ' || row.percentage || '}';
	END LOOP;

	return v_members;
end;$body$ language 'plpgsql';
