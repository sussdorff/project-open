-- upgrade-5.0.2.3.4-5.0.2.3.5.sql

SELECT acs_log__debug('/packages/intranet-translation/sql/postgresql/upgrade/upgrade-5.0.2.3.4-5.0.2.3.5.sql','');



create or replace function im_trans_task__delete (integer) returns integer as '
DECLARE
	v_task_id	 alias for $1;
BEGIN
	-- ToDo: Check if there is a WF case associated with the object(?)
	delete from im_task_actions
	where task_id = v_task_id;

	-- Erase the im_trans_tasks item associated with the id
	delete from     im_trans_tasks
	where	   task_id = v_task_id;

	-- Erase all the priviledges
	delete from     acs_permissions
	where	   object_id = v_task_id;

	PERFORM acs_object__delete(v_task_id);

	return 0;
end;' language 'plpgsql';

