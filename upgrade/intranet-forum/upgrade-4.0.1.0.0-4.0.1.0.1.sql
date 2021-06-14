-- upgrade-4.0.1.0.0-4.0.1.0.1.sql

SELECT acs_log__debug('/packages/intranet-forum/sql/postgresql/upgrade/upgrade-4.0.1.0.0-4.0.1.0.1.sql','');

-- User that should be added as topic assignees  
select acs_privilege__create_privilege('add_topic_assignee','Add Topic Assignee','Add Topic Assignee');
select acs_privilege__add_child('admin', 'add_topic_assignee');
