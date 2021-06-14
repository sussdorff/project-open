-- upgrade-4.0.1.0.2-4.0.1.0.3.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.0.1.0.2-4.0.1.0.3.sql','');

select acs_privilege__create_privilege('add_hours_direct_reports','Add hours for direct reports','');
select acs_privilege__add_child('admin', 'add_hours_direct_reports');

