-- upgrade-4.0.5.0.7-4.0.5.0.8.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.5.0.7-4.0.5.0.8.sql','');


-- Fix wrong link to workflow package
update im_menus set url = '/acs-workflow/admin/' where url = '/workflow/admin/';


