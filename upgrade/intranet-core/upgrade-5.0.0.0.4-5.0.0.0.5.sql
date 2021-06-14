-- upgrade-5.0.0.0.4-5.0.0.0.5.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.0.0.4-5.0.0.0.5.sql','');

-- acs-mail is deprecated
-- To ensure backwards compatibility inherit acs_mail_nt__post_request using acs_mail_lite queue

create or replace function acs_mail_nt__post_request(integer,integer,boolean,varchar,text,integer,integer)
returns integer as $BODY$
declare
        p_party_from            alias for $1;
        p_party_to              alias for $2;
        p_expand_group          alias for $3;   -- default 'f'
        p_subject               alias for $4;
        p_message               alias for $5;
        p_max_retries           alias for $6;   -- default 0
        p_package_id            alias for $7;   -- default null
        v_header_from           acs_mail_bodies.header_from%TYPE;
        v_header_to             acs_mail_bodies.header_to%TYPE;
        v_message_id            acs_mail_queue_messages.message_id%TYPE;
        v_header_to_rec         record;
        v_creation_user         acs_objects.creation_user%TYPE;
	v_creation_date		timestamptz;
	v_locking_server	varchar;
	v_mime_type		varchar;
begin
        if p_max_retries <> 0 then
           raise EXCEPTION ' -20000: max_retries parameter not implemented.';
        end if;

        -- get the sender email address
        select max(email) into v_header_from from parties where party_id = p_party_from;

        -- if sender address is null, then use site default OutgoingSender
        if v_header_from is null then
                select apm__get_value(package_id, 'OutgoingSender') into v_header_from from apm_packages where package_key='acs-kernel';
        end if;

        -- make sure that this party is in users table. If not, let creation_user
        -- be null to prevent integrity constraint violations on acs_objects
        select max(user_id) into v_creation_user from users where user_id = p_party_from;

        -- get the recipient email address
        select max(email) into v_header_to from parties where party_id = p_party_to;

        -- do not let from addresses be null
        if v_header_from is null then
           raise EXCEPTION ' -20000: acs_mail_nt: cannot sent email from blank address.';
        end if;

        -- do not let any of these addresses be null
        if v_header_to is null AND p_expand_group = 'f' then
           raise EXCEPTION ' -20000: acs_mail_nt: cannot sent email to blank address.';
        end if;

	-- set vars 
	select now() into v_creation_date; 
	v_locking_server := null; 
	v_mime_type := 'text/plain';


	if p_expand_group = 'f' then

		insert into acs_mail_lite_queue
                  (message_id,
                   creation_date,
                   locking_server,
                   to_addr,
                   from_addr,
                   reply_to,
                   subject,
                   package_id,
                   mime_type,
                   body
                  )
            values
                   (nextval('acs_mail_lite_id_seq'),
                   v_creation_date,
                   v_locking_server,
                   v_header_to,
                   v_header_from,
                   v_header_from,
                   p_subject ,
                   p_package_id,
                   v_mime_type,
                   p_message
                  );

        else
                -- expand the group
                -- FIXME: need to check if this is a group and if there are members
                --        if not, do we need to notify sender?

                for v_header_to_rec in
                        select email from parties p
                        where party_id in (
                           SELECT u.user_id
                           FROM group_member_map m, membership_rels mr, users u
                           INNER JOIN (select member_id from group_approved_member_map where group_id = p_party_to) mm
                           ON u.user_id = mm.member_id
                           WHERE u.user_id = m.member_id
                           AND m.group_id in (acs__magic_object_id('registered_users'::CHARACTER VARYING))
                           AND m.rel_id = mr.rel_id AND m.container_id = m.group_id
                           AND m.rel_type::TEXT = 'membership_rel'::TEXT
                           AND mr.member_state = 'approved'
                        )
                loop
			insert into acs_mail_lite_queue
			       (message_id,
			       creation_date,
			       locking_server,
			       to_addr,
			       from_addr,
			       reply_to,
			       subject,
			       package_id,
			       mime_type,
			       body
			)
			values
			      (nextval('acs_mail_lite_id_seq'),
			      v_creation_date,
			      v_locking_server,
			      v_header_to_rec.email,
			      v_header_from,
			      v_header_from,
			      p_subject ,
			      p_package_id,
			      v_mime_type,
			      p_message
	               );
                end loop;
        end if;
        return 1;
end;$BODY$ language 'plpgsql';


create or replace function acs_mail_nt__post_request(integer,integer,boolean,varchar,text,integer)
returns integer as $BODY$
declare
        p_party_from            alias for $1;
        p_party_to              alias for $2;
        p_expand_group          alias for $3;   -- default 'f'
        p_subject               alias for $4;
        p_message               alias for $5;
        p_max_retries           alias for $6;   -- default 0
        v_header_from           acs_mail_bodies.header_from%TYPE;
        v_header_to             acs_mail_bodies.header_to%TYPE;
        v_message_id            acs_mail_queue_messages.message_id%TYPE;
        v_header_to_rec         record;
        v_creation_user         acs_objects.creation_user%TYPE;
	v_creation_date		timestamptz;
	v_locking_server	varchar;
	v_mime_type		varchar;
begin
	
	return acs_mail_nt__post_request(p_party_from, p_party_to, p_expand_group, p_subject, p_message, p_max_retries, null);

end;$BODY$ language 'plpgsql';




-- Fix translation issue
delete from lang_messages
where	message_key = 'lt_Registered_from_regis' and package_key = 'intranet-core';


update im_menus set 
       parent_menu_id = (select menu_id from im_menus where label = 'projects'),
       sort_order = 10
where label = 'project_programs';

