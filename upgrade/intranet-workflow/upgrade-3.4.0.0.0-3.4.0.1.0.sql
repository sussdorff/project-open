-- upgrade-3.3.1.1..0-3.3.1.2.0.sql

SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-3.4.0.0.0-3.4.0.1.0.sql','');




-- Returns a string with comma separated names of users/parties
-- assigned to the current task
create or replace function im_workflow_task_assignee_names (integer)
returns varchar as '
DECLARE
	p_task_id	alias for $1;
        row             RECORD;
        v_result	varchar;
BEGIN
     v_result := '''';

     FOR row IN
	select	acs_object__name(wta.party_id) as party_name
	from	wf_task_assignments wta
	where	wta.task_id = p_task_id
     loop
        v_result := v_result || '' '' || row.party_name;
     end loop;

     return v_result;
end;' language 'plpgsql';



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

	v_str					varchar;
	v_custom_arg				varchar;
	v_deadline_pretty                       varchar;  
	v_object_name                           text; 
	v_transition_key                        wf_transitions.transition_key%TYPE;
	v_transition_name                       wf_transitions.transition_name%TYPE;
	v_party_from                            parties.party_id%TYPE;
	v_party_to                              parties.party_id%TYPE;
	v_subject                               text; 
	v_body                                  text; 
	v_request_id                            integer; 
	v_workflow_url			  text;
	v_acs_lang_package_id			  integer;

	v_notification_type			  varchar;
	v_notification_type_id		  integer;
	v_workflow_package_id			  integer;
	v_notification_n_seconds		  integer;
	v_locale				  text;
	v_count				  integer;
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

	v_custom_arg := notify_assignee__custom_arg;
	IF v_custom_arg is null THEN v_custom_arg := ''null''; END IF;

	IF length(notify_assignee__callback) > 0 and notify_assignee__callback is not null THEN

		v_str :=  ''select '' || notify_assignee__callback || '' ('' ||
		      notify_assignee__task_id || '','' ||
		      quote_literal(v_custom_arg) || '','' ||
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




-- ------------------------------------------------------
-- Privileges
-- ------------------------------------------------------

select acs_privilege__create_privilege('wf_reassign_tasks','Reassign tasks to other users','');
select acs_privilege__add_child('admin', 'wf_reassign_tasks');

select im_priv_create('wf_reassign_tasks','Accounting');
select im_priv_create('wf_reassign_tasks','P/O Admins');
select im_priv_create('wf_reassign_tasks','Senior Managers');


-- ------------------------------------------------------
-- Update Project/Task types with Workflow types
-- ------------------------------------------------------

update im_categories
set category_description = 'trans_edit_wf'
where category_id = 87;

update im_categories
set category_description = 'edit_only_wf'
where category_id = 88;

update im_categories
set category_description = 'trans_edit_proof_wf'
where category_id = 89;

update im_categories
set category_description = 'localization_wf'
where category_id = 91;

update im_categories
set category_description = 'trans_only_wf'
where category_id = 93;

update im_categories
set category_description = 'trans_spotcheck_wf'
where category_id = 94;

update im_categories
set category_description = 'proof_only_wf'
where category_id = 95;

update im_categories
set category_description = 'glossary_compilation_wf'
where category_id = 96;


-- ------------------------------------------------------
-- Components
-- ------------------------------------------------------

-- Show the workflow component in project page
--
SELECT im_component_plugin__new (
        null,                           -- plugin_id
        'im_component_plugin',                   -- object_type
        now(),                          -- creation_date
        null,                           -- creation_user
        null,                           -- creation_ip
        null,                           -- context_id
        'Home Workflow Component',      -- plugin_name
        'intranet-workflow',            -- package_name
        'left',                         -- location
        '/intranet/index',              -- page_url
        null,                           -- view_name
        1,                              -- sort_order
	'im_workflow_home_component'
);

-- Project WF Display
--
SELECT im_component_plugin__new (
        null,                           -- plugin_id
        'im_component_plugin',                   -- object_type
        now(),                          -- creation_date
        null,                           -- creation_user
        null,                           -- creation_ip
        null,                           -- context_id
        'Project Workflow Graph',       -- plugin_name
        'intranet-workflow',            -- package_name
        'right',                        -- location
        '/intranet/projects/view',     -- page_url
        null,                           -- view_name
        20,                              -- sort_order
        'im_workflow_graph_component -object_id $project_id'
);


-- Project WF Journal
--
SELECT im_component_plugin__new (
        null,                           -- plugin_id
        'im_component_plugin',                   -- object_type
        now(),                          -- creation_date
        null,                           -- creation_user
        null,                           -- creation_ip
        null,                           -- context_id
        'Project Workflow Journal',     -- plugin_name
        'intranet-workflow',            -- package_name
        'bottom',                       -- location
        '/intranet/projects/view',      -- page_url
        null,                           -- view_name
        60,                             -- sort_order
        'im_workflow_journal_component -object_id $project_id'
);


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





-- ------------------------------------------------------
-- Menus
-- ------------------------------------------------------

create or replace function inline_0 ()
returns integer as '
declare

        v_menu                  integer;
        v_main_menu             integer;
        v_employees             integer;
        v_companies             integer;
        v_freelancers           integer;
BEGIN
    select group_id into v_employees from groups where group_name = ''Employees'';
    select group_id into v_companies from groups where group_name = ''Customers'';
    select group_id into v_freelancers from groups where group_name = ''Freelancers'';

    select menu_id into v_main_menu from im_menus where label=''main'';

    v_menu := im_menu__new (
        null,                   -- p_menu_id
        ''im_menu'',         -- object_type
        now(),                  -- creation_date
        null,                   -- creation_user
        null,                   -- creation_ip
        null,                   -- context_id
        ''intranet-workflow'',  -- package_name
        ''workflow'',           -- label
        ''Workflow'',           -- name
        ''/intranet-workflow/'',-- url
        50,                     -- sort_order
        v_main_menu,            -- parent_menu_id
        null                    -- p_visible_tcl
    );

    PERFORM acs_permission__grant_permission(v_menu, v_employees, ''read'');
    PERFORM acs_permission__grant_permission(v_menu, v_companies, ''read'');
    PERFORM acs_permission__grant_permission(v_menu, v_freelancers, ''read'');

    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();








--------------------------------------------------------------
-- Workflow Views
--
-- Views reserved for workflow: 260-269

delete from im_view_columns where view_id >= 260 and view_id <= 269;
delete from im_views where view_id >= 260 and view_id <= 269;

--------------------------------------------------------------
-- Home Inbox View
insert into im_views (view_id, view_name, visible_for) 
values (260, 'workflow_home_inbox', '');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (26000,260,'Action','"<a class=button href=$action_url>$next_action_l10n</a>"',0);

-- insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
-- values (26010,260,'Object Type','"$object_type_pretty"',10);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (26020,260,'Type','"$object_subtype"',20);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (26030,260,'Status','"$status"',30);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (26040,260,'Assignee','"$assignee_pretty"',40);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (26050,260,'Owner','"<a href=$owner_url>$owner_name</a>"',45);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (26060,260,'Object Name','"<a href=$object_url>$object_name</a>"',60);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (26070,260,'Relationship','"$relationship_l10n"',70);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (26090,260,
	'<input type=checkbox onclick="acs_ListCheckAll(''action'',this.checked)">',
	'"<input type=checkbox name=task_id value=$task_id id=action,$task_id>"',
90);


create or replace function im_workflow_task_assignee_names (integer)
returns varchar as '
DECLARE
        p_task_id       alias for $1;
        row             RECORD;
        v_result        varchar;
BEGIN
     v_result := '''';

     FOR row IN
        select  acs_object__name(wta.party_id) as party_name
        from    wf_task_assignments wta
        where   wta.task_id = p_task_id
     loop
        v_result := v_result || '' '' || row.party_name;
     end loop;

     return v_result;
end;' language 'plpgsql';

