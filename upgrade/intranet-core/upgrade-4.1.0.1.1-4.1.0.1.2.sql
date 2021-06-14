-- 4.1.0.1.1-4.1.0.1.2.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.0.1.1-4.1.0.1.2.sql','');


-- Rename "Consulting Project" into "Gantt Project"
update im_categories
set category = 'Gantt Project'
where category = 'Consulting Project' and category_type = 'Intranet Project Type';

update apm_parameter_values
set attr_value = 'Gantt Project'
where attr_value = 'Consulting Project';

update apm_parameters
set default_value = 'Gantt Project'
where default_value = 'Consulting Project';

update im_menus
set visible_tcl = '[expr [im_permission $user_id view_timesheet_tasks] && [im_project_has_type [ns_set get $bind_vars project_id] "Gantt Project"]]'
where visible_tcl = '[expr [im_permission $user_id view_timesheet_tasks] && [im_project_has_type [ns_set get $bind_vars project_id] "Consulting Project"]]';



