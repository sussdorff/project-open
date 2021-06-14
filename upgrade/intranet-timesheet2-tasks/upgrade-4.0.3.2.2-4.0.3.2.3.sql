-- upgrade-4.0.3.2.2-4.0.3.2.3.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.0.3.2.2-4.0.3.2.3.sql','');

create or replace function inline_0() returns varchar as $body$
        DECLARE
		v_count		integer;
		v_plugin_id 	integer;
		v_foo		integer;
        BEGIN
		select count(*) into v_count from im_component_plugins where plugin_name = 'Task Resources';
		IF      1 = v_count
		THEN
			select plugin_id into v_plugin_id from im_component_plugins where plugin_name = 'Task Resources';
			select im_component_plugin__delete(v_plugin_id) into v_foo;        			
		ELSE 
			RAISE NOTICE 'intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.0.3.2.2-4.0.3.2.3.sql failed - Plugin Name not unique or does not exist.';
		END IF;
		return 0;  
	END;
$body$ language 'plpgsql';

SELECT inline_0 ();

DROP FUNCTION inline_0 ();