-- upgrade-4.0.5.0.3-4.0.5.0.4.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.0.5.0.3-4.0.5.0.4.sql','');

select acs_privilege__create_privilege('add_absences_all','Add absences all','Add absences all');
select acs_privilege__add_child('create', 'add_absences_all');
select im_priv_create('add_absences_all', 'P/O Admins');
select im_priv_create('add_absences_all', 'HR Managers');
