SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-4.1.0.0.0-4.1.0.0.1.sql','');

create or replace function im_workflow__assign_to_vacation_replacement_if(
    p_task_id           integer,
    p_case_id           integer,
    p_owner_id          integer,
    p_supervisor_id     integer,
    p_transition_key    varchar,
    p_creation_user     integer,
    p_creation_ip       varchar,
    p_object_type       varchar
)
returns void as
$$
declare
    v_vacation_replacement_id   integer;
    v_vacation_replacement_name varchar;
    v_journal_id                integer;
    v_slack_time_days           integer;
    v_msg                       varchar;
    v_table_exists_p            boolean;
begin

    select true
    into v_table_exists_p 
    from pg_class c 
    inner join pg_attribute a 
    on (a.attrelid=c.oid) 
    where relname='im_user_absences' 
    and attname='vacation_replacement_id';
    
    if v_table_exists_p is null then
        return;
    end if;

    select attr_value into v_slack_time_days
    from apm_parameter_values pv
    inner join apm_packages pkg
    on (pkg.package_id=pv.package_id)
    inner join apm_parameters p
    on (p.parameter_id=pv.parameter_id)
    where pkg.package_key='intranet-timesheet2' and p.parameter_name='TimesheetSlackTimeDays';

    if v_slack_time_days is null then
        raise exception 'intranet-timesheet2/TimesheetSlackTimeDays parameter must be a number';
    end if;

    -- check if the supervisor_id found is currently on vacation 
    -- (quick query in im_user_absences if now is in between absence dates)
    -- End date is usually at 0:00 in the morning, hence the adding of the 1 day to make sure it is correctly opened
    -- Only for active absences

    select vacation_replacement_id, person__name(vacation_replacement_id) 
    into v_vacation_replacement_id, v_vacation_replacement_name
    from im_user_absences
    where owner_id = p_supervisor_id
    and (now() between (start_date - (v_slack_time_days || ' days')::interval) and  (end_date + '1 days'::interval))
    and absence_status_id = 16000;

    -- In case an absence is found, check if there is a vacation_replacement_id. 

    if v_vacation_replacement_id = p_owner_id then

        select supervisor_id, person__name(supervisor_id)
        into v_vacation_replacement_id, v_vacation_replacement_name
        from im_employees
        where employee_id = p_supervisor_id;

        v_msg = 'Assigning to ' || v_vacation_replacement_name || ', the supervisor of ' || person__name(p_supervisor_id) || '.';
    else
        v_msg = 'Assigning to ' || v_vacation_replacement_name || ', the vacation replacement of ' || person__name(p_supervisor_id) || '.';
    end if;

    if v_vacation_replacement_id is not null then

        -- If there is, assign the workflow to both the supervisor_id and the 
        -- vacation_replacement_id. Record this additional assigning in the 
        -- workflow journal as well.

        v_journal_id := journal_entry__new(
            null, 
            p_case_id,
            p_transition_key || ' assign_to_supervisor ' || v_vacation_replacement_name,
            p_transition_key || ' assign_to_supervisor ' || v_vacation_replacement_name,
            now(), 
            p_creation_user, 
            p_creation_ip,
            v_msg
        );

        perform workflow_case__add_task_assignment(p_task_id, v_vacation_replacement_id, 'f');

        perform workflow_case__notify_assignee (p_task_id, v_vacation_replacement_id, null, null, 
            'wf_' || p_object_type || '_assignment_notif');
        
    end if;
end;
$$ language 'plpgsql';


create or replace function im_workflow__auto_approve_task (
    p_task_id           integer,
    p_case_id           integer,
    p_transition_key    varchar,
    p_owner_id          integer,
    p_owner_name        varchar,
    p_creation_user     integer,
    p_creation_ip       varchar,
    p_action            varchar,
    p_msg               varchar
) returns integer as
$$
declare
    v_journal_id integer;
begin

    -- Start the task. Saves the user the work to press the "Start Task" button.
    perform workflow_case__add_task_assignment (p_task_id, p_owner_id, 't');
    perform workflow_case__begin_task_action (p_task_id,'start',p_creation_ip,p_owner_id,'');

    v_journal_id := journal_entry__new(
        null, 
        p_case_id,
        p_action,
        p_action,
        now(), 
        p_creation_user, 
        p_creation_ip,
        p_msg
    );

    perform workflow_case__start_task (p_task_id,p_owner_id,v_journal_id);

    -- Finish the task. That forwards the token to the next transition.
    perform workflow_case__finish_task(p_task_id,v_journal_id);

    return v_journal_id;

end;
$$ language 'plpgsql';

-- Unassigned callback that assigns the transition to the supervisor of the owner
-- of the underlying object
--
create or replace function im_workflow__assign_to_supervisor (integer, text)
returns integer as 
$$
declare
	p_task_id		            alias for $1;
	p_custom_arg		        alias for $2;

	v_case_id		            integer;		
    v_object_id	            	integer;
	v_creation_user		        integer;
    v_creation_ip		        varchar;
	v_journal_id		        integer;
    v_object_type		        varchar;
	v_owner_id		            integer;
	v_owner_name		        varchar;
	v_supervisor_id		        integer;
	v_supervisor_name	        varchar;
    v_vacation_replacement_id   integer;
    v_vacation_replacement_name varchar;
	v_transition_key	        varchar;
	v_str			            text;
	row			                record;
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

	if v_supervisor_id is null then

        -- auto approves the current step and continues to the next one
        -- logs this in the journal (with an "auto approved" entry) 
        -- and makes sure that the approval_p information is set
        -- to "t" and the absence request is actually approved. 

        perform im_workflow__auto_approve_task(
            p_task_id,
            v_case_id,
            v_transition_key,
            v_owner_id,
            v_owner_name,
            v_creation_user,
            v_creation_ip,
            v_transition_key || ' assign_to_supervisor ' || v_owner_name,
		    'Assigning to ' || v_owner_name || ' (auto-approved) as there is no supervisor.'
        );

    else

        perform im_workflow__assign_to_vacation_replacement_if(
            p_task_id,
            v_case_id,
            v_owner_id,
            v_supervisor_id,
            v_transition_key,
            v_creation_user,
            v_creation_ip,
            v_object_type
        );

		v_journal_id := journal_entry__new(
		    null, 
            v_case_id,
		    v_transition_key || ' assign_to_supervisor ' || v_supervisor_name,
		    v_transition_key || ' assign_to_supervisor ' || v_supervisor_name,
		    now(), 
            v_creation_user, 
            v_creation_ip,
		    'Assigning to ' || v_supervisor_name || ', the supervisor of ' || v_owner_name || '.'
		);

		perform workflow_case__add_task_assignment(p_task_id, v_supervisor_id, 'f');

		perform workflow_case__notify_assignee (p_task_id, v_supervisor_id, null, null, 
			'wf_' || v_object_type || '_assignment_notif');

	end if;

	return 0;
end;
$$ language 'plpgsql';


-- Unassigned callback that assigns the transition to the supervisor of the owner
-- of the underlying absence
--
create or replace function im_workflow__assign_to_absence_supervisor (integer, text)
returns integer as 
$$
declare
	p_task_id		    alias for $1;
	p_custom_arg		alias for $2;

	v_case_id		    integer;
	v_object_id		    integer;
	v_creation_user		integer;
	v_creation_ip		varchar;
	v_journal_id		integer;
	v_object_type		varchar;
	v_owner_id		    integer;
	v_owner_name		varchar;
	v_supervisor_id		integer;
	v_supervisor_name	varchar;
	v_transition_key	varchar;
	v_str			    text;
	row			        record;
begin
	-- Get information about the transition and the "environment"
    select  tr.transition_key, t.case_id, c.object_id, ua.owner_id, o.creation_ip, o.object_type
    into    v_transition_key, v_case_id, v_object_id, v_owner_id, v_creation_ip, v_object_type
    from    wf_tasks t, wf_cases c, wf_transitions tr, im_user_absences ua, acs_objects o
    where   t.task_id = p_task_id
            and t.case_id = c.case_id
            and o.object_id = c.object_id
            and ua.absence_id = o.object_id
            and t.workflow_key = tr.workflow_key
            and t.transition_key = tr.transition_key;

	select	im_name_from_user_id(e.employee_id), 
            e.supervisor_id, 
            im_name_from_user_id(e.supervisor_id)
	into    v_owner_name, 
            v_supervisor_id,
            v_supervisor_name
	from	im_employees e
	where	e.employee_id = v_owner_id;

	if v_supervisor_id is null then

        -- auto approves the current step and continues to the next one
        -- logs this in the journal (with an "auto approved" entry) 
        -- and makes sure that the approval_p information is set
        -- to "t" and the absence request is actually approved. 

        perform im_workflow__auto_approve_task(
            p_task_id,
            v_case_id,
            v_transition_key,
            v_owner_id,
            v_owner_name,
            v_creation_user,
            v_creation_ip,
            v_transition_key || ' assign_to_supervisor ' || v_owner_name,
		    'Assigning to ' || v_owner_name || ' (auto-approved) as there is no supervisor.'
        );

    else

        perform im_workflow__assign_to_vacation_replacement_if(
            p_task_id,
            v_case_id,
            v_owner_id,
            v_supervisor_id,
            v_transition_key,
            v_creation_user,
            v_creation_ip,
            v_object_type
        );

		v_journal_id := journal_entry__new(
		    null, 
            v_case_id,
		    v_transition_key || ' assign_to_supervisor ' || v_supervisor_name,
		    v_transition_key || ' assign_to_supervisor ' || v_supervisor_name,
		    now(), 
            v_creation_user, 
            v_creation_ip,
		    'Assigning to ' || v_supervisor_name || ', the supervisor of ' || v_owner_name || '.'
		);

		perform workflow_case__add_task_assignment(p_task_id, v_supervisor_id, 'f');

		perform workflow_case__notify_assignee (p_task_id, v_supervisor_id, null, null, 
			'wf_' || v_object_type || '_assignment_notif');

	end if;

	return 0;

end;
$$ language 'plpgsql';


