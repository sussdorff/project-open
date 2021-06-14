-- upgrade-4.0.5.0.4-4.0.5.0.5.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.5.0.4-4.0.5.0.5.sql','');


-----------------------------------------------------------
-- Create Biz Object Group datatype as a dynamically managed group
-----------------------------------------------------------

select acs_object_type__create_type (
	'im_biz_object_group',
	'Biz Object Group',
	'Biz Object Groups',
	'group',
	'im_biz_object_groups',
	'group_id',
	'im_biz_object_group',
	'f',
	null,
	null
);


create or replace function inline_0 () returns integer as $body$
DECLARE
	v_count		    integer;
BEGIN
	select	count(*) into v_count 
	from	acs_object_type_tables
	where	object_type = 'im_biz_object_group' and
		table_name = 'im_biz_object_groups';
	IF v_count = 0  THEN
		insert into acs_object_type_tables VALUES ('im_biz_object_group', 'im_biz_object_groups', 'group_id');
	END IF; 

	-- Mark biz_object_group as a dynamically managed object type
	update acs_object_types 
	set dynamic_p='t' 
	where object_type = 'im_biz_object_group';

	select	count(*) into v_count
	from	group_type_rels	
	where	group_type = 'im_biz_object_group';
	IF v_count = 0  THEN
		-- Copy group type_rels to groups
		insert into group_type_rels (group_rel_type_id, rel_type, group_type)
		select	nextval('t_acs_object_id_seq'), 
			r.rel_type, 
			'im_biz_object_group'
		from	group_type_rels r
		where	r.group_type = 'group';
	END IF; 

	select	count(*) into v_count
	from	user_tab_columns
	where	lower(table_name) = 'im_biz_object_groups';
	IF v_count = 0  THEN
		create table im_biz_object_groups (
			group_id	integer
					constraint im_biz_object_groups_id_pk primary key
					constraint im_biz_object_groups_id_fk references groups,
					-- The ID of the business object for which this group is created
			biz_object_id	integer
					constraint im_biz_object_groups_biz_object_fk references acs_objects
		);

		-- Unique index: Do not allow duplicate biz object groups for a single biz object
		create unique index im_biz_object_groups_un on im_biz_object_groups (coalesce(biz_object_id,0));
	END IF;

	return 0;
END;$body$ language 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();



select define_function_args('im_biz_object_group__new','group_id,group_name,email,url,last_modified;now(),modifying_ip,object_type;im_biz_object_group,context_id,creation_user,creation_date;now(),creation_ip,join_policy,biz_object_id');

create or replace function im_biz_object_group__new(integer,varchar,varchar,varchar,timestamptz,varchar,varchar,integer,integer,timestamptz,varchar,varchar,integer)
returns integer as $$
declare
	p_group_id		alias for $1;
	p_group_name		alias for $2;
	p_email			alias for $3;
	p_url			alias for $4;
	p_last_modified		alias for $5;
	p_modifying_ip		alias for $6;

	p_object_type		alias for $7;
	p_context_id		alias for $8;
	p_creation_user		alias for $9;
	p_creation_date		alias for $10;
	p_creation_ip		alias for $11;
	p_join_policy		alias for $12;
	p_biz_object_id		alias for $13;

	v_group_id 		im_biz_object_groups.group_id%TYPE;
begin
	v_group_id := acs_group__new (
		p_group_id, p_object_type, 
		p_creation_date, p_creation_user, 
		p_creation_ip, p_email, 
		p_url, p_group_name, 
		p_join_policy, p_context_id
	);
	insert into im_biz_object_groups (group_id, biz_object_id) values (v_group_id, p_biz_object_id);
	return v_group_id;
end;$$ language 'plpgsql';

create or replace function im_biz_object_group__delete (integer)
returns integer as $$
declare
	p_group_id	alias for $1;
begin
	delete from im_biz_object_groups where group_id = p_group_id;
	perform acs_group__delete( p_group_id );
	return 1;
end;$$ language 'plpgsql';

create or replace function im_biz_object_group__name (integer)
returns varchar as $$
declare
	p_group_id	alias for $1;
	v_name		varchar;
begin
	select	group_name into v_name from groups
	where	group_id = p_group_id;
	return v_name;
end;$$ language 'plpgsql';


