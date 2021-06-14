-- 
-- packages/intranet-workflow/sql/postgresql/upgrade/upgrade-4.0.1.0.0-4.0.1.0.1.sql
-- 
-- Copyright (c) 2011, cognovís GmbH, Hamburg, Germany
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
-- 
-- @author Malte Sussdorff (malte.sussdorff@cognovis.de)
-- @creation-date 2011-04-12
-- @cvs-id $Id$
--

SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-4.0.1.0.0-4.0.1.0.1.sql','');

CREATE OR REPLACE FUNCTION im_workflow__assign_to_project_manager(integer, text)
  RETURNS integer AS
$BODY$
 declare
     p_task_id        alias for $1;
	p_custom_arg		alias for $2;
     v_transition_key    varchar;    
    v_object_type        varchar;
     v_case_id        integer;    
    v_object_id        integer;
     v_creation_user        integer;    
    v_creation_ip        varchar;
     v_project_manager_id     integer;    
    v_project_manager_name     varchar;    

     v_journal_id        integer;    
 
 begin
     -- Get information about the transition and the 'environment'
     select    tr.transition_key, t.case_id, c.object_id, o.creation_user, o.creation_ip, o.object_type
     into    v_transition_key, v_case_id, v_object_id, v_creation_user, v_creation_ip, v_object_type
     from    wf_tasks t, wf_cases c, wf_transitions tr, acs_objects o
     where    t.task_id = p_task_id
         and t.case_id = c.case_id
         and o.object_id = t.case_id
         and t.workflow_key = tr.workflow_key
         and t.transition_key = tr.transition_key;
 
     select    p.project_lead_id into v_project_manager_id from im_projects p, im_timesheet_conf_objects co
     where    p.project_id = co.conf_project_id
     and co.conf_id = v_object_id;
 
     select im_name_from_id(v_project_manager_id) into v_project_manager_name;

     IF v_project_manager_id is not null THEN
         v_journal_id := journal_entry__new(
             null, v_case_id,
             v_transition_key || ' assign_to_project_manager ' || v_project_manager_name,
             v_transition_key || ' assign_to_project_manager ' || v_project_manager_name,
             now(), v_creation_user, v_creation_ip,
             'Assigning to user' || v_project_manager_name
         );
         PERFORM workflow_case__add_task_assignment(p_task_id, v_project_manager_id, 'f');
         PERFORM workflow_case__notify_assignee (p_task_id, v_project_manager_id, null, null, 
             'wf_' || v_object_type || '_assignment_notif');
     END IF;
     return 0;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE;



-- Assign the transition to project members with role "Project Admin".
-- (The project manager is automatically assigned as project member with
-- this role, but there may be additional persons in this role).
create or replace function im_workflow__assign_to_project_admins (integer, text)
returns integer as '
declare
        p_task_id               alias for $1;
        p_custom_arg            alias for $2;

	v_case_id		integer;
	v_creation_ip		varchar; 	
    v_creation_user		integer;
	v_object_id		integer;	v_object_type		varchar;
	v_journal_id		integer;
	v_transition_key	varchar;	v_workflow_key		varchar;

	row			RECORD;
begin
	-- Select out some frequently used variables of the environment
	select	tr.transition_key, t.case_id, c.object_id, o.creation_user, o.creation_ip, o.object_type
	into	v_transition_key, v_case_id, v_object_id, v_creation_user, v_creation_ip, v_object_type
	from	wf_tasks t, wf_cases c, wf_transitions tr, acs_objects o
	where	t.task_id = p_task_id
		and t.case_id = c.case_id
		and o.object_id = t.case_id
		and t.workflow_key = tr.workflow_key
		and t.transition_key = tr.transition_key;

	FOR row IN
		select	r.object_id_two as user_id, 
			im_name_from_user_id(r.object_id_two) as user_name
		from im_timesheet_conf_objects co,
			im_projects p,
			acs_rels r,
			im_biz_object_members bom
		where	co.conf_id = v_object_id and
			co.conf_project_id = p.project_id and
			r.object_id_one = p.project_id and
			r.rel_id = bom.rel_id and
			bom.object_role_id = 1301
	LOOP
		v_journal_id := journal_entry__new(
		    null, v_case_id,
		    v_transition_key || '' assign_to_user '' || row.user_name,
		    v_transition_key || '' assign_to_user '' || row.user_name,
		    now(), v_creation_user, v_creation_ip,
		    ''Assigning to '' || row.user_name
		);
		PERFORM workflow_case__add_task_assignment(p_task_id, row.user_id, ''f'');
		PERFORM workflow_case__notify_assignee (p_task_id, row.user_id, null, null, 
			''wf_'' || v_object_type || ''_assignment_notif'');
	END LOOP;

	return 0;
end;' language 'plpgsql';



create or replace function im_workflow__assign_to_project_admins (integer, text, text)
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

	row			RECORD;
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

	FOR row IN
		select	r.object_id_two as user_id, 
			im_name_from_user_id(r.object_id_two) as user_name
		from	wf_cases wfc,
			im_projects p,
			acs_rels r,
			im_biz_object_members bom
		where	wfc.case_id = v_case_id and
			wfc.object_id = p.project_id and
			r.object_id_one = p.project_id and
			r.rel_id = bom.rel_id and
			bom.object_role_id = 1301
	LOOP
		v_journal_id := journal_entry__new(
		    null, v_case_id,
		    v_transition_key || '' assign_to_user '' || row.user_name,
		    v_transition_key || '' assign_to_user '' || row.user_name,
		    now(), v_creation_user, v_creation_ip,
		    ''Assigning to '' || row.user_name
		);
		PERFORM workflow_case__add_task_assignment(v_task_id, row.user_id, ''f'');
		PERFORM workflow_case__notify_assignee (v_task_id, row.user_id, null, null, 
			''wf_'' || v_object_type || ''_assignment_notif'');
	END LOOP;

	return 0;
end;' language 'plpgsql';


-- Enable callback that deletes all tokens in the systems except the one
-- for the current transition.
-- This function allows to deal with parallelism in the Petri-Net and
-- the situation that one approval path of severals is not OK.
--
-- The function will also "cancel" any started transitions, in order to
-- cancel parallel tasks that were already started.
--
-- p_custom_arg is not used.
--
create or replace function im_workflow__delete_all_other_tokens (integer, text, text)
returns integer as $body$
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
	select  c.object_id, c.workflow_key, task_id, c.case_id
	into	v_object_id, v_workflow_key, v_task_id, v_case_id
	from	wf_tasks t, wf_cases c
	where   c.case_id = p_case_id
		and t.case_id = c.case_id
		and t.workflow_key = c.workflow_key
		and t.transition_key = p_transition_key;

	v_journal_id := journal_entry__new(
		null, v_case_id,
		v_transition_key || ' set_object_status_id ' || im_category_from_id(p_custom_arg::integer),
		v_transition_key || ' set_object_status_id ' || im_category_from_id(p_custom_arg::integer),
		now(), v_creation_user, v_creation_ip,
		'Deleting all other tokens and resetting transitions, except for "' || p_transition_key || '".'
	);

	-- Cancel all started tasks. This will result in releasing the tokens to their places.
	FOR row IN
		select	*
		from	wf_tasks
		where	case_id = p_case_id and
			state = 'started'
	LOOP
		-- PERFORM acs_log__debug('im_workflow__delete_all_other_tokens', 'Cancel task '||row.task_id);
		PERFORM workflow_case__cancel_task (row.task_id, v_journal_id);
	END LOOP;

	-- Delete all "free" tokens
	FOR row IN
		select	*
		from	wf_tokens
		where	case_id = p_case_id and
			state = 'free'
	LOOP
		-- PERFORM acs_log__debug('im_workflow__delete_all_other_tokens', 'Deleting token '||row.token_id||' in place '||row.place_key);
        	delete from wf_tokens where token_id = row.token_id;
	END LOOP;

	-- For all places that link to the current (new!) transition
	-- create a new token to enable the current transition
	FOR row IN
		select	*
		from	wf_arcs
		where	workflow_key = v_workflow_key and
			transition_key = p_transition_key and 
			direction = 'in'
	LOOP
		-- PERFORM acs_log__debug('im_workflow__delete_all_other_tokens', 'Add token in place '||row.place_key);
		PERFORM workflow_case__add_token (p_case_id, row.place_key, null);
	END LOOP;

	return 0;
end; $body$ language 'plpgsql';


