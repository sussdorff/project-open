-- upgrade-4.1.0.0.0-4.1.0.0.1.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.0.0.0-4.1.0.0.1.sql','');

-- Disable the ASUS backup component at the moment
update im_component_plugins
set enabled_p = 'f'
where plugin_name in ('ASUS Backup', 'Home Page Help Blurb');

