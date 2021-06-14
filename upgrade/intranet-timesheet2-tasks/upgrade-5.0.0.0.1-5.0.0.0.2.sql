-- upgrade-5.0.0.0.1-5.0.0.0.2.sql
SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-5.0.0.0.1-5.0.0.0.2.sql','');

-- New hidden field which will preplace loop variable task_status_id in  ~/packages/intranet-timesheet2-tasks/www/task-action.tcl

CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS $BODY$

declare
        v_count                 integer;
begin

        select count(*) into v_count from im_view_columns where column_id = 91022 and view_id = 910;

        IF      1 = v_count
        THEN
		update im_view_columns set column_render_tcl = '"<input type=checkbox name=''task_id.$task_id'' id=''tasks,$task_id''> <input type=''hidden'' name=''task_id_form.$task_id''>"' where column_id = 91022 and view_id = 910;
                return 0;
	ELSE 	
	     	RAISE NOTICE 'Unable to update view_id: 920 - view not found';
	        return 1;	     
        END IF;

end;$BODY$ LANGUAGE 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();
