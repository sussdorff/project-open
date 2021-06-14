-- upgrade-5.0.0.0.0-5.0.0.0.1.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-workflow/sql/postgresql/upgrade/upgrade-5.0.0.0.0-5.0.0.0.1.sql','');


select im_menu__delete (
       (select menu_id from im_menus where name = 'Start Confirmation Workflow')
);




