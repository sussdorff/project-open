-- upgrade-5.0.2.2.0-5.0.2.2.1.sql
SELECT acs_log__debug('/packages/intranet-crm-opportunities/sql/postgresql/upgrade/upgrade-5.0.2.2.0-5.0.2.2.1.sql','');


-- Fix issue in previous update script
update im_menus
set visible_tcl = '[im_permission $user_id "add_projects"]'
where visible_tcl = 'im_permission $user_id "add_projects"';

