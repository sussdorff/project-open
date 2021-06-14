-- upgrade-4.0.3.0.2-4.0.3.0.3.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-workflow/sql/postgresql/upgrade/upgrade-4.0.3.0.2-4.0.3.0.3.sql','');

CREATE OR REPLACE FUNCTION im_absence_notify_applicant_not_approved(integer, character varying, character varying)
  RETURNS integer AS
$BODY$
declare
        p_case_id               alias for $1;
        p_transition_key        alias for $2;
	p_custom_arg            alias for $3;

        v_task_id               integer;        v_case_id               integer;
        v_creation_ip           varchar;        v_creation_user         integer;
        v_object_id             integer;        v_object_type           varchar;
        v_journal_id            integer;        v_name_creation_user    varchar;
        v_transition_key        varchar;        v_workflow_key          varchar;
        v_group_id              integer;        v_group_name            varchar;
        v_task_owner            integer;

	v_absence_id		integer;

	v_start_date		text;		 
	v_end_date		text;
	v_description		text;

	v_url			text;
	v_base_url		text;

        v_object_name           text;
        v_party_from            parties.party_id%TYPE;
        v_party_to              parties.party_id%TYPE;
        v_subject               text;
        v_body                  text;
        v_request_id            integer;

        v_locale                text;
        v_count                 integer;

begin
        RAISE NOTICE 'im_absence_notify_applicant_not_approved: enter - p_case_id=%, p_transition_key=%, p_custom_arg=%', p_case_id, p_transition_key, p_custom_arg;

        -- Select out some frequently used variables of the environment
        select  c.object_id, c.workflow_key, co.creation_user, task_id, c.case_id, co.object_type, co.creation_ip
        into    v_object_id, v_workflow_key, v_creation_user, v_task_id, v_case_id, v_object_type, v_creation_ip
        from    wf_tasks t, wf_cases c, acs_objects co
        where   c.case_id = p_case_id
                and c.case_id = co.object_id
                and t.case_id = c.case_id
                and t.workflow_key = c.workflow_key
                and t.transition_key = p_transition_key;

        v_party_from := -1;

        -- Get locale of user
        select  locale into v_locale
        from    user_preferences
        where   user_id = v_creation_user;

	IF v_locale IS NULL THEN
		v_locale := 'en_US';
	END IF; 

        -- ------------------------------------------------------------
        -- Try with specific translation first
        v_subject := 'Notification_Subject_Notify_Applicant_Absence_Not_Approved';
        v_subject := acs_lang_lookup_message(v_locale, 'intranet-timesheet2', v_subject);

        -- Fallback to generic (no transition key) translation
        IF substring(v_subject from 1 for 7) = 'MISSING' THEN
                v_subject := 'Your application for an absence';
        END IF;

        -- Replace variables
        -- v_subject := replace(v_subject, '%object_name%', v_object_name);
        -- v_subject := replace(v_subject, '%transition_name%', v_transition_name);

        -- ------------------------------------------------------------
        -- Try with specific translation first
        v_body := 'Notification_Body_Notify_Applicant_Absence_Not_Approved';
        v_body := acs_lang_lookup_message(v_locale, 'intranet-timesheet2', v_body);

        -- Fallback to generic (no transition key) translation
        IF substring(v_body from 1 for 7) = 'MISSING' THEN
                v_body := 'Your application for an absence has not been approved:';
        END IF;

        -- Replace variables
        -- v_body := replace(v_body, '%object_name%', v_object_name);
        -- v_body := replace(v_body, '%transition_name%', v_transition_name);

	-- get absence_id 
	select object_id into v_absence_id from wf_cases where case_id = p_case_id; 

	-- get URL of absence
	select 	attr_value 
	into 	v_base_url 
	from 
		apm_parameter_values pv,
		apm_parameters p
	where 
                p.package_key = 'acs-kernel' and
                p.parameter_name = 'SystemURL' and
                pv.parameter_id = p.parameter_id;

	v_url := v_base_url || 'intranet-timesheet2/absences/new?form_mode=display&absence_id=' || v_absence_id;

	-- get info about absence 
       	select
                to_char(start_date,'YYYY-MM-DD'),
                to_char(end_date,'YYYY-MM-DD'),
		COALESCE(v_description, '(none)')
       	into v_start_date, v_end_date, v_description
       	from im_user_absences where absence_id = v_absence_id;

	v_body := v_body || '\n\n' || v_start_date || '-' || v_end_date || ': ' || v_description || '\n' || v_url || '\n\n';	
	v_party_to := v_creation_user;

	-- Custom argument might contain user_id different from owner
	-- Notification to HR   	
	if p_custom_arg <> '' THEN
		select into v_name_creation_user im_name_from_id(v_creation_user);
		v_subject := v_subject || ' ' || v_name_creation_user;
		v_party_to := p_custom_arg;	
	END IF;

        RAISE NOTICE 'im_absence_notify_applicant_not_approved: Subject=%, Body=%', v_subject, v_body;

        v_request_id := acs_mail_nt__post_request (
		v_party_from,                 -- party_from
		v_party_to,                   -- party_to
		'f',                          -- expand_group
		v_subject,                    -- subject
		v_body,                       -- message
		0                             -- max_retries
        );
        return 0;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE;




CREATE OR REPLACE FUNCTION im_absence_notify_applicant_approved(integer, character varying, character varying)
  RETURNS integer AS
$BODY$
declare
        p_case_id               alias for $1;
        p_transition_key        alias for $2;
	p_custom_arg            alias for $3;

        v_task_id               integer;        v_case_id               integer;
        v_creation_ip           varchar;        v_creation_user         integer;
        v_object_id             integer;        v_object_type           varchar;
        v_journal_id            integer;	v_name_creation_user    varchar;
        v_transition_key        varchar;        v_workflow_key          varchar;
        v_group_id              integer;        v_group_name            varchar;
        v_task_owner            integer;

	v_absence_id		integer;

	v_start_date		text;		 
	v_end_date		text;
	v_description		text;

	v_url			text;
	v_base_url		text;

        v_object_name           text;
        v_party_from            parties.party_id%TYPE;
        v_party_to              parties.party_id%TYPE;
        v_subject               text;
        v_body                  text;
        v_request_id            integer;

        v_locale                text;
        v_count                 integer;

begin
        RAISE NOTICE 'im_absence_notify_applicant_approved: enter - p_case_id=%, p_transition_key=%, p_custom_arg=%', p_case_id, p_transition_key, p_custom_arg;

        -- Select out some frequently used variables of the environment
        select  c.object_id, c.workflow_key, co.creation_user, task_id, c.case_id, co.object_type, co.creation_ip
        into    v_object_id, v_workflow_key, v_creation_user, v_task_id, v_case_id, v_object_type, v_creation_ip
        from    wf_tasks t, wf_cases c, acs_objects co
        where   c.case_id = p_case_id
                and c.case_id = co.object_id
                and t.case_id = c.case_id
                and t.workflow_key = c.workflow_key
                and t.transition_key = p_transition_key;

        v_party_from := -1;

        -- Get locale of user
        select  locale into v_locale
        from    user_preferences
        where   user_id = v_creation_user;

        IF v_locale IS NULL THEN
                v_locale := 'en_US';
        END IF;

        -- ------------------------------------------------------------
        -- Try with specific translation first
        v_subject := 'Notification_Subject_Notify_Applicant_Absence_Approved';
        v_subject := acs_lang_lookup_message(v_locale, 'intranet-timesheet2', v_subject);

        -- Fallback to generic (no transition key) translation
        IF substring(v_subject from 1 for 7) = 'MISSING' THEN
                v_subject := 'Your application for an absence:';
        END IF;

        -- Replace variables
        -- v_subject := replace(v_subject, '%object_name%', v_object_name);
        -- v_subject := replace(v_subject, '%transition_name%', v_transition_name);

        -- ------------------------------------------------------------
        -- Try with specific translation first
        v_body := 'Notification_Body_Notify_Applicant_Absence_Approved';
        v_body := acs_lang_lookup_message(v_locale, 'intranet-timesheet2', v_body);

        -- Fallback to generic (no transition key) translation
        IF substring(v_body from 1 for 7) = 'MISSING' THEN
                v_body := 'Your application for an absence has been approved';
        END IF;

        -- Replace variables
        -- v_body := replace(v_body, '%object_name%', v_object_name);
        -- v_body := replace(v_body, '%transition_name%', v_transition_name);

	-- get absence_id 
	select object_id into v_absence_id from wf_cases where case_id = p_case_id; 

	-- get URL of absence
	select 	attr_value 
	into 	v_base_url 
	from 
		apm_parameter_values pv,
		apm_parameters p
	where 
		p.package_key = 'acs-kernel' and
		p.parameter_name = 'SystemURL' and 
		pv.parameter_id = p.parameter_id; 

	v_url := v_base_url || 'intranet-timesheet2/absences/new?form_mode=display&absence_id=' || v_absence_id;

        -- get info about absence
        select
                to_char(start_date,'YYYY-MM-DD'),
                to_char(end_date,'YYYY-MM-DD'),
                COALESCE(v_description, '(none)')
        into v_start_date, v_end_date, v_description
        from im_user_absences where absence_id = v_absence_id;

        -- v_body := v_body || '\n\n' || v_description || '\n\n' || v_start_date || '\n\n' || v_end_date || '\n\n' || v_url || '\n\n';
        v_body := v_body || '\n\n' || v_start_date || '-' || v_end_date || ': ' || v_description || '\n' || v_url || '\n\n';
        v_party_to := v_creation_user;

        -- Custom argument might contain user_id different from owner
        -- Notification to HR
        if p_custom_arg <> '' THEN
                select into v_name_creation_user im_name_from_id(v_creation_user);
                v_subject := v_subject || ' ' || v_name_creation_user;
                v_party_to := p_custom_arg;
        END IF;

        RAISE NOTICE 'im_absence_notify_applicant_not_approved: Subject=%, Body=%', v_subject, v_body;

        v_request_id := acs_mail_nt__post_request (
                v_party_from,                 -- party_from
                v_party_to,                   -- party_to
                'f',                          -- expand_group
                v_subject,                    -- subject
                v_body,                       -- message
                0                             -- max_retries
        );
        return 0;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE;
