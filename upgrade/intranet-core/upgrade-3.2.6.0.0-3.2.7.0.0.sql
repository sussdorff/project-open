-- upgrade-3.2.6.0.0-3.2.7.0.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.2.6.0.0-3.2.7.0.0.sql','');

\i upgrade-3.0.0.0.first.sql


-------------------------------------------------------------
-- Slow query for Employees (the most frequent one...)
-- because of missing outer-join reordering in PG 7.4...
-- Now adding the "im_employees" (in extra-from/extra-where)
-- INSIDE the basic query.

update im_view_columns set extra_from = null, extra_where = null where column_id = 5500;



-------------------------------------------------------------
-- Allow to make quotes for both active and potential companies
create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
        select count(*) into v_count from im_categories
	where category = ''Active or Potential'';
        IF 0 != v_count THEN return 0; END IF;

	insert into im_categories (
	        CATEGORY_DESCRIPTION, ENABLED_P, CATEGORY_ID,
	        CATEGORY, CATEGORY_TYPE
	) values (
	        '''', ''f'', ''40'',
	        ''Active or Potential'', ''Intranet Company Status''
	);


	-- Introduce "Active or Potential" as supertype of both
	-- "Acative" and "Potential"
	--
	-- im_category_hierarchy(parent, child)
	
	INSERT INTO im_category_hierarchy 
		SELECT 40, child_id
		FROM im_category_hierarchy
		WHERE parent_id = 41
	;

	-- Make "Potential" and "Active" themselves children of "Act or Pot"
	INSERT INTO im_category_hierarchy VALUES (40, 41);
	INSERT INTO im_category_hierarchy VALUES (40, 46);

	return 1;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




-- Return a string with all profiles of the user
create or replace function im_profiles_from_user_id(integer)
returns varchar as '
DECLARE
        v_user_id       alias for $1;
        v_profiles      varchar;
        row             RECORD;
BEGIN
        v_profiles := '''';
        FOR row IN
                select  group_name
                from    groups g,
                        im_profiles p,
                        group_distinct_member_map m
                where   m.member_id = v_user_id
                        and g.group_id = m.group_id
                        and g.group_id = p.profile_id
        LOOP
            IF '''' != v_profiles THEN v_profiles := v_profiles || '', ''; END IF;
            v_profiles := v_profiles || row.group_name;
        END LOOP;

        return v_profiles;
END;' language 'plpgsql';
-- select im_profiles_from_user_id(624);






create or replace function im_name_from_id(integer)
returns varchar as '
DECLARE
        v_integer       alias for $1;
        v_result        varchar(4000);
BEGIN
        -- Try with category - probably the fastest
        select category
        into v_result
        from im_categories
        where category_id = v_integer;

        IF v_result is not null THEN return v_result; END IF;

        -- Try with ACS_OBJECT
        select acs_object__name(v_integer)
        into v_result;

        return v_result;

END;' language 'plpgsql';


create or replace function im_name_from_id(varchar)
returns varchar as '
DECLARE
        v_result	alias for $1;
BEGIN
        return v_result;
END;' language 'plpgsql';



create or replace function im_name_from_id(timestamptz)
returns varchar as '
DECLARE
        v_timestamp	alias for $1;
BEGIN
        return to_char(v_timestamp, ''YYYY-MM-DD'');
END;' language 'plpgsql';



create or replace function im_name_from_id(numeric)
returns varchar as '
DECLARE
        v_result        alias for $1;
BEGIN
        return v_result::varchar;
END;' language 'plpgsql';




create or replace function im_integer_from_id(integer)
returns varchar as '
DECLARE
        v_result        alias for $1;
BEGIN
        return v_result::varchar;
END;' language 'plpgsql';



create or replace function im_integer_from_id(varchar)
returns varchar as '
DECLARE
        v_result        alias for $1;
BEGIN
        return v_result;
END;' language 'plpgsql';




create or replace function im_integer_from_id(numeric)
returns varchar as '
DECLARE
        v_result        alias for $1;
BEGIN
        return v_result::varchar;
END;' language 'plpgsql';







-------------------------------------------------------------
-- Fix issue with deleting Wiki items


create or replace function content_item__del (integer)
returns integer as '
declare
	delete__item_id                alias for $1;  
	v_symlink_val                  record;
	v_revision_val                 record;
	v_rel_val                      record;
begin
	raise NOTICE ''2) Deleting symlinks...'';
	FOR v_symlink_val in 
		select	symlink_id
		from	cr_symlinks
		where	target_id = delete__item_id 
	LOOP
	    PERFORM content_symlink__delete(v_symlink_val.symlink_id);
	end loop;

	raise NOTICE ''Unscheduling item...'';
	delete from cr_release_periods where item_id = delete__item_id;

	raise NOTICE ''3a) Deleting associated publish audits...'';
	delete from cr_item_publish_audit where item_id = delete__item_id;


	raise NOTICE ''3b) Delete latest and live revision links...'';
	update cr_items set 
		live_revision = null, 
		latest_revision = null
	where item_id =  delete__item_id;

	raise NOTICE ''3c) Deleting associated revisions...'';
	FOR v_revision_val in
		select	revision_id 
		from	cr_revisions
		where	item_id = delete__item_id
	LOOP
	    raise NOTICE ''3d) acs_object__delete(%)'', v_revision_val.revision_id;
	    PERFORM acs_object__delete(v_revision_val.revision_id);
	end loop;
	
	raise NOTICE ''4) Deleting associated item templates...'';
	delete from cr_item_template_map where item_id = delete__item_id; 

	raise NOTICE ''Deleting item relationships...'';
	FOR v_rel_val in 
		select	rel_id
		from	cr_item_rels
		where	item_id = delete__item_id
			or related_object_id = delete__item_id 
	LOOP
	    PERFORM acs_rel__delete(v_rel_val.rel_id);
	end loop;  

	raise NOTICE ''Deleting child relationships...'';
	FOR v_rel_val in
		select	rel_id
		from	cr_child_rels
		where	child_id = delete__item_id 
	LOOP
	    PERFORM acs_rel__delete(v_rel_val.rel_id);
	end loop;  

	raise NOTICE ''Deleting parent relationships...'';
	FOR v_rel_val in 
		select	rel_id, child_id
		from	cr_child_rels
		where	parent_id = delete__item_id 
	LOOP
	    PERFORM acs_rel__delete(v_rel_val.rel_id);
	    PERFORM content_item__delete(v_rel_val.child_id);
	end loop;  

	raise NOTICE ''5) Deleting associated permissions...'';
	delete from acs_permissions
	where object_id = delete__item_id;

	raise NOTICE ''6) Deleting keyword associations...'';
	delete from cr_item_keyword_map
	where item_id = delete__item_id;

	raise NOTICE ''7) Deleting associated comments...'';
	PERFORM journal_entry__delete_for_object(delete__item_id);

	raise NOTICE ''Deleting content item...'';
	PERFORM acs_object__delete(delete__item_id);

	return 0; 
end;' language 'plpgsql';



----------------------------------------------------------------
-- percentage column for im_biz_object_members


create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = ''im_biz_object_members'' and lower(column_name) = ''percentage'';
        IF 0 != v_count THEN return 0; END IF;

	ALTER TABLE im_biz_object_members ADD column percentage numeric(8,2);
	ALTER TABLE im_biz_object_members ALTER column percentage set default 100;

        return 1;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



