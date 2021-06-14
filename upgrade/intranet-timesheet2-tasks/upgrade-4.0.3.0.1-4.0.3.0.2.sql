-- upgrade-4.0.3.0.1-4.0.3.0.2.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.0.3.0.1-4.0.3.0.2.sql','');

drop view im_timesheet_tasks_view;

alter table im_timesheet_tasks alter column planned_units type numeric;
alter table im_timesheet_tasks alter column billable_units type numeric;

create view im_timesheet_tasks_view as SELECT t.task_id, t.material_id, t.uom_id, t.planned_units, t.billable_units, t.cost_center_id, t.invoice_id, t.priority, t.sort_order, t.bt_bug_id, t.gantt_project_id, p.parent_id AS project_id, p.project_name AS task_name, p.project_nr AS task_nr, p.percent_completed, p.project_type_id AS task_type_id, p.project_status_id AS task_status_id, p.start_date, p.end_date, p.reported_hours_cache, p.reported_days_cache, p.reported_hours_cache AS reported_units_cache
   FROM im_projects p, im_timesheet_tasks t
  WHERE t.task_id = p.project_id;