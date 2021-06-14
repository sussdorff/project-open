-- upgrade-3.2.7.0.0-3.2.8.0.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-3.2.7.0.0-3.2.8.0.0.sql','');


select im_component_plugin__del_module('intranet-timesheet2-tasks-info');
select im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',				-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creattion_ip
	null,					-- context_id

	'Project Timesheet Tasks Information',	-- plugin_name
	'intranet-timesheet2-tasks-info',	-- package_name
	'right',				-- location
	'/intranet-timesheet2-tasks/new',		-- page_url
	null,					-- view_name
	50,					-- sort_order
	'im_timesheet_task_info_component $project_id $task_id $return_url'
);


select im_component_plugin__del_module('intranet-timesheet2-tasks-resources');
select im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',				-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creattion_ip
	null,					-- context_id

	'Task Resources',			-- plugin_name
	'intranet-timesheet2-tasks-resources',	-- package_name
	'right',				-- location
	'/intranet-timesheet2-tasks/new',		-- page_url
	null,					-- view_name
	50,					-- sort_order
	'im_timesheet_task_members_component $project_id $task_id $return_url'
);


update im_view_columns
set column_render_tcl = '"<a href=/intranet-cost/cost-centers/new?[export_url_vars cost_center_id return_url]>$cost_center_name</a>"'
where column_id = 91006;

