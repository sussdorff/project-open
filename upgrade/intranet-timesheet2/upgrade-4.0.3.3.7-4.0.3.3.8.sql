-- upgrade-4.0.3.3.7-4.0.3.3.8.sql
SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.0.3.3.7-4.0.3.3.8.sql','');

select acs_privilege__create_privilege('view_absences_direct_reports','View Absences Direct Reports','View Absences Direct Reports');
select acs_privilege__add_child('view', 'view_absences_direct_reports');

select im_priv_create('view_absences_direct_reports', 'Senior Managers');
