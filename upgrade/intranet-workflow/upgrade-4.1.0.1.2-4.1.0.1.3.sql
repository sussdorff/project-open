-- upgrade-4.1.0.1.2-4.1.0.1.3.sql
SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-4.1.0.1.2-4.1.0.1.3.sql','');

-- Send out notification emails to assignees of workflow transitions
create or replace function workflow_case__notify_assignee (integer,integer,varchar,varchar,varchar)
returns integer as $$
declare
	notify_assignee__task_id		alias for $1;
	notify_assignee__user_id		alias for $2;
	notify_assignee__callback		alias for $3;
	notify_assignee__custom_arg		alias for $4;
	notify_assignee__notification_type	alias for $5;

	v_deadline_pretty			varchar;  
	v_object_name				text; 
	v_workflow_key				varchar;
	v_transition_key			wf_transitions.transition_key%TYPE;
	v_transition_name			wf_transitions.transition_name%TYPE;
	v_party_from				parties.party_id%TYPE;
	v_party_to				parties.party_id%TYPE;
	v_subject				text; 
	v_body					text; 
	v_request_id				integer; 
	v_workflow_url				text;
	v_acs_lang_package_id			integer;
	v_notifications_installed_p		integer;

	v_custom_arg				varchar;
	v_notification_type			varchar;
	v_notification_type_id			integer;
	v_workflow_package_id			integer;
	v_notification_n_seconds		integer;
	v_locale				text;
	v_str					varchar;
	v_user_first_names			varchar;
	v_user_last_name			varchar;
begin
	-- Default notification type
	v_notification_type := notify_assignee__notification_type;
	IF v_notification_type is null THEN
		v_notification_type := 'wf_assignment_notif';
	END IF;

	-- Get information about the workflow context into variables
	select	to_char(ta.deadline,'Mon fmDDfm, YYYY HH24:MI:SS'),
		acs_object__name(c.object_id), ta.workflow_key, tr.transition_key, tr.transition_name
	into	v_deadline_pretty, v_object_name, v_workflow_key, v_transition_key, v_transition_name
	from	wf_tasks ta, wf_transitions tr, wf_cases c
	where	ta.task_id = notify_assignee__task_id and
		c.case_id = ta.case_id and
		tr.workflow_key = c.workflow_key and
		tr.transition_key = ta.transition_key;

	select	a.package_id, apm__get_value(p.package_id, 'SystemURL') || site_node__url(s.node_id)
	into	v_workflow_package_id, v_workflow_url
	from	site_nodes s, apm_packages a,
		(select package_id
		from apm_packages 
		where package_key = 'acs-kernel') p
	where	s.object_id = a.package_id and
		a.package_key = 'acs-workflow';
	v_workflow_url := v_workflow_url || 'task?task_id=' || notify_assignee__task_id;

	select	pe.first_names, pe.last_name
	into	v_user_first_names, v_user_last_name
	from	persons pe
	where	pe.person_id = notify_assignee__user_id;

	RAISE NOTICE 'workflow_case__notify_assignee: task_id=%, user_id=%, obj=%, wf=%, trans=%',
	      notify_assignee__task_id, notify_assignee__user_id, v_object_name, v_workflow_key, v_transition_key;

	select	wfi.principal_party 
	into	v_party_from
	from	wf_context_workflow_info wfi, wf_tasks ta, wf_cases c
	where	ta.task_id = notify_assignee__task_id and
		c.case_id = ta.case_id and 
		wfi.workflow_key = c.workflow_key and
		wfi.context_key = c.context_key;
	if NOT FOUND then v_party_from := -1; end if;

	-- Check whether the "notifications" package is installed and get
	-- the notification interval of the user.
	select	count(*) into v_notifications_installed_p 
	from	user_tab_columns
	where	lower(table_name) = 'notifications';
	IF v_notifications_installed_p > 0 THEN

		-- Notification Type is a kind of "channel" where to spread notifics
		select	type_id into v_notification_type_id
		from	notification_types
		where	short_name = v_notification_type;

		-- Check if the user is "subscribed" to these notifications
		select	n_seconds into v_notification_n_seconds
		from	notification_requests r,
			notification_intervals i
		where	r.interval_id = i.interval_id
			and user_id = notify_assignee__user_id
			and object_id = v_workflow_package_id
			and type_id = v_notification_type_id;

		-- Skip notification if there are no notifications defined
		IF v_notification_n_seconds is null THEN return 0; END IF;

	END IF;

	-- Get the System Locale
	select	package_id into	v_acs_lang_package_id
	from	apm_packages
	where	package_key = 'acs-lang';
	v_locale := apm__get_value(v_acs_lang_package_id, 'SiteWideLocale');

	-- make sure there are no null values - replaces(...,null) returns null...
	IF v_deadline_pretty is NULL THEN v_deadline_pretty := 'undefined'; END IF;
	IF v_workflow_url is NULL THEN v_workflow_url := 'undefined'; END IF;

	-- ------------------------------------------------------------
	-- Lookup message and substitute
	v_subject := workflow_case__notify_l10n_lookup ('Notification_Subject', v_notification_type, v_workflow_key, v_transition_key, v_locale, 0);
	v_subject := replace(v_subject, '%object_name%', v_object_name);
	v_subject := replace(v_subject, '%transition_name%', v_transition_name);
	v_subject := replace(v_subject, '%deadline%', v_deadline_pretty);

	v_body := workflow_case__notify_l10n_lookup ('Notification_Body', v_notification_type, v_workflow_key, v_transition_key, v_locale, 1);
	v_body := replace(v_body, '%deadline%', v_deadline_pretty);
	v_body := replace(v_body, '%object_name%', v_object_name);
	v_body := replace(v_body, '%transition_name%', v_transition_name);
	v_body := replace(v_body, '%workflow_url%', v_workflow_url);
	v_body := replace(v_body, '%first_names%', v_user_first_names);
	v_body := replace(v_body, '%last_name%', v_user_last_name);
	v_body := replace(v_body, '%user_first_names%', v_user_first_names);
	v_body := replace(v_body, '%user_last_name%', v_user_last_name);

	RAISE NOTICE 'workflow_case__notify_assignee: User=%, Subject=%, Body=%', v_user_first_names || ' ' || v_user_last_name, v_subject, v_body;

	v_custom_arg := notify_assignee__custom_arg;
	IF v_custom_arg is null THEN v_custom_arg := 'null'; END IF;

	if notify_assignee__callback != '' and notify_assignee__callback is not null then
		v_str := 'select ' || notify_assignee__callback || ' (' ||
			notify_assignee__task_id || ',' ||
			quote_literal(v_custom_arg) || ',' ||
			notify_assignee__user_id || ',' ||
			v_party_from || ',' ||
			quote_literal(v_subject) || ',' ||
			quote_literal(v_body) || ')';
		execute v_str;
	else
		v_request_id := acs_mail_nt__post_request (
			v_party_from,				-- party_from
			notify_assignee__user_id,		-- party_to
			'f',					-- expand_group
			v_subject,				-- subject
			v_body,					-- message
			0					-- max_retries
		);
	end if;

	return 0; 
end;$$ language 'plpgsql';


-- SELECT im_lang_add_message('en_US','acs-workflow','Task_Has_Not_Been_Started_Yet','This task has not been started yet.');

