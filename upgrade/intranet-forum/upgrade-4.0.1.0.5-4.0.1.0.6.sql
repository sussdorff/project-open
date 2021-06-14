-- upgrade-4.0.1.0.5-4.0.1.0.6.sql
SELECT acs_log__debug('/packages/intranet-forum/sql/postgresql/upgrade/upgrade-4.0.1.0.5-4.0.1.0.6.sql','');

-- Remove the possibility to create new forum topics from the home page
-- Creating topics from the HomeComponent ist inconsistent currently
update im_component_plugins
set title_tcl = '_ intranet-forum.Forum_Items'
where plugin_name = 'Home Forum Component';
