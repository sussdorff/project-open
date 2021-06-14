-- upgrade-3.4.1.0.0-3.4.1.0.1.sql

SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-3.4.1.0.0-3.4.1.0.1.sql','');

-- set privilege for "Admin Actions" on /web/projop/packages/acs-workflow/www/task.tcl 

select acs_privilege__create_privilege('wf_suspend_case','Suspend workflow case','');
select acs_privilege__add_child('admin', 'wf_suspend_case');

select im_priv_create('wf_suspend_case','Accounting');
select im_priv_create('wf_suspend_case','P/O Admins');
select im_priv_create('wf_suspend_case','Senior Managers');


select acs_privilege__create_privilege('wf_cancel_case','Cancel workflow case','');
select acs_privilege__add_child('admin', 'wf_cancel_case');

select im_priv_create('wf_cancel_case','Accounting');
select im_priv_create('wf_cancel_case','P/O Admins');
select im_priv_create('wf_cancel_case','Senior Managers');

