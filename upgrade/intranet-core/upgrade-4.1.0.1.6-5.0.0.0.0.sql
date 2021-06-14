-- upgrade-4.1.0.1.6-5.0.0.0.0.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.0.1.6-5.0.0.0.0.sql','');

SELECT im_lang_add_message('en_US','intranet-confdb','Apply','Apply');
SELECT im_lang_add_message('en_US','intranet-contacts','Contacts','Contacts');
SELECT im_lang_add_message('en_US','intranet-ganttproject','Dim_','Dim');
SELECT im_lang_add_message('en_US','intranet-translation','Trans_Langs','Trans Langs');
SELECT im_lang_add_message('en_US','intranet-invoices','clone','Clone');
SELECT im_lang_add_message('en_US','intranet-hr','Salary_period_','Salary Period');
-- SELECT im_lang_add_message('en_US','intranet-','','');
