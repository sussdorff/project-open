-- upgrade-3.3.1.2.0-3.3.1.2.1.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-3.3.1.2.0-3.3.1.2.1.sql','');


-- Define write permissions to the "members" box by project_write.

update im_component_plugins 
set   component_tcl = 'im_group_member_component $task_id $current_user_id $project_write $return_url "" "" 1' 
where component_tcl = 'im_group_member_component $task_id $current_user_id $user_admin_p $return_url "" "" 1';

