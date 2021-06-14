-- upgrade-4.0.3.0.4-4.0.3.0.5.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-workflow/sql/postgresql/upgrade/upgrade-4.0.3.0.4-4.0.3.0.5.sql','');

CREATE OR REPLACE FUNCTION im_ts_notify_applicant_not_approved(integer, character varying, character varying)
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

	v_description		text;

	v_project_nr 		text;		v_project_name          text;
	v_project_manager	text;

	v_project_nr_label 	text;		v_project_name_label    text;
	v_project_manager_label	text;
	
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
        RAISE NOTICE 'im_ts_notify_applicant_not_approved: enter - p_case_id=%, p_transition_key=%, p_custom_arg=%', p_case_id, p_transition_key, p_custom_arg;

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
        v_subject := acs_lang_lookup_message(v_locale, 'intranet-timesheet2-workflow', 'Notification_Subject_Notify_Applicant_TS_Not_Approved');

        -- Fallback to generic (no transition key) translation
        IF substring(v_subject from 1 for 7) = 'MISSING' THEN
                v_subject := 'Notification about your Timesheet Approval Workflow';
        END IF;

        -- ------------------------------------------------------------
        -- Try with specific translation first
        v_body := acs_lang_lookup_message(v_locale, 'intranet-timesheet2-workflow','Notification_Body_Notify_Applicant_TS_Not_Approved');
        RAISE NOTICE 'im_ts_notify_applicant_not_approved: Body=%', v_body;

        -- Fallback to generic (no transition key) translation
        IF substring(v_body from 1 for 7) = 'MISSING' THEN
                v_body := 'Your hours logged hours have not been approved:';
        END IF;

        -- get project_name, project_nr und PM 
	select 
		p.project_nr,
		p.project_name,
		im_name_from_id(p.project_lead_id)
	into
		v_project_nr,
		v_project_name,
		v_project_manager 
	from 
		im_projects p, 
		wf_cases c, 
		im_timesheet_conf_objects co
	where 
                c.case_id = p_case_id and
		c.object_id = co.conf_id and  
                co.conf_project_id = p.project_id
	;

	-- get labels 
	v_project_nr_label := acs_lang_lookup_message(v_locale, 'intranet-core', 'Project_Nr');
	v_project_name_label := acs_lang_lookup_message(v_locale, 'intranet-core', 'Project_Name');
	v_project_manager_label := acs_lang_lookup_message(v_locale, 'intranet-core', 'Project_Manager');	
		
	-- get Base URL
	select 	attr_value 
	into 	v_base_url 
	from 
		apm_parameter_values pv,
		apm_parameters p
	where 
                p.package_key = 'acs-kernel' and
                p.parameter_name = 'SystemURL' and
                pv.parameter_id = p.parameter_id;

	v_url := v_base_url || 'acs-workflow/task?return_url=%2fintranet%2f&task_id=' || v_task_id;
	 
	v_body := v_body || '\n\n' || v_project_nr_label || ': ' || v_project_nr || '\n';
	v_body := v_body || v_project_name_label || ': ' || v_project_name || '\n';
	v_body := v_body || v_project_manager_label || ': ' || v_project_manager || '\n\n';
 	v_body := v_body || v_url || '\n\n';	

	v_party_to := v_creation_user;

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



CREATE OR REPLACE FUNCTION im_ts_notify_applicant_approved(integer, character varying, character varying)
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

	v_description		text;

	v_project_nr 		text;		v_project_name          text;
	v_project_manager	text;

	v_project_nr_label 	text;		v_project_name_label    text;
	v_project_manager_label	text;
	
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
        RAISE NOTICE 'im_ts_notify_applicant_approved: enter - p_case_id=%, p_transition_key=%, p_custom_arg=%', p_case_id, p_transition_key, p_custom_arg;

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
        v_subject := acs_lang_lookup_message(v_locale, 'intranet-timesheet2-workflow', 'Notification_Subject_Notify_Applicant_TS_Approved');

        -- Fallback to generic (no transition key) translation
        IF substring(v_subject from 1 for 7) = 'MISSING' THEN
                v_subject := 'Notification about your Timesheet Approval Workflow';
        END IF;

        -- ------------------------------------------------------------
        -- Try with specific translation first
        v_body := acs_lang_lookup_message(v_locale, 'intranet-timesheet2-workflow','Notification_Body_Notify_Applicant_TS_Approved');

        -- Fallback to generic (no transition key) translation
        IF substring(v_body from 1 for 7) = 'MISSING' THEN
                v_body := 'Your hours logged hours have been approved:';
        END IF;

        -- get project_name, project_nr und PM 
	select 
		p.project_nr,
		p.project_name,
		im_name_from_id(p.project_lead_id)
	into
		v_project_nr,
		v_project_name,
		v_project_manager 
	from 
		im_projects p, 
		wf_cases c, 
		im_timesheet_conf_objects co
	where 
                c.case_id = p_case_id and
		c.object_id = co.conf_id and  
                co.conf_project_id = p.project_id
	;

	-- get labels 
	v_project_nr_label := acs_lang_lookup_message(v_locale, 'intranet-core', 'Project_Nr');
	v_project_name_label := acs_lang_lookup_message(v_locale, 'intranet-core', 'Project_Name');
	v_project_manager_label := acs_lang_lookup_message(v_locale, 'intranet-core', 'Project_Manager');	
		

	-- get Base URL
	select 	attr_value 
	into 	v_base_url 
	from 
		apm_parameter_values pv,
		apm_parameters p
	where 
                p.package_key = 'acs-kernel' and
                p.parameter_name = 'SystemURL' and
                pv.parameter_id = p.parameter_id;

	v_url := v_base_url || 'acs-workflow/task?return_url=%2fintranet%2f&task_id=' || v_task_id;
	 
	v_body := v_body || '\n\n' || v_project_nr_label || ': ' || v_project_nr || '\n';
	v_body := v_body || v_project_name_label || ': ' || v_project_name || '\n';
	v_body := v_body || v_project_manager_label || ': ' || v_project_manager || '\n\n';
 	v_body := v_body || v_url || '\n\n';	

	v_party_to := v_creation_user;

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

