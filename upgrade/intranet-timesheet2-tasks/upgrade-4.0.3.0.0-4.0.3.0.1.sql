-- upgrade-4.0.3.0.0-4.0.3.0.1.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.0.3.0.0-4.0.3.0.1.sql','');




-------------------------------
-- Gantt Task Dependency Type
--

-- Values used for GanttProject(?)
SELECT im_category_new(9650,'Depends', 'Intranet Gantt Task Dependency Type');
SELECT im_category_new(9652,'Sub-Task', 'Intranet Gantt Task Dependency Type');


-- Check for configuration error in previous version
update im_categories set category_id = 9666 where category_id = 9668;
update im_categories set category = 'Depends' where category_id = 9650;

--
-- Values used for MS-project
SELECT im_category_new(9660,'FF (finish-to-finish)', 'Intranet Gantt Task Dependency Type');
update im_categories set aux_int1 = 0 where category_id = 9660;
SELECT im_category_new(9662,'FS (finish-to-start)', 'Intranet Gantt Task Dependency Type');
update im_categories set aux_int1 = 1 where category_id = 9662;
SELECT im_category_new(9664,'SF (start-to-finish)', 'Intranet Gantt Task Dependency Type');
update im_categories set aux_int1 = 2 where category_id = 9664;
SELECT im_category_new(9666,'SS (start-to-start)', 'Intranet Gantt Task Dependency Type');
update im_categories set aux_int1 = 3 where category_id = 9666;


