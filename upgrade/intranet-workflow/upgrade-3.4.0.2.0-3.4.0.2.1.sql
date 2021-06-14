-- upgrade-3.4.0.2.0-3.4.0.2.1.sql

SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-3.4.0.2.0-3.4.0.2.1.sql','');


-- Unassigned callback that assigns the transition to the group in the custom_arg
--
create or replace function im_workflow__assign_to_group (integer,text)
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

	RAISE NOTICE ''In: im_workflow__assign_to_group(integer, text) p_task_id: %'', p_task_id;

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

	RAISE NOTICE ''In: im_workflow__assign_to_group(integer, text) group_id: %'', v_group_id;

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



