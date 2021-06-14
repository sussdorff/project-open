-- upgrade-4.0.5.0.0-4.0.5.0.1.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-4.0.5.0.0-4.0.5.0.1.sql','');

update im_menus
set url = '/intranet-cost/index'
where label = 'finance' and url = '/intranet-invoices/list';

