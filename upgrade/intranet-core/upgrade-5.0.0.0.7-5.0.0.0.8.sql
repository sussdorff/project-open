-- upgrade-5.0.0.0.7-5.0.0.0.8.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.0.0.7-5.0.0.0.8.sql','');

-- Create the new group/profile if not already there...
create or replace function inline_0()
returns integer as $body$
DECLARE
	v_count		integer;
BEGIN
	select	count(*) into v_count from groups
	where	group_name = 'Skill Profile';
	IF v_count > 0 THEN return 1; END IF;

	PERFORM im_profile__new('Skill Profile', 'skill_profile');

	return 0;
END;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();






-- Set name and email of the skill profiles
update persons set	first_names = 'Consultant', 	last_name = 'Consultant'	where person_id = 8987;
update persons set	first_names = 'Project', 	last_name = 'Manager'		where person_id = 8989;
update persons set	first_names = 'Administrator', 	last_name = 'Administrator'	where person_id = 8991;
update persons set	first_names = 'Database', 	last_name = 'Administrator'	where person_id = 8999;
update persons set	first_names = 'Presales', 	last_name = 'Presales'		where person_id = 9003;
update persons set	first_names = 'Tester', 	last_name = 'Tester'		where person_id = 9005;
update persons set	first_names = 'Senior', 	last_name = 'Developer'		where person_id = 9007;
update persons set	first_names = 'Junior', 	last_name = 'Developer'		where person_id = 9013;

update parties set	email = 'consultant@tigerpond.com',	url = null	where party_id = 8987;
update parties set	email = 'project.manager',		url = null	where party_id = 8989;
update parties set	email = 'administrator@tigerpond.com',	url = null	where party_id = 8991;
update parties set	email = 'database.administrator',	url = null	where party_id = 8999;
update parties set	email = 'presales@tigerpond.com',	url = null	where party_id = 9003;
update parties set	email = 'tester@tigerpond.com',		url = null	where party_id = 9005;
update parties set	email = 'senior.developer@tigerpond.com', url = null	where party_id = 9007;
update parties set	email = 'junior.developer@tigerpond.com', url = null	where party_id = 9013;


-- Cleanup the contact information of the skill profile users
update users_contact set
	aim_screen_name = null,
	cell_phone = null,
	current_information = null,
	fax = null,
	ha_city = null, ha_country_code = null, ha_line1 = null, ha_line2 = null, ha_postal_code = null, ha_state = null,
	wa_city = null, wa_country_code = null, wa_line1 = null, wa_line2 = null, wa_postal_code = null, wa_state = null,
	home_phone = null,
	icq_number = null,
	m_address = null,
	msn_screen_name = null,
	note = null,
	pager = null,
	work_phone = null
where
	user_id in (8987, 8989, 8991, 8999, 9003, 9005, 9007, 9013);

-- Remove the skill profile users from any group except "Registered Users"
select	r.object_id_two as user_id,
	r.rel_id,
	membership_rel__delete(r.rel_id) as del
from	acs_rels r
where	r.rel_type = 'membership_rel' and 
	r.object_id_one > 0 and
	r.object_id_two in (8987, 8989, 8991, 8999, 9003, 9005, 9007, 9013);

-- Add the skill profile users to the group "Skill Profiles"
select	membership_rel__new(
		(select group_id from groups where group_name = 'Skill Profile'),
		person_id
	) as rel
from	persons
where	person_id in (8987, 8989, 8991, 8999, 9003, 9005, 9007, 9013);


