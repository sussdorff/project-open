-- upgrade-4.0.2.0.4-4.0.2.0.5.sql
SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-4.0.2.0.4-4.0.2.0.5.sql','');

-- New privilege defining permission to see internal rates 
-- An employee might be entitled to see external rates only   

select acs_privilege__create_privilege('fi_view_internal_rates','FI View internal rates','FI View internal rates');
select acs_privilege__add_child('admin', 'fi_view_internal_rates');

select im_priv_create('fi_view_internal_rates', 'P/O Admins');
select im_priv_create('fi_view_internal_rates', 'Senior Managers');

