-- /packages/intranet-cost/sql/postgres/upgrade/upgrade-3.4.0.2.0-3.4.0.2.1.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-3.4.0.2.0-3.4.0.2.1.sql','');



SELECT im_category_new (3726,'Timesheet Planned Cost','Intranet Cost Type');
SELECT im_category_new (3728,'Expense Planned Cost','Intranet Cost Type');

