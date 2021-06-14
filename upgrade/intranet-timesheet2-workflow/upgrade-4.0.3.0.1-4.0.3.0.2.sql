-- upgrade-4.0.3.0.1-4.0.3.0.2.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-workflow/sql/postgresql/upgrade/upgrade-4.0.3.0.1-4.0.3.0.2.sql','');

create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from information_schema.columns where
              table_name = ''im_timesheet_conf_objects''
              and column_name = ''comment'';

        IF v_count > 0 THEN return 1; END IF;

	alter table im_timesheet_conf_objects add column comment text default '''';

        RETURN 0;

end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function im_ts_approval__add_comment(int4,varchar,varchar) returns int4 as '
    declare
            p_case_id               alias for $1;
            p_transition_key        alias for $2;
            p_custom_arg            alias for $3;
    
            v_task_id               integer;        v_case_id               integer;
            v_creation_ip           varchar;        v_user_id               integer;
            v_creation_user         integer;        v_conf_id               integer;
            v_object_id             integer;        v_object_type           varchar;
            v_journal_id            integer;
            v_transition_key        varchar;        v_workflow_key          varchar;
            v_group_id              integer;        v_group_name            varchar;
            v_task_owner            integer;
    
            v_description           text;
            v_msg                   text;
    
            v_object_name           text;
            v_locale                text;
            v_action_pretty         text;
    
    begin
            RAISE NOTICE ''im_ts_approval__add_comment: enter - p_case_id=%, p_transition_key=%, p_custom_arg=%'', p_case_id, p_transition_key, p_custom_arg;
    
            -- Select out some frequently used variables of the environment
            select  c.object_id, c.workflow_key, co.creation_user, task_id, c.case_id, co.object_type, co.creation_ip
            into    v_object_id, v_workflow_key, v_creation_user, v_task_id, v_case_id, v_object_type, v_creation_ip
            from    wf_tasks t, wf_cases c, acs_objects co
            where   c.case_id = p_case_id
                    and c.case_id = co.object_id
                    and t.case_id = c.case_id
                    and t.workflow_key = c.workflow_key
                    and t.transition_key = p_transition_key;
    
    
            -- set object_id
            v_conf_id := v_object_id;
            RAISE NOTICE ''im_ts_approval__add_comment: v_conf_id:% '', v_conf_id;
   
            -- get comment
            v_action_pretty := p_custom_arg || '' finish'';
            select msg into v_msg from journal_entries where object_id = v_case_id and action_pretty = v_action_pretty;
    
            update im_timesheet_conf_objects set comment = v_msg where conf_id = v_conf_id;
    
            return 0;
end;' language 'plpgsql';


create or replace function im_workflow__remove_conf_item_timesheet(int4,text,text) returns int4 as '
         declare
                p_task_id               alias for $1;
                p_custom_arg            alias for $2;
                p_custom_arg_1          alias for $3;
        
                v_transition_key        varchar;
                v_object_type           varchar;
                v_case_id               integer;
                v_object_id             integer;
                v_creation_user         integer;
                v_creation_ip           varchar;
                v_project_manager_id    integer;
                v_project_manager_name  varchar;
        
                v_journal_id            integer;
        
         begin
                RAISE NOTICE ''im_workflow__remove_conf_item_timesheet:alias_1 =%, alias_2 =%, alias3 =%, v_case_id=%'', p_task_id, p_custom_arg, p_custom_arg_1, v_case_id;
                update im_hours set conf_object_id = NULL where conf_object_id in (select object_id from wf_cases where case_id = p_task_id);
                return 0;
end;' language 'plpgsql';

