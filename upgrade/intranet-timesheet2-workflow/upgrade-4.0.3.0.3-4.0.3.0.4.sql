-- upgrade-4.0.3.0.3-4.0.3.0.4.sql

-- finally not used, removal of absence causes deletion of wf case which is not desired 
-- maybe useful in the future ... 

SELECT acs_log__debug('/packages/intranet-timesheet2-workflow/sql/postgresql/upgrade/upgrade-4.0.3.0.3-4.0.3.0.4.sql','');

CREATE OR REPLACE FUNCTION im_user_absence_wf__delete(integer, character varying, character varying)
  RETURNS integer AS
$BODY$
declare
        p_case_id               alias for $1;
        p_transition_key        alias for $2;
	p_custom_arg            alias for $3;

        v_task_id               integer;        v_case_id               integer;
        v_creation_ip           varchar;        v_creation_user         integer;
        v_object_id             integer;        v_object_type           varchar;
        v_journal_id            integer;        v_name_creation_user    varchar;
        v_transition_key        varchar;        v_workflow_key          varchar;
        v_group_id              integer;        v_group_name            varchar;
        v_task_owner            integer;

	v_absence_id		integer;
	v_start_date		date;
	v_end_date 		date;
	v_description 		varchar;
	v_absence_type_id 	integer;
	v_absence_name 		varchar;
	v_duration_days		numeric;
begin
        RAISE NOTICE 'im_user_absence_wf__delete: enter - p_case_id=%, p_transition_key=%, p_custom_arg=%', p_case_id, p_transition_key, p_custom_arg;

        -- Select out some frequently used variables of the environment
        select  c.object_id, c.workflow_key, co.creation_user, task_id, c.case_id, co.object_type, co.creation_ip
        into    v_object_id, v_workflow_key, v_creation_user, v_task_id, v_case_id, v_object_type, v_creation_ip
        from    wf_tasks t, wf_cases c, acs_objects co
        where   c.case_id = p_case_id
                and c.case_id = co.object_id
                and t.case_id = c.case_id
                and t.workflow_key = c.workflow_key
                and t.transition_key = p_transition_key;

	-- get absence_id 
	select object_id into v_absence_id from wf_cases where case_id = p_case_id; 
	
	-- Get absence attributes  
	select	start_date, end_date, description, absence_type_id, absence_name, duration_days 
	into 	v_start_date, v_end_date, v_description, v_absence_type_id, v_absence_name, v_duration_days 
	from 	im_user_absences 
	where 	absence_id = v_absence_id; 

	-- remove absence 
	PERFORM im_user_absence__delete(v_absence_id);  

	v_journal_id := journal_entry__new(
	    null, v_case_id, v_transition_key, v_transition_key, now(), v_creation_user, v_creation_ip, 
	    'Removed Absence ID:' || v_absence_id || '(' || 
	    v_start_date || '<br>' || 
	    v_end_date || '<br>' || 
	    v_description || '<br>' || 
	    v_absence_type_id || '<br>' || 
	    v_absence_name || '<br>' || 
	    v_duration_days || ')'    
	);
        return 0;

end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE;



CREATE OR REPLACE FUNCTION im_absences__cleanup()
  RETURNS INTEGER AS
	-- There should be no start_date with '00:00:00 in order to avoid problems with  
	-- constraint im_user_absences::owner_and_start_date_unique UNIQUE, btree (owner_id, absence_type_id, start_date)
        -- Example: Absence WF - Absence has been rejected in the first place, but a new inquiry with same dates and type is made. 
$BODY$

declare
        r                       record;
        v_owner_id              integer;
        v_absence_type_id       integer;
        v_start_date            timestamp;
        v_count        		integer;
	v_interval_str		interval;
	v_counter		integer;
	
begin
        -- Select out some frequently used variables of the environment
        FOR r IN
                select  absence_id, owner_id, absence_type_id, start_date
                from    im_user_absences
                where   absence_status_id = 16002 OR
                        absence_status_id = 16006
                order by owner_id, absence_type_id, start_date
        LOOP
                IF      position('00:00:00' in r.start_date) > 1  THEN
                        RAISE NOTICE 'im_absences__cleanup :: Found absence_id %', absence_id;
			v_counter := 1; 
			FOR i IN 1..300 LOOP				
				v_interval_str := v_counter || ' seconds';
				RAISE NOTICE 'r.start_date: %, v_interval_str: % ', r.start_date, v_interval_str;
				v_start_date := r.start_date::timestamp + v_interval_str;
				select 
					count(*) 
				into 
					v_count            
				from 
					im_user_absences 
				where 
					absence_type_id = r.absence_type_id and 
					owner_id = r.owner_id and
					start_date = v_start_date;

				IF v_count = 0 THEN 
					update im_user_absences set start_date = v_start_date where absence_id = r.absence_id;  
					RAISE NOTICE 'im_absences__cleanup :: Changed absence_id: % to %', r.absence_id, v_start_date;
					EXIT;
				END IF; 
				-- v_interval_str := v_interval_str +1;
			END LOOP;
                END IF;
        END LOOP;
	return 0;
end;$BODY$

LANGUAGE 'plpgsql' VOLATILE;
