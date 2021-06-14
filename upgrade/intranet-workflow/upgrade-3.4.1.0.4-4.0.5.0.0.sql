-- upgrade-3.4.1.0.4-4.0.5.0.0.sql
SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-3.4.1.0.4-4.0.5.0.0.sql','');

-- Unassigned callback that assigns the transition to the owner of the underlying object.

create or replace function im_workflow__assign_to_owner (integer, text)
returns integer as $BODY$
declare
	p_task_id		alias for $1;	p_custom_arg		alias for $2;
	v_case_id		integer;	v_object_id		integer;
	v_creation_user		integer;	v_creation_ip		varchar;
	v_journal_id		integer;	v_object_type		varchar;
	v_transition_key	varchar;	v_transition_name	varchar;
	v_owner_id		integer;	v_owner_name		varchar;
	v_str			text;		row			RECORD;
begin
	-- Get information about the transition and the "environment"
	select	t.case_id, c.object_id, o.creation_user, o.creation_ip, o.object_type, tr.transition_key, tr.transition_name
	into	v_case_id, v_object_id, v_creation_user, v_creation_ip, v_object_type, v_transition_key, v_transition_name
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
		    v_transition_key || ' assign_to_owner ' || v_owner_name,
		    v_transition_key || ' assign_to_owner ' || v_owner_name,
		    now(), v_creation_user, v_creation_ip,
		    v_transition_name || ': Assigning to ' || v_owner_name || ', the owner of the workflow case for object/user: ' || 
		    acs_object__name(v_object_id) || '.'
		);
		PERFORM workflow_case__add_task_assignment(p_task_id, v_owner_id, 'f');
		PERFORM workflow_case__notify_assignee (p_task_id, v_owner_id, null, null, 
			'wf_' || v_object_type || '_assignment_notif');
	END IF;
	return 0;
end;$BODY$ language 'plpgsql';
