-- 5.0.2.1.0-5.0.2.1.1.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.2.1.0-5.0.2.1.1.sql','');


update im_menus set 
	parent_menu_id = (select menu_id from im_menus where label = 'admin'),
	sort_order = 1450
where label = 'admin_templates';


create or replace function im_biz_object_member__delete (integer, integer)
returns integer as $body$
DECLARE
	p_object_id	alias for $1;
	p_user_id	alias for $2;

	v_rel_id	integer;
	v_skill_profile_rel_id_exists_p	integer;
BEGIN
	select	rel_id
	into	v_rel_id
	from	acs_rels
	where	object_id_one = p_object_id
		and object_id_two = p_user_id;

	-- Other rels can reference a rel...
	select count(*) into v_skill_profile_rel_id_exists_p
	from information_schema.columns 
	where table_name = 'im_biz_object_members' and column_name = 'skill_profile_rel_id';
	IF v_skill_profile_rel_id_exists_p > 0 THEN 
		update im_biz_object_members
		set skill_profile_rel_id = null
		where skill_profile_rel_id = v_rel_id;			   
	END IF;

	delete	from im_biz_object_members
	where	object_role_id = v_rel_id;

	PERFORM acs_rel__delete(v_rel_id);
	return 0;
end; $body$ language 'plpgsql';
