-- intranet-reporting-dashboard/sql/postgresql/upgrade/upgrade/upgrade-5.0.2.3.0-5.0.2.3.1.sql

SELECT acs_log__debug('/packages/intranet-reporting-dashboard/sql/postgresql/upgrade/upgrade-5.0.2.3.0-5.0.2.3.1.sql','');

-- Delete the "all time top services" portlet
select im_component_plugin__delete(
       (select min(plugin_id) 
       from im_component_plugins 
       where plugin_name = 'Home All-Time Top Services')
);
