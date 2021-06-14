-- 
-- packages/intranet-workflow/sql/postgresql/upgrade/upgrade-4.0.5.0.1-4.0.5.0.2.sql
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
-- @creation-date 2014-03-12
-- @cvs-id $Id$
--

SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-4.0.5.0.1-4.0.5.0.2.sql','');

-- Unassigned callback that assigns the transition to the supervisor of the owner
-- of the underlying absence
--
create or replace function im_workflow__assign_to_absence_supervisor (integer, text)
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
	select	tr.transition_key, t.case_id, c.object_id, ua.owner_id, o.creation_ip, o.object_type
	into	v_transition_key, v_case_id, v_object_id, v_owner_id, v_creation_ip, v_object_type
	from	wf_tasks t, wf_cases c, wf_transitions tr, im_user_absences ua, acs_objects o
	where	t.task_id = p_task_id
		and t.case_id = c.case_id
		and o.object_id = c.object_id
                and ua.absence_id = o.object_id
		and t.workflow_key = tr.workflow_key
		and t.transition_key = tr.transition_key;

	select	im_name_from_user_id(e.employee_id), 
		e.supervisor_id, im_name_from_user_id(e.supervisor_id)
	into  v_owner_name, 
		v_supervisor_id, v_supervisor_name
	from	im_employees e
	where	e.employee_id = v_owner_id;

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

update wf_context_transition_info set unassigned_callback = 'im_workflow__assign_to_absence_supervisor' where workflow_key='vacation_approval_wf' and transition_key = 'approve';
update wf_context_transition_info set unassigned_callback = 'im_workflow__assign_to_absence_supervisor' where workflow_key='hr_vacation_approval_wf' and transition_key = 'approve';
