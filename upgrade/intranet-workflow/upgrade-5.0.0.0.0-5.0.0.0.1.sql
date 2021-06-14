-- upgrade-5.0.0.0.0-5.0.0.0.1.sql
SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-5.0.0.0.0-5.0.0.0.1.sql','');


-- Deal with PostgreSQL 9.x
create or replace function workflow_case__add_token (integer,varchar,integer)
returns integer as $$
declare
        add_token__case_id                alias for $1;
        add_token__place_key              alias for $2;
        add_token__journal_id             alias for $3;
        v_token_id                        integer;
        v_workflow_key                    varchar;
begin
        select nextval('t_wf_token_id_seq') into v_token_id from dual;

        select workflow_key into v_workflow_key
        from   wf_cases c
        where  c.case_id = add_token__case_id;

        insert into wf_tokens (
		token_id, case_id, workflow_key, place_key, state, produced_journal_id
	) values (
		v_token_id, add_token__case_id, v_workflow_key, add_token__place_key,
                'free', add_token__journal_id
	);

        return 0;
end;$$ language 'plpgsql';



create or replace function workflow_case__execute_time_callback (varchar,varchar,integer,varchar)
returns timestamptz as $$
declare
	execute_time_callback__callback               alias for $1;  
	execute_time_callback__custom_arg             alias for $2;  
	execute_time_callback__case_id                alias for $3;  
	execute_time_callback__transition_key         alias for $4;  
	v_rec                                         record;
	v_str                                         text;
	v_result					timestamptz;
begin
	if execute_time_callback__callback = '' or execute_time_callback__callback is null then
		return null;
	end if;

	v_str := 'select ' || execute_time_callback__callback || '(' || 
		 execute_time_callback__case_id || ',' || 
		 quote_literal(execute_time_callback__transition_key) || ',' || 
		 coalesce(quote_literal(execute_time_callback__custom_arg),'null') || ') as trigger_time';

	for v_rec in execute v_str
	LOOP
		v_result := v_rec.trigger_time;
	end LOOP;

	RAISE NOTICE 'workflow_case__execute_time_callback: res=%, sql=%', v_result, v_str;
	return v_result;
end;$$ language 'plpgsql';



-- procedure enable_transitions
create or replace function workflow_case__enable_transitions (integer)
returns integer as $$
declare
	enable_transitions__case_id                alias for $1;  
	v_task_id                                  integer;        
	v_workflow_key                             varchar;  
	v_trigger_time                             timestamptz;     
	v_deadline_date                            timestamptz;     
	v_party_from                               integer;       
	v_subject                                  varchar;  
	v_body                                     text; 
	v_num_assigned                             integer; 
	trans_rec                                  record;
begin
	select workflow_key into v_workflow_key 
	from   wf_cases 
	where  case_id = enable_transitions__case_id;
	  
	/* we mark tasks overridden if they were once enabled, but are no longer so */

	update wf_tasks 
	set    state = 'overridden',
		   overridden_date = now()
	where  case_id = enable_transitions__case_id 
	and    state = 'enabled'
	and    transition_key not in 
		(select transition_key 
		 from wf_enabled_transitions 
		 where case_id = enable_transitions__case_id);
	  

	/* insert a task for the transitions that are enabled but have no task row */

	for trans_rec in select et.transition_key,
		   et.transition_name, 
		   et.trigger_type, 
		   et.enable_callback,
		   et.enable_custom_arg, 
		   et.time_callback, 
		   et.time_custom_arg,
		   et.deadline_callback,
		   et.deadline_custom_arg,
		   et.deadline_attribute_name,
		   et.notification_callback,
		   et.notification_custom_arg,
		   et.unassigned_callback,
		   et.unassigned_custom_arg,
		   et.estimated_minutes,
		   cr.assignment_callback,
		   cr.assignment_custom_arg
		  from wf_enabled_transitions et left outer join wf_context_role_info cr
		    on (et.workflow_key = cr.workflow_key and et.role_key = cr.role_key)
		 where et.case_id = enable_transitions__case_id
		   and not exists (select 1 from wf_tasks 
		               where case_id = enable_transitions__case_id
		               and   transition_key = et.transition_key
		               and   state in ('enabled', 'started')) 
	LOOP

		v_trigger_time := null;
		v_deadline_date := null;

		if trans_rec.trigger_type = 'user' then
		v_deadline_date := workflow_case__get_task_deadline (
		    trans_rec.deadline_callback, 
		    trans_rec.deadline_custom_arg,
		    trans_rec.deadline_attribute_name,
		    enable_transitions__case_id, 
		    trans_rec.transition_key
		);
		end if;

		v_trigger_time := workflow_case__execute_time_callback (
		                        trans_rec.time_callback, 
		                        trans_rec.time_custom_arg,
		                        enable_transitions__case_id, 
		                        trans_rec.transition_key);


		/* we are ready to insert the row */
		select nextval('t_wf_task_id_seq') into v_task_id from dual;

		insert into wf_tasks (
			task_id, case_id, workflow_key, transition_key, 
			deadline, trigger_time, estimated_minutes
		) values (
			v_task_id, enable_transitions__case_id, v_workflow_key, 
			trans_rec.transition_key,
			v_deadline_date, v_trigger_time, trans_rec.estimated_minutes
		);
		
		PERFORM workflow_case__set_task_assignments (
		        v_task_id,
			trans_rec.assignment_callback,
			trans_rec.assignment_custom_arg
		);

		/* Execute the transition enabled callback */
		PERFORM workflow_case__execute_transition_callback (
			trans_rec.enable_callback, 
			trans_rec.enable_custom_arg,
			enable_transitions__case_id, 
			trans_rec.transition_key
		);

		select count(*) into v_num_assigned
		from   wf_task_assignments
		where  task_id = v_task_id;

		if v_num_assigned = 0 then
		PERFORM workflow_case__execute_unassigned_callback (
		    trans_rec.unassigned_callback,
		    v_task_id,
		    trans_rec.unassigned_custom_arg
		);
		end if;

	end loop;

	return 0; 
end;$$ language 'plpgsql';

