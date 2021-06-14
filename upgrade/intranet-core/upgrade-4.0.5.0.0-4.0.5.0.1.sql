-- upgrade-4.0.5.0.0-4.0.5.0.1.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.5.0.0-4.0.5.0.1.sql','');


update im_menus
set url = '/intranet/admin/consistency-check'
where label = 'admin_consistency_check';




-- Return a TCL list of the member_ids of the members of a 
-- business object.
create or replace function im_biz_object_pm__list (integer)
returns varchar as $body$
DECLARE
	p_object_id	alias for $1;
	v_members	varchar;
	row		record;
BEGIN
	v_members := '';
	FOR row IN 
		select	r.rel_id,
			r.object_id_two as party_id,
			coalesce(bom.object_role_id::varchar, '""') as role_id,
			coalesce(bom.percentage::varchar, '""') as percentage
		from	acs_rels r,
			im_biz_object_members bom
		where	r.rel_id = bom.rel_id and
			r.object_id_one = p_object_id and
			bom.object_role_id = 1301
		order by party_id
	LOOP
		IF '' != v_members THEN v_members := v_members || ' '; END IF;
		v_members := v_members || '{' || row.party_id || ' ' || row.role_id || ' ' || row.percentage || ' ' || row.rel_id || '}';
	END LOOP;

	return v_members;
end;$body$ language 'plpgsql';



