-- upgrade-3.3.1.1.0-3.3.1.2.0.sql

SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-3.3.1.1.0-3.3.1.2.0.sql','');


-- Home Inbox Component
SELECT  im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',				-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'Home Workflow Inbox',			-- plugin_name
	'intranet-workflow',			-- package_name
	'right',				-- location
	'/intranet/index',			-- page_url
	null,					-- view_name
	150,					-- sort_order
	'im_workflow_home_inbox_component'	-- component_tcl
);


-- Compatibility proc - to maintain API
create or replace function workflow_case__notify_assignee (integer,integer,varchar,varchar)
returns integer as '
declare
	notify_assignee__task_id                alias for $1;  
	notify_assignee__user_id                alias for $2;  
	notify_assignee__callback               alias for $3;  
	notify_assignee__custom_arg             alias for $4;  
begin
	return workflow_case__notify_assignee($1,$2,$3,$4,null);
end;' language 'plpgsql';


-- procedure notify_assignee
create or replace function workflow_case__notify_assignee (integer,integer,varchar,varchar,varchar)
returns integer as '
declare
	notify_assignee__task_id                alias for $1;
	notify_assignee__user_id                alias for $2;
	notify_assignee__callback               alias for $3;
	notify_assignee__custom_arg             alias for $4;
	notify_assignee__notification_type      alias for $5;

	v_deadline_pretty                       varchar;  
	v_object_name                           text; 
	v_transition_key                        wf_transitions.transition_key%TYPE;
	v_transition_name                       wf_transitions.transition_name%TYPE;
	v_party_from                            parties.party_id%TYPE;
	v_party_to                              parties.party_id%TYPE;
	v_subject                               text; 
	v_body                                  text; 
	v_request_id                            integer; 
	v_workflow_url				text;
	v_acs_lang_package_id			integer;

	v_notification_type			varchar;
	v_notification_type_id			integer;
	v_workflow_package_id			integer;
	v_notification_n_seconds		integer;
	v_locale				text;
	v_str					text;
	v_count					integer;
begin
		-- Default notification type
		v_notification_type := notify_assignee__notification_type;
		IF v_notification_type is null THEN
		  v_notification_type := ''wf_assignment_notif'';
		END IF;

	select to_char(ta.deadline,''Mon fmDDfm, YYYY HH24:MI:SS''),
		   acs_object__name(c.object_id), tr.transition_key, tr.transition_name
	into   v_deadline_pretty, v_object_name, v_transition_key, v_transition_name
	  from wf_tasks ta, wf_transitions tr, wf_cases c
	 where ta.task_id = notify_assignee__task_id
	   and c.case_id = ta.case_id
	   and tr.workflow_key = c.workflow_key
	   and tr.transition_key = ta.transition_key;

	select a.package_id, apm__get_value(p.package_id, ''SystemURL'') || site_node__url(s.node_id)
	  into v_workflow_package_id, v_workflow_url
	  from site_nodes s, apm_packages a,
		   (select package_id
		from apm_packages 
		where package_key = ''acs-kernel'') p
	 where s.object_id = a.package_id 
	   and a.package_key = ''acs-workflow'';
	v_workflow_url := v_workflow_url || ''task?task_id='' || notify_assignee__task_id;

	  select wfi.principal_party into v_party_from
		from wf_context_workflow_info wfi, wf_tasks ta, wf_cases c
	   where ta.task_id = notify_assignee__task_id
		 and c.case_id = ta.case_id
		 and wfi.workflow_key = c.workflow_key
		 and wfi.context_key = c.context_key;
	if NOT FOUND then v_party_from := -1; end if;

	-- Check whether the "notifications" package is installed and get
	-- the notification interval of the user.
	select count(*) into v_count 
	from user_tab_columns
	where lower(table_name) = ''notifications'';
	IF v_count > 0 THEN

		-- Notification Type is a kind of "channel" where to spread notifics
		select type_id into v_notification_type_id
		from notification_types
		where short_name = v_notification_type;

		-- Check the 
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
	where	package_key = ''acs-lang'';
	v_locale := apm__get_value (v_acs_lang_package_id, ''SiteWideLocale'');

	-- make sure there are no null values - replaces(...,null) returns null...
	IF v_deadline_pretty is NULL THEN v_deadline_pretty := ''undefined''; END IF;
	IF v_workflow_url is NULL THEN v_workflow_url := ''undefined''; END IF;

	-- ------------------------------------------------------------
	-- Try with specific translation first
	v_subject := ''Notification_Subject_'' || v_transition_key || ''_'' || v_notification_type;
	v_subject := acs_lang_lookup_message(v_locale, ''acs-workflow'', v_subject);

	-- Fallback to generic (no transition key) translation
	IF substring(v_subject from 1 for 7) = ''MISSING'' THEN
		v_subject := ''Notification_Subject_'' || v_transition_key;
		v_subject := acs_lang_lookup_message(v_locale, ''acs-workflow'', v_subject);
	END IF;
	
	-- Replace variables
	v_subject := replace(v_subject, ''%object_name%'', v_object_name);
	v_subject := replace(v_subject, ''%transition_name%'', v_transition_name);
	v_subject := replace(v_subject, ''%deadline%'', v_deadline_pretty);

	-- ------------------------------------------------------------
	-- Try with specific translation first
	v_body := ''Notification_Body_'' || v_transition_key || ''_'' || v_notification_type;
	v_body := acs_lang_lookup_message(v_locale, ''acs-workflow'', v_body);

	-- Fallback to generic (no transition key) translation
	IF substring(v_body from 1 for 7) = ''MISSING'' THEN
		v_body := ''Notification_Body_'' || v_transition_key;
		v_body := acs_lang_lookup_message(v_locale, ''acs-workflow'', v_body);
	END IF;

	-- Replace variables
	v_body := replace(v_body, ''%object_name%'', v_object_name);
	v_body := replace(v_body, ''%transition_name%'', v_transition_name);
	v_body := replace(v_body, ''%deadline%'', v_deadline_pretty);
	v_body := replace(v_body, ''%workflow_url%'', v_workflow_url);

	RAISE NOTICE ''workflow_case__notify_assignee: Subject=%, Body=%'', v_subject, v_body;

	IF notify_assignee__callback != '''' AND notify_assignee__callback is not null THEN

		v_str :=  ''select '' || notify_assignee__callback || '' ('' ||
		      notify_assignee__task_id || '','' ||
		      coalesce(quote_literal(notify_assignee__custom_arg),''null'') ||
		      '','' ||
		      notify_assignee__user_id || '','' ||
		      v_party_from || '','' ||
		      quote_literal(v_subject) || '','' ||
		      quote_literal(v_body) || '')'';

		execute v_str;

	else
		v_request_id := acs_mail_nt__post_request (
			v_party_from,                 -- party_from
			notify_assignee__user_id,     -- party_to
			''f'',                        -- expand_group
			v_subject,                    -- subject
			v_body,                       -- message
			0                             -- max_retries
		);
	end if;

	return 0; 
end;' language 'plpgsql';

