-- upgrade-3.4.1.0.3-3.4.1.0.4.sql

SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-3.4.1.0.3-3.4.1.0.4.sql','');

create or replace function im_workflow__assign_to_group_when_sv_absent(int4,text) returns int4 as '
        declare
                p_task_id               alias for $1;
                p_custom_arg            alias for $2;
                v_case_id               integer;        v_object_id             integer;
                v_creation_user         integer;        v_creation_ip           varchar;
                v_journal_id            integer;        v_object_type           varchar;
                v_owner_id              integer;        v_owner_name            varchar;
                v_supervisor_id         integer;        v_supervisor_name       varchar;
                v_transition_key        varchar;        v_number_absences       integer;
                v_str                   text;           v_group_id              integer;
                row                     RECORD;         v_group_name            varchar;
                v_todays_date           varchar;
        begin
                -- Get information about the transition and the "environment"
                select  tr.transition_key, t.case_id, c.object_id, o.creation_user, o.creation_ip, o.object_type
                into    v_transition_key, v_case_id, v_object_id, v_creation_user, v_creation_ip, v_object_type
                from    wf_tasks t, wf_cases c, wf_transitions tr, acs_objects o
                where   t.task_id = p_task_id
                        and t.case_id = c.case_id
                        and o.object_id = t.case_id
                        and t.workflow_key = tr.workflow_key
                        and t.transition_key = tr.transition_key;

                -- Getting supervisor of user
                select  e.employee_id, im_name_from_user_id(e.employee_id),
                        e.supervisor_id, im_name_from_user_id(e.supervisor_id)
                into    v_owner_id, v_owner_name,
                        v_supervisor_id, v_supervisor_name
                from    im_employees e
                where   e.employee_id = v_creation_user;

                RAISE NOTICE ''im_workflow__assign_to_group_when_sv_absent - Found Supervisor:% (%)'', v_supervisor_name, v_supervisor_id;

                v_number_absences := 0;

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

                select to_date(now()::text,''yyyy-mm-dd'') into v_todays_date;
                RAISE NOTICE ''im_workflow__assign_to_group_when_sv_absent - Looking for absences for day:%'', v_todays_date;

                        -- Check if there is an absence
                        select  count(*)
                        into    v_number_absences
                        from    im_user_absences
                        where   owner_id = v_supervisor_id
                                and ( to_date(now()::text,''yyyy-mm-dd'') >= to_date(start_date::text,''yyyy-mm-dd'') and to_date(now()::text,''yyyy-mm-dd'') <= to_date(end_date::text,''yyyy-mm-dd'') );
                END IF;

                -- If superviser is absent, we also assign it to a group (argument)

                RAISE NOTICE ''im_workflow__assign_to_group_when_sv_absent - Number days Absence found:%'', v_number_absences;

                IF v_number_absences > 0  THEN
                        select  group_id, group_name
                        into    v_group_id, v_group_name
                        from    groups
                        where   trim(lower(group_name)) = trim(lower(p_custom_arg));

                        RAISE NOTICE ''im_workflow__assign_to_group_when_sv_absent - Assigning to v_group_id:%/v_group_name:%'', v_group_id, v_group_name;

                        IF v_group_id is not null THEN
                                v_journal_id := journal_entry__new(
                                        null, v_case_id,
                                        v_transition_key || '' assign_to_group '' || v_group_name,
                                        v_transition_key || '' assign_to_group '' || v_group_name,
                                        now(), v_creation_user, v_creation_ip,
                                        ''Assigning to specified group '' || v_group_name
                                );
                                PERFORM workflow_case__add_task_assignment(p_task_id, v_group_id, ''f'');
                                -- PERFORM workflow_case__notify_assignee (v_task_id, v_group_id, null, null,
                                -- ''wf_'' || v_object_type || ''_assignment_notif'');
                        END IF;
                END IF;
                return 0;
end;' language 'plpgsql';

