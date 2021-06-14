-- upgrade-3.4.0.7.7-3.4.0.7.8.sql

SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-3.4.0.7.7-3.4.0.7.8.sql','');


-- ------------------------------------------------------
-- Callback functions for Workflow
-- ------------------------------------------------------

-- Enable callback that skips (fires) the transition if the underlying WF object 
-- has the specified status.
-- This callback is used for example to bypass a workflow if the object is already
-- approved.
--
create or replace function im_workflow__skip_on_status_id (integer, text, text)
returns integer as '
declare
	p_case_id		alias for $1;
	p_transition_key	alias for $2;
	p_custom_arg		alias for $3;

	v_task_id		integer;
	v_case_id		integer;
	v_object_id		integer;
	v_creation_user		integer;
	v_creation_ip		varchar;
	v_journal_id		integer;
	v_transition_key	varchar;
	v_workflow_key		varchar;

	v_status_id		varchar;
begin
	-- Select out some frequently used variables of the environment
	select	c.object_id, c.workflow_key, c.creation_ip, task_id, c.case_id, 
		im_biz_object__get_status_id(c.object_id)
	into	v_object_id, v_workflow_key, v_creation_ip, v_task_id, v_case_id,
		v_status_id
	from	wf_tasks t, wf_cases c
	where	c.case_id = p_case_id
		and t.case_id = c.case_id
		and t.workflow_key = c.workflow_key
		and t.transition_key = p_transition_key;

	IF v_status_id = p_custom_arg::integer THEN
		v_journal_id := journal_entry__new(
		    null, v_case_id,
		    v_transition_key || '' skipping because of status '' || im_category_from_id(v_status_id),
		    v_transition_key || '' skipping because of status '' || im_category_from_id(v_status_id),
		    now(), v_creation_user, v_creation_ip,
		    ''Skipping transition with status: '' || im_category_from_id(v_status_id)
		);
		-- Consume tokens from incoming places and put out tokens to outgoing places
		PERFORM workflow_case__fire_transition_internal (v_task_id, v_journal_id);
	END IF;
	return 0;
end;' language 'plpgsql';


-- Enable callback that sets the status of the underlying object
--
create or replace function im_workflow__set_object_status_id (integer, text, text)
returns integer as '
declare
	p_case_id		alias for $1;
	p_transition_key	alias for $2;
	p_custom_arg		alias for $3;
	v_task_id		integer;	v_case_id		integer;
	v_object_id		integer;	v_creation_user		integer;
	v_creation_ip		varchar;	v_journal_id		integer;
	v_transition_key	varchar;	v_workflow_key		varchar;
	v_status		varchar;
	v_str			text;
	row			RECORD;
begin
	-- Select out some frequently used variables of the environment
	select	c.object_id, c.workflow_key, task_id, c.case_id
	into	v_object_id, v_workflow_key, v_task_id, v_case_id
	from	wf_tasks t, wf_cases c
	where	c.case_id = p_case_id
		and t.case_id = c.case_id
		and t.workflow_key = c.workflow_key
		and t.transition_key = p_transition_key;

	v_journal_id := journal_entry__new(
	    null, v_case_id,
	    v_transition_key || '' set_object_status_id '' || im_category_from_id(p_custom_arg::integer),
	    v_transition_key || '' set_object_status_id '' || im_category_from_id(p_custom_arg::integer),
	    now(), v_creation_user, v_creation_ip,
	    ''Setting the status of "'' || acs_object__name(v_object_id) || ''" to "'' || 
	    im_category_from_id(p_custom_arg::integer) || ''".''
	);

	PERFORM im_biz_object__set_status_id(v_object_id, p_custom_arg::integer);
	return 0;
end;' language 'plpgsql';



-- Unassigned callback that assigns the transition to the owner of the underlying object.
--
create or replace function im_workflow__assign_to_owner (integer, text)
returns integer as '
declare
	p_task_id		alias for $1;	p_custom_arg		alias for $2;
	v_case_id		integer;	v_object_id		integer;
	v_creation_user		integer;	v_creation_ip		varchar;
	v_journal_id		integer;	v_object_type		varchar;
	v_transition_key	varchar;
	v_owner_id		integer;	v_owner_name		varchar;
	v_str			text;		row			RECORD;
begin
	-- Get information about the transition and the "environment"
	select	t.case_id, c.object_id, o.creation_user, o.creation_ip, o.object_type, tr.transition_key
	into	v_case_id, v_object_id, v_creation_user, v_creation_ip, v_object_type, v_transition_key
	from	wf_tasks t, wf_cases c, wf_transitions tr, acs_objects o
	where	t.task_id = p_task_id
		and t.case_id = c.case_id
		and o.object_id = t.case_id
		and t.workflow_key = tr.workflow_key
		and t.transition_key = tr.transition_key;

	select	v_creation_user, im_name_from_user_id(v_creation_user)
	into	v_owner_id, v_owner_name;

	IF v_owner_id is not null THEN
		v_journal_id := journal_entry__new(
		    null, v_case_id,
		    v_transition_key || '' assign_to_owner '' || v_owner_name,
		    v_transition_key || '' assign_to_owner '' || v_owner_name,
		    now(), v_creation_user, v_creation_ip,
		    ''Assigning to '' || v_owner_name || '', the owner of '' || 
		    acs_object__name(v_object_id) || ''.''
		);
		PERFORM workflow_case__add_task_assignment(p_task_id, v_owner_id, ''f'');
		PERFORM workflow_case__notify_assignee (p_task_id, v_owner_id, null, null, 
			''wf_'' || v_object_type || ''_assignment_notif'');
	END IF;
	return 0;
end;' language 'plpgsql';


-- Unassigned callback that assigns the transition to the supervisor of the owner
-- of the underlying object
--
create or replace function im_workflow__assign_to_supervisor (integer, text)
returns integer as '
declare
	p_task_id		alias for $1;
	p_custom_arg		alias for $2;
	v_case_id		integer;	v_object_id		integer;
	v_creation_user		integer;	v_creation_ip		varchar;
	v_journal_id		integer;	v_object_type		varchar;
	v_owner_id		integer;	v_owner_name		varchar;
	v_supervisor_id		integer;	v_supervisor_name	varchar;
	v_transition_key	varchar;
	v_str			text;
	row			RECORD;
begin
	-- Get information about the transition and the "environment"
	select	tr.transition_key, t.case_id, c.object_id, o.creation_user, o.creation_ip, o.object_type
	into	v_transition_key, v_case_id, v_object_id, v_creation_user, v_creation_ip, v_object_type
	from	wf_tasks t, wf_cases c, wf_transitions tr, acs_objects o
	where	t.task_id = p_task_id
		and t.case_id = c.case_id
		and o.object_id = t.case_id
		and t.workflow_key = tr.workflow_key
		and t.transition_key = tr.transition_key;

	select	e.employee_id, im_name_from_user_id(e.employee_id), 
		e.supervisor_id, im_name_from_user_id(e.supervisor_id)
	into	v_owner_id, v_owner_name, 
		v_supervisor_id, v_supervisor_name
	from	im_employees e
	where	e.employee_id = v_creation_user;

	IF v_supervisor_id is not null THEN
		v_journal_id := journal_entry__new(
		    null, v_case_id,
		    v_transition_key || '' assign_to_supervisor '' || v_supervisor_name,
		    v_transition_key || '' assign_to_supervisor '' || v_supervisor_name,
		    now(), v_creation_user, v_creation_ip,
		    ''Assigning to '' || v_supervisor_name || '', the supervisor of '' || v_owner_name || ''.''
		);
		PERFORM workflow_case__add_task_assignment(p_task_id, v_supervisor_id, ''f'');
		PERFORM workflow_case__notify_assignee (p_task_id, v_supervisor_id, null, null, 
			''wf_'' || v_object_type || ''_assignment_notif'');
	END IF;
	return 0;
end;' language 'plpgsql';



-- Unassigned callback that assigns the transition to the group in the custom_arg
--
create or replace function im_workflow__assign_to_group (integer, text)
returns integer as '
declare
	p_task_id		alias for $1;
	p_custom_arg		alias for $2;

	v_transition_key	varchar;	v_object_type		varchar;
	v_case_id		integer;	v_object_id		integer;
	v_creation_user		integer;	v_creation_ip		varchar;

	v_group_id		integer;	v_group_name		varchar;

	v_journal_id		integer;	
	v_str			text;
	row			RECORD;
begin
	-- Get information about the transition and the "environment"
	select	tr.transition_key, t.case_id, c.object_id, o.creation_user, o.creation_ip, o.object_type
	into	v_transition_key, v_case_id, v_object_id, v_creation_user, v_creation_ip, v_object_type
	from	wf_tasks t, wf_cases c, wf_transitions tr, acs_objects o
	where	t.task_id = p_task_id
		and t.case_id = c.case_id
		and o.object_id = t.case_id
		and t.workflow_key = tr.workflow_key
		and t.transition_key = tr.transition_key;

	select	group_id, group_name into v_group_id, v_group_name from groups
	where	trim(lower(group_name)) = trim(lower(p_custom_arg));

	IF v_group_id is not null THEN
		v_journal_id := journal_entry__new(
		    null, v_case_id,
		    v_transition_key || '' assign_to_group '' || v_group_name,
		    v_transition_key || '' assign_to_group '' || v_group_name,
		    now(), v_creation_user, v_creation_ip,
		    ''Assigning to specified group '' || v_group_name
		);
		PERFORM workflow_case__add_task_assignment(p_task_id, v_group_id, ''f'');
		PERFORM workflow_case__notify_assignee (p_task_id, v_group_id, null, null, 
			''wf_'' || v_object_type || ''_assignment_notif'');
	END IF;
	return 0;
end;' language 'plpgsql';


create or replace function im_workflow__assign_to_group (integer, text, text)
returns integer as '
declare
        p_case_id               alias for $1;
        p_transition_key        alias for $2;
        p_custom_arg            alias for $3;

	v_task_id		integer;	v_case_id		integer;
	v_creation_ip		varchar; 	v_creation_user		integer;
	v_object_id		integer;	v_object_type		varchar;
	v_journal_id		integer;
	v_transition_key	varchar;	v_workflow_key		varchar;

	v_group_id		integer;	v_group_name		varchar;
begin
	-- Select out some frequently used variables of the environment
	select	c.object_id, c.workflow_key, task_id, c.case_id, co.object_type, co.creation_ip
	into	v_object_id, v_workflow_key, v_task_id, v_case_id, v_object_type, v_creation_ip
	from	wf_tasks t, wf_cases c, acs_objects co
	where	c.case_id = p_case_id
		and c.case_id = co.object_id
		and t.case_id = c.case_id
		and t.workflow_key = c.workflow_key
		and t.transition_key = p_transition_key;

	select	group_id, group_name into v_group_id, v_group_name from groups
	where	trim(lower(group_name)) = trim(lower(p_custom_arg));

	IF v_group_id is not null THEN
		v_journal_id := journal_entry__new(
		    null, v_case_id,
		    v_transition_key || '' assign_to_group '' || v_group_name,
		    v_transition_key || '' assign_to_group '' || v_group_name,
		    now(), v_creation_user, v_creation_ip,
		    ''Assigning to specified group '' || v_group_name
		);
		PERFORM workflow_case__add_task_assignment(v_task_id, v_group_id, ''f'');
		PERFORM workflow_case__notify_assignee (v_task_id, v_group_id, null, null, 
			''wf_'' || v_object_type || ''_assignment_notif'');
	END IF;
	return 0;
end;' language 'plpgsql';


