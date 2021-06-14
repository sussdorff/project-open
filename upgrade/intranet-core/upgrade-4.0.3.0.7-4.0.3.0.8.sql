-- upgrade-4.0.3.0.7-4.0.3.0.8.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.0.7-4.0.3.0.8.sql','');


create or replace function inline_0 ()
returns integer as $body$
declare
        v_count  integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = 'im_biz_object_members' and lower(column_name) = 'skill_profile_rel_id';
        IF v_count = 0 THEN
                alter table im_biz_object_members
		add column skill_profile_rel_id integer
		constraint im_biz_object_members_skill_profile_rel_fk
		references im_biz_object_members;
        END IF;

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




-- Return a TCL list of the member_ids of the members of a
-- business object.
create or replace function im_biz_object_member__list (integer)
returns varchar as $body$
DECLARE
        p_object_id     alias for $1;
        v_members       varchar;
        row             record;
BEGIN
        v_members := '';
        FOR row IN
                select  r.rel_id,
                        r.object_id_two as party_id,
                        coalesce(bom.object_role_id::varchar, '""') as role_id,
                        coalesce(bom.percentage::varchar, '""') as percentage
                from    acs_rels r,
                        im_biz_object_members bom
                where   r.rel_id = bom.rel_id and
                        r.object_id_one = p_object_id
                order by party_id
        LOOP
                IF '' != v_members THEN v_members := v_members || ' '; END IF;
                v_members := v_members || '{' || row.party_id || ' ' || row.role_id || ' ' || row.percentage || ' ' || row.rel_id || '}';
        END LOOP;

        return v_members;
end;$body$ language 'plpgsql';

