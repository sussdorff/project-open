-- upgrade-3.4.0.5.3-3.4.0.5.4.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.5.3-3.4.0.5.4.sql','');


-- Disable older upgrade scripts
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.1.0.0.0-3.1.0.0.2.sql','');
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.1.0.0.2-3.1.0.1.0.sql','');
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.1.0.1.0-3.1.2.0.0.sql','');
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.1.2.0.0-3.1.3.0.0.sql','');
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.1.3.0.0-3.2.0.0.0.sql','');

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-3.1.2.0.0-3.1.3.0.0.sql','');
SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-3.1.4.0.0-3.2.0.0.0.sql','');
SELECT acs_log__debug('/packages/intranet-filestorage/sql/postgresql/upgrade/upgrade-3.1.1.0.0-3.1.2.0.0.sql','');
SELECT acs_log__debug('/packages/intranet-forum/sql/postgresql/upgrade/upgrade-3.1.4.0.0-3.2.0.0.0.sql','');
SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-3.1.0.0.0-3.1.1.0.0.sql','');
SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-3.1.1.0.0-3.1.2.0.0.sql','');
SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-3.1.3.0.0-3.2.0.0.0.sql','');
SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-3.1.0.0.0-3.1.1.0.0.sql','');
SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-3.1.1.0.0-3.1.2.0.0.sql','');
SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-3.1.2.0.0-3.1.3.0.0.sql','');
SELECT acs_log__debug('/packages/intranet-search-pg/sql/postgresql/upgrade/upgrade-3.1.2.0.0-3.1.4.0.0.sql','');
SELECT acs_log__debug('/packages/intranet-search-pg/sql/postgresql/upgrade/upgrade-3.1.4.0.0-3.2.0.0.0.sql','');
SELECT acs_log__debug('/packages/intranet-timesheet2-invoices/sql/postgresql/upgrade/upgrade-3.1.3.0.0-3.2.0.0.0.sql','');
SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-3.1.2.0.0-3.1.3.0.0.sql','');
SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-3.1.3.0.0-3.2.0.0.0.sql','');
SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-3.1.3.0.0-3.2.0.0.0.sql','');
SELECT acs_log__debug('/packages/intranet-trans-invoices/sql/postgresql/upgrade/upgrade-3.1.0.0.0-3.1.0.1.0.sql','');
SELECT acs_log__debug('/packages/intranet-trans-invoices/sql/postgresql/upgrade/upgrade-3.1.3.0.0-3.2.0.0.0.sql','');
SELECT acs_log__debug('/packages/intranet-translation/sql/postgresql/upgrade/upgrade-3.1.0.1.0-3.1.1.0.0.sql','');
SELECT acs_log__debug('/packages/intranet-translation/sql/postgresql/upgrade/upgrade-3.1.3.0.0-3.2.0.0.0.sql','');



create or replace function im_create_profile (varchar, varchar)
returns integer as '
DECLARE
	v_pretty_name	alias for $1;
	v_profile_gif	alias for $2;

	v_group_id	integer;
	v_rel_id	integer;
	n_groups	integer;
	v_category_id   integer;
BEGIN
	-- Check that the group does not exist before
	select count(*)
	into n_groups
	from groups
	where group_name = v_pretty_name;

	-- only add the group if it did not exist before...
	if n_groups = 0 then

	v_group_id := im_profile__new(
		v_pretty_name,
		v_profile_gif
	);

	v_rel_id := composition_rel__new (
		null,			-- rel_id
		''composition_rel'',	-- rel_type
		-2,			-- object_id_one
		v_group_id,		-- object_id_two
		0,			-- creation_user
		null			-- creation_ip
	);
	
	select acs_object_id_seq.nextval into v_category_id;

	-- Add the group to the Intranet User Type categories
	perform im_category_new (
		v_category_id,  -- category_id
		v_pretty_name, 		    -- category
		''Intranet User Type'',     -- category_type
		null	   		    -- description
	);

	update im_categories set aux_int1 = v_group_id where category_id = v_category_id;

	end if;
	return 0;
end;' language 'plpgsql';

create or replace function im_drop_profile (varchar) 
returns integer as '
DECLARE
	row		RECORD;
	v_pretty_name	alias for $1;

	v_group_id	integer;
BEGIN
	-- Check that the group does not exist before
	select group_id
	into v_group_id
	from groups
	where group_name = v_pretty_name;

	-- First we need to remove this dependency ...
	delete from im_profiles where profile_id = v_group_id;
	delete from acs_permissions where grantee_id=v_group_id;
	-- the acs_group package takes care of segments referred
	-- to by rel_constraints__rel_segment. We delete the ones
	-- references by rel_constraints__required_rel_segment here.
	for row in 
	select cons.constraint_id
	from rel_constraints cons, rel_segments segs
	where
		segs.segment_id = cons.required_rel_segment
		and segs.group_id = v_group_id
	loop

	PERFORM rel_segment__delete(row.constraint_id);

	end loop;

	-- delete the actual group
	PERFORM im_profile__delete(v_group_id);

	-- now delete the category
	delete from im_categories where category = v_pretty_name and category_type = ''Intranet User Type'';
        
	return 0;
end;' language 'plpgsql';
