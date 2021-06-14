-- upgrade-3.4.1.0.1-3.4.1.0.2.sql

SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-3.4.1.0.1-3.4.1.0.2.sql','');

CREATE OR REPLACE FUNCTION im_workflow__assign_to_user(integer, text, text)
  RETURNS integer AS
$BODY$
declare
	p_case_id		alias for $1;	
	p_transition_key	alias for $2;
	p_custom_arg		alias for $3;

	v_task_id		integer;	
	v_conf_id		integer;
	v_workflow_key          varchar;
	v_creation_user		integer;	
	v_creation_ip		varchar;
	v_journal_id		integer;	
	v_object_type		varchar;
	v_object_id		integer;
	v_transition_key	varchar;
	v_owner_id		integer;	
	v_owner_name		varchar;
	v_str			text;
	row			RECORD;
begin
	-- Get information about the transition and the "environment"
        -- Select out some frequently used variables of the environment
        select  c.object_id, c.workflow_key, t.task_id, t.transition_key, o.creation_user, o.creation_ip, o.object_type, o.object_id 
        into    v_conf_id, v_workflow_key, v_task_id, v_transition_key, v_creation_user, v_creation_ip, v_object_type, v_object_id
        from    wf_tasks t, wf_cases c, acs_objects o 
        where   c.case_id = p_case_id
                and t.case_id = c.case_id
		and o.object_id = t.case_id
                and t.workflow_key = c.workflow_key
                and t.transition_key = p_transition_key;

	v_owner_id := cast(p_custom_arg as integer); 
	select	im_name_from_user_id(v_owner_id) into v_owner_name;

	IF v_owner_id is not null THEN
		v_journal_id := journal_entry__new(
		    null, p_case_id,
		    v_transition_key || ' assign_to_owner ' || v_owner_name,
		    v_transition_key || ' assign_to_owner ' || v_owner_name,
		    now(), v_creation_user, v_creation_ip,
		    'Assigning to ' || v_owner_name || ', the owner of ' || 
		    acs_object__name(v_object_id) || '.'
		);
		PERFORM workflow_case__add_task_assignment(v_task_id, v_owner_id, 'f');
		PERFORM workflow_case__notify_assignee (v_task_id, v_owner_id, null, null, 'wf_' || v_object_type || '_assignment_notif');
	END IF;
	return 0;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE;


CREATE OR REPLACE FUNCTION im_workflow__assign_to_user(integer, text)
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

	PERFORM im_workflow__assign_to_user(v_case_id, v_transition_key, p_custom_arg);
        return 0;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE;


