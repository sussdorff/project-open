-- upgrade-4.1.0.1.5-4.1.0.1.6.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.0.1.5-4.1.0.1.6.sql','');


-- PostgreSQL 9.x related issues

drop view if exists timespan_seq;

update im_component_plugins set sort_order = 20 where plugin_name = 'User Contact Information';
update im_component_plugins set sort_order = 50 where plugin_name = 'User Admin Information';
update im_component_plugins set sort_order = 100 where plugin_name = 'User Skin Information';
update im_component_plugins set sort_order = 200 where plugin_name = 'Vacation Balance';


