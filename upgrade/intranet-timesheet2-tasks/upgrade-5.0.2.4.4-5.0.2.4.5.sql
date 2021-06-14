-- upgrade-5.0.2.4.4-5.0.2.4.5.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-5.0.2.4.4-5.0.2.4.5.sql','');



-- 2019-10-19 Fraber: There are somehow bad dependencies in the table.
-- Delete these, and alter the constraints so that constraints point
-- at least to valid projects.
delete from im_timesheet_task_dependencies where task_id_one not in (select project_id from im_projects);
delete from im_timesheet_task_dependencies where task_id_two not in (select project_id from im_projects);

alter table im_timesheet_task_dependencies drop constraint IF EXISTS im_timesheet_task_map_one_fk;
alter table im_timesheet_task_dependencies drop constraint IF EXISTS im_timesheet_task_map_two_fk;

ALTER TABLE im_timesheet_task_dependencies ADD CONSTRAINT im_timesheet_task_map_one_fk FOREIGN KEY (task_id_one) REFERENCES im_projects;
ALTER TABLE im_timesheet_task_dependencies ADD CONSTRAINT im_timesheet_task_map_two_fk FOREIGN KEY (task_id_two) REFERENCES im_projects;

