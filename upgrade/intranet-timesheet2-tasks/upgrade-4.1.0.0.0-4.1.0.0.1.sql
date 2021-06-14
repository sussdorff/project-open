
SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.1.0.0.0-4.1.0.0.1.sql','');

SELECT  im_component_plugin__new (
		null,                           -- plugin_id
		'acs_object',                	-- object_type
		now(),                        	-- creation_date
		null,                           -- creation_user
		null,                           -- creation_ip
		null,                           -- context_id
		'Project Task to Subproject Converter', 	-- plugin_name
		'intranet-timesheet2-tasks',   	-- package_name
		'right',                        -- location
		'/intranet-timesheet2-tasks/view', -- page_url
		null,                           -- view_name
		5,                              -- sort_order
		'im_timesheet_task_convert_to_subproject_component -task_id $task_id' -- component_tcl
);

create or replace function inline_0 ()
returns integer as'
declare

		-- Groups
		v_group_id_employees                integer;
		v_plugin_id 	   	            integer;

begin
		select group_id into v_group_id_employees from groups where group_name = ''Employees'';

		select  plugin_id
		into    v_plugin_id
		from    im_component_plugins pl
		where   plugin_name = ''Project Task to Subproject Converter'';

		PERFORM im_grant_permission(v_plugin_id, v_group_id_employees, ''read'');

		return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


