
SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.1.0.0.1-4.1.0.0.2.sql','');

update im_view_columns set column_render_tcl = '"<nobr>$indent_short_html$gif_html<a href=$object_url>$task_name</a></nobr>"' where column_id = 91101;


-- It seems we missed the employee permissions for the task componten

create or replace function inline_0 ()
returns integer as'
declare

				-- Groups
				v_group_id_employees                integer;
				v_plugin_id                         integer;

begin
				select group_id into v_group_id_employees from groups where group_name = ''Employees'';

				select  plugin_id
				into    v_plugin_id
				from    im_component_plugins pl
				where   plugin_name = ''Timesheet Task Info Component'';

				PERFORM im_grant_permission(v_plugin_id, v_group_id_employees, ''read'');

				return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();

create or replace function inline_0 ()
returns integer as'
declare

				-- Groups
				v_group_id_employees                integer;
				v_plugin_id                         integer;

begin
				select group_id into v_group_id_employees from groups where group_name = ''Freelancers'';

				select  plugin_id
				into    v_plugin_id
				from    im_component_plugins pl
				where   plugin_name = ''Timesheet Task Info Component'';

				PERFORM im_grant_permission(v_plugin_id, v_group_id_employees, ''read'');

				return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();