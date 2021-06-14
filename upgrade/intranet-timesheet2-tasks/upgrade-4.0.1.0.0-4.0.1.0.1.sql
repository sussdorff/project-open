-- upgrade-4.0.1.0.0-4.0.1.0.1.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.0.1.0.0-4.0.1.0.1.sql','');


-- Does the user have the right to edit task estimates?
select acs_privilege__create_privilege(
	'edit_timesheet_task_estimates',
	'Edit Gantt Task Estimates',
	'Edit Gantt Task Estimates'
);
select acs_privilege__add_child('admin', 'edit_timesheet_task_estimates');
select im_priv_create('edit_timesheet_task_estimates', 'Employees');


select acs_privilege__create_privilege(
        'view_timesheet_task_estimates',
        'View Gantt Task Estimates',
        'View Gantt Task Estimates'
);
select acs_privilege__add_child('admin', 'view_timesheet_task_estimates');
select im_priv_create('view_timesheet_task_estimates', 'Employees');


select acs_privilege__create_privilege(
        'view_timesheet_task_billables',
        'View Gantt Task Billables',
        'View Gantt Task Billables'
);
select acs_privilege__add_child('admin', 'view_timesheet_task_billables');
select im_priv_create('view_timesheet_task_billables', 'Employees');


-- The new version of the delete also cleans up relationships etc.

-- Delete a single timesheet_task (if we know its ID...)
create or replace function im_timesheet_task__delete (integer)
returns integer as '
declare
	p_task_id		alias for $1;	-- timesheet_task_id
	row			RECORD;
begin
	-- Start deleting with im_gantt_projects
	delete from	im_gantt_projects
	where		project_id = p_task_id;

	-- Delete dependencies between tasks
	delete from	im_timesheet_task_dependencies
	where		(task_id_one = p_task_id OR task_id_two = p_task_id);

	-- Delete object_context_index
	delete from	acs_object_context_index
	where		(object_id = p_task_id OR ancestor_id = p_task_id);

	-- Delete relatinships
	FOR row IN
		select	*
		from	acs_rels
		where	(object_id_one = p_task_id OR object_id_two = p_task_id)
	LOOP
		PERFORM acs_rel__delete(row.rel_id);
	END LOOP;

	-- Erase the timesheet_task
	delete from im_timesheet_tasks
	where task_id = p_task_id;

	-- Erase the object
	PERFORM im_project__delete(p_task_id);
	return 0;
end;' language 'plpgsql';
