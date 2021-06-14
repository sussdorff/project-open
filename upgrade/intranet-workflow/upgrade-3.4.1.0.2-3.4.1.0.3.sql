-- upgrade-3.4.1.0.2-3.4.1.0.3.sql

SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-3.4.1.0.2-3.4.1.0.3.sql','');

CREATE OR REPLACE FUNCTION im_workflow__notification_simple(integer, character varying, character varying)
  RETURNS integer AS
$BODY$
declare
        p_case_id               alias for $1;
        p_transition_key        alias for $2;
	p_custom_arg            alias for $3;

        v_task_id               integer;        v_case_id               integer;
        v_creation_ip           varchar;        v_creation_user         integer;
        v_object_id             integer;        v_object_type           varchar;
        v_journal_id            integer;
        v_transition_key        varchar;        v_workflow_key          varchar;
        v_group_id              integer;        v_group_name            varchar;
        v_task_owner            integer;	v_transition_name	varchar;
	v_notification_type	varchar;	v_workflow_url		varchar;
	v_workflow_package_id	integer;

        v_object_name           text;
        v_party_from            parties.party_id%TYPE;
        v_party_to              parties.party_id%TYPE;
        v_subject               text;
        v_body                  text;
        v_request_id            integer;

        v_locale                text;
        v_count                 integer;
	v_assignee_id		integer;

begin
        -- RAISE NOTICE 'im_workflow_notification_simple: enter';

        -- Select out some frequently used variables of the environment
        select  c.object_id, c.workflow_key, co.creation_user, task_id, c.case_id, co.object_type, co.creation_ip, tr.transition_key, tr.transition_name, acs_object__name(c.object_id)
        into    v_object_id, v_workflow_key, v_creation_user, v_task_id, v_case_id, v_object_type, v_creation_ip, v_transition_key, v_transition_name, v_object_name
        from    wf_tasks t, wf_cases c, acs_objects co, wf_transitions tr
        where   c.case_id = p_case_id
                and c.case_id = co.object_id
                and t.case_id = c.case_id
                and t.workflow_key = c.workflow_key
                and t.transition_key = p_transition_key
		and tr.workflow_key = c.workflow_key
		and tr.transition_key = t.transition_key;

        v_party_from := -1;
	v_assignee_id := p_custom_arg;

        -- Get locale of user
        select  language_preference into v_locale
        from    user_preferences
        where   user_id = v_assignee_id;

	-- RAISE NOTICE 'im_workflow_notification_simple: Locale for user_id=%: locale=%:', v_creation_user, v_locale;

	IF v_locale IS NULL THEN
		v_locale := 'en_US';
	END IF; 

        -- ------------------------------------------------------------
        -- Setting SUBJECT
	v_notification_type := 'simple_notif';

        -- ------------------------------------------------------------
        -- Try with specific translation first
	
	v_subject := 'Notification_Subject_' || v_transition_key || '_' || v_notification_type;
	-- RAISE NOTICE 'im_workflow_notification_simple: Try localizing SUBJECT, search string: v_subject=%, locale=% in package acs-workflow', v_subject,v_locale;
	v_subject := acs_lang_lookup_message(v_locale, 'acs-workflow', v_subject);

        -- RAISE NOTICE 'im_workflow_notification_simple: SUBJECT after generic translation: SUBJECT=%', v_subject;
	-- RAISE NOTICE 'im_workflow_notification_simple: SUBJECT Substring: %', substring(v_subject from 1 for 7);

        -- Fallback to generic (no transition key) translation
        IF substring(v_subject from 1 for 7) = 'MISSING' THEN
		-- RAISE NOTICE 'im_workflow_notification_simple: No translation found';
		v_subject := 'You have been assigned to a workflow task';
        END IF;

        RAISE NOTICE 'im_workflow_notification_simple: SUBJECT after generic translation: Body=%', v_subject;

        -- ------------------------------------------------------------
        -- Setting BODY	

	-- get WF URL 
	select 	a.package_id, apm__get_value(p.package_id, 'SystemURL') || site_node__url(s.node_id)
        into 	v_workflow_package_id, v_workflow_url
        from 	site_nodes s, apm_packages a,
		(select package_id
        		from apm_packages 
        		where package_key = 'acs-kernel') p
	where 	s.object_id = a.package_id 
		and a.package_key = 'acs-workflow';
        v_workflow_url := v_workflow_url || 'task?task_id=' || v_task_id;

        -- Try with specific translation first
	v_body := 'Notification_Body_' || v_transition_key || '_' || v_notification_type;
	v_body := acs_lang_lookup_message(v_locale, 'acs-workflow', v_body);

        -- RAISE NOTICE 'im_workflow_notification_simple: BODY after specific translation: Body=%', v_body;

        -- Fallback to generic (no transition key) translation
        IF substring(v_body from 1 for 7) = 'MISSING' THEN
                v_body := 'You have been assigned to a WF task: %object_name% / %transition_name% \n \n %workflow_url%';
        END IF;

        -- RAISE NOTICE 'im_workflow_notification_simple: BODY after generic translation: Body=%', v_body;

        -- Replace variables
        v_body := replace(v_body, '%object_name%', v_object_name);
        v_body := replace(v_body, '%transition_name%', v_transition_name);
        v_body := replace(v_body, '%workflow_url%', v_workflow_url);

        RAISE NOTICE 'im_workflow_notification_simple: After replacing vars: Subject=%, Body=%', v_subject, v_body;

        v_request_id := acs_mail_nt__post_request (
		v_party_from,                 -- party_from
		v_assignee_id,	              -- party_to
		'f',                          -- expand_group
		v_subject,                    -- subject
		v_body,                       -- message
		0                             -- max_retries
        );

        return 0;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE;



CREATE OR REPLACE FUNCTION im_workflow__notification_simple(integer, text)
  RETURNS integer AS
$BODY$
declare
        p_task_id               alias for $1;
        p_custom_arg            alias for $2;
	v_transition_key	text;
	v_case_id		integer;
begin
       	-- Get information about the transition and the "environment"
       	select	tr.transition_key, t.case_id
       	into	v_transition_key, v_case_id 
       	from	wf_tasks t, wf_cases c, wf_transitions tr, acs_objects o
       	where	t.task_id = p_task_id
       		and t.case_id = c.case_id
       		and o.object_id = t.case_id
       		and t.workflow_key = tr.workflow_key
       		and t.transition_key = tr.transition_key;

	PERFORM im_workflow__notification_simple(v_case_id, v_transition_key, p_custom_arg);
        return 0;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE;


