-- upgrade-4.0.0.0.0-4.0.1.0.0.sql

SELECT acs_log__debug('/packages/intranet-forum/sql/postgresql/upgrade/upgrade-4.0.0.0.0-4.0.1.0.0.sql','');


alter table im_forum_topics alter column topic_name type text;
alter table im_forum_topics alter column topic_path type text;
alter table im_forum_topics alter column subject type text;
alter table im_forum_topics alter column message type text;

