-- upgrade-3.2.3.0.0-3.2.4.0.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-3.2.3.0.0-3.2.4.0.0.sql','');

\i ../../../../intranet-core/sql/postgresql/upgrade/upgrade-3.0.0.0.first.sql


------------------------------------------------------
-- Permissions and Privileges
--

-- view_timesheet_tasks actually is more of an obligation then a privilege...
select acs_privilege__create_privilege(
	'view_timesheet_tasks',
	'View Timesheet Task',
	'View Timesheet Task'
);
select acs_privilege__add_child('admin', 'view_timesheet_tasks');


select im_priv_create('view_timesheet_tasks', 'Accounting');
select im_priv_create('view_timesheet_tasks', 'Employees');
select im_priv_create('view_timesheet_tasks', 'P/O Admins');
select im_priv_create('view_timesheet_tasks', 'Project Managers');
select im_priv_create('view_timesheet_tasks', 'Sales');
select im_priv_create('view_timesheet_tasks', 'Senior Managers');



------------------------------------------------------
-- Set permissions of the "Tasks" tab 
update im_menus
set visible_tcl = '[expr [im_permission $user_id view_timesheet_tasks] && [im_project_has_type [ns_set get $bind_vars project_id] "Consulting Project"]]'
where label = 'project_timesheet_task';




------------------------------------------------------
-- Update Timesheet Tasks Status to Project Status
--
-- Cleanup Stati configuration mess

update im_projects
set project_status_id = 76
where project_status_id = 9600;

update im_projects
set project_status_id = 81
where project_status_id = 9602;


-- Cleanup Type Configuration Mess

update im_projects
set project_type_id = 100
where project_type_id = 84;

update im_invoice_items
set item_type_id = 100
where item_type_id = 84;


-- im_trans_tasks dont exist anymore at this upgrade time
-- update im_trans_tasks
-- set task_type_id = 100
-- where task_type_id = 84;

delete from im_categories
where category_id = 84;

update im_projects
set project_type_id = 100
where project_type_id = 9500;



