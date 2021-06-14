-- upgrade-3.4.0.7.7-3.4.0.7.8.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.7.7-3.4.0.7.8.sql','');

update im_categories set category_description = 'Unknown project type' where category = 'Unknown' and category_type = 'Intranet Project Type';
update im_categories set category_description = 'The project doesn''t fit in any category' where category = 'Other' and category_type = 'Intranet Project Type';
update im_categories set category_description = 'Timesheet Task (should not be visible)' where category = 'Task' and category_type = 'Intranet Project Type';
update im_categories set category_description = 'Helpdesk Ticket (should not be visible)' where category = 'Ticket' and category_type = 'Intranet Project Type';

update im_categories set category_description = 'Generic translation project' where category = 'Translation Project' and category_type = 'Intranet Project Type';
update im_categories set category_description = 'Translation project with a Trans + Edit static workflow' where category = 'Trans + Edit' and category_type = 'Intranet Project Type';
update im_categories set category_description = 'Translation project with a Edit Only static workflow' where category = 'Edit Only' and category_type = 'Intranet Project Type';
update im_categories set category_description = 'Translation project with a Trans + Edit + Proof static workflow' where category = 'Trans + Edit + Proof' and category_type = 'Intranet Project Type';
update im_categories set category_description = 'Translation project performing Linguistic Validation' where category = 'Linguistic Validation' and category_type = 'Intranet Project Type';
update im_categories set category_description = 'Translation project performing Localization activities' where category = 'Localization' and category_type = 'Intranet Project Type';
update im_categories set category_description = 'Translation project performing Technological activities' where category = 'Technology' and category_type = 'Intranet Project Type';
update im_categories set category_description = 'Translation project with a Trans Only static workflow' where category = 'Trans Only' and category_type = 'Intranet Project Type';
update im_categories set category_description = 'Translation project with a Trans + Int. Spotcheck static workflow' where category = 'Trans + Int. Spotcheck' and category_type = 'Intranet Project Type';
update im_categories set category_description = 'Translation project with a Proof Only static workflow' where category = 'Proof Only' and category_type = 'Intranet Project Type';
update im_categories set category_description = 'Translation project performing Glossary Compilation activities' where category = 'Glossary Compilation' and category_type = 'Intranet Project Type';
update im_categories set category_description = 'Translation project with a sample dynamic workflow (test/demo)' where category = 'Trans Only (Dynamic WF)' and category_type = 'Intranet Project Type';

update im_categories set category_description = 'Generic consulting project or any other project based on a Gantt schedule and Gantt tasks' where category = 'Consulting Project' and category_type = 'Intranet Project Type';
update im_categories set category_description = 'Strategic consulting ' where category = 'Strategic Consulting' and category_type = 'Intranet Project Type';
update im_categories set category_description = 'Ongoing software maintenance' where category = 'Software Maintenance' and category_type = 'Intranet Project Type';
update im_categories set category_description = 'Software development' where category = 'Software Development' and category_type = 'Intranet Project Type';


update im_categories set category_description = 'Service contract with a customer. Contains Helpdesk tickets as sub-items' where category = 'Service Level Agreement' and category_type = 'Intranet Project Type';
update im_categories set category_description = 'Milestones appear in the Milestone dashboard' where category = 'Milestone' and category_type = 'Intranet Project Type';

update im_categories set category_description = 'Container project for Bug Tracker tasks' where category = 'Bug Tracker Container' and category_type = 'Intranet Project Type';
update im_categories set category_description = 'Bug Tracker task' where category = 'Bug Tracker Task' and category_type = 'Intranet Project Type';

update im_categories set category_description = 'Represents the items of a software release project' where category = 'Software Release Item' and category_type = 'Intranet Project Type';
update im_categories set category_description = 'Represents a software release, consisting of several software release items' where category = 'Software Release' and category_type = 'Intranet Project Type';
