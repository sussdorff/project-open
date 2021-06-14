-- upgrade-5.0.0.0.8-5.0.0.0.9.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.0.0.8-5.0.0.0.9.sql','');

--  

create or replace function im_create_profile (varchar, varchar)
returns integer as $body$
DECLARE
        v_pretty_name   alias for $1;
        v_profile_gif   alias for $2;

        v_group_id      integer;
        v_rel_id        integer;
        n_groups        integer;
        v_category_id   integer;
BEGIN
        -- Check that the group does not exist before
        select  count(*)
        into    n_groups
        from    groups
        where   group_name = v_pretty_name;

        -- only add the group if it did not exist before...
        IF n_groups = 0 THEN
                v_group_id := im_profile__new(
                        v_pretty_name,
                        v_profile_gif
                );

                v_rel_id := composition_rel__new (
                        null,                           -- rel_id
                        'composition_rel',              -- rel_type
                        -2,                             -- object_id_one
                        v_group_id,                     -- object_id_two
                        0,                              -- creation_user
                        null                            -- creation_ip
                );

		select nextval into v_category_id from acs_object_id_seq;

                -- Add the group to the Intranet User Type categories
                perform im_category_new (
                        v_category_id,                  -- category_id
                        v_pretty_name,                  -- category
                        'Intranet User Type',           -- category_type
                        null                            -- description
                );

                update im_categories set aux_int1 = v_group_id where category_id = v_category_id;

        END IF;
        return 0;
end;$body$ language 'plpgsql';



