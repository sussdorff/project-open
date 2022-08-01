-- upgrade-5.0.2.0.0-5.0.2.0.1.sql

SELECT acs_log__debug('/packages/intranet-reporting-indicators/sql/postgresql/upgrade/upgrade-5.0.2.0.0-5.0.2.0.1.sql','');

UPDATE im_component_plugins set component_tcl = 'im_indicator_timeline_component -indicator_section_id [im_indicator_section_pm]' 
where plugin_name = 'Project Indicators Timeline' and package_name = 'intranet-reporting-indicators'; 

