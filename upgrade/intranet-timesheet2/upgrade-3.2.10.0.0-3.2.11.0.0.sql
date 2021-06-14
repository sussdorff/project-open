-- upgrade-3.2.10.0.0-3.2.11.0.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-3.2.10.0.0-3.2.11.0.0.sql','');


-- New Privilege to allow accounting guys to change hours
select acs_privilege__create_privilege('add_hours_all','Edit Hours All','Edit Hours All');
select acs_privilege__add_child('admin', 'add_hours_all');

select im_priv_create('add_hours_all', 'Accounting');
select im_priv_create('add_hours_all', 'P/O Admins');
select im_priv_create('add_hours_all', 'Senior Managers');

