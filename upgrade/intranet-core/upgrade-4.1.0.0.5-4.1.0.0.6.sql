-- upgrade-4.1.0.0.5-4.1.0.0.6.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.0.0.5-4.1.0.0.6.sql','');

-- ToDo: Delete privileges
-- select acs_privilege__create_privilege('view_project_members','View Project Members','View Project Members');
-- select acs_privilege__add_child('admin', 'view_project_members');


