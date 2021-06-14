-- upgrade-4.0.2.0.2-4.0.2.0.3.sql
SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-4.0.2.0.2-4.0.2.0.3.sql','');

SELECT im_category_new (3736,'Timesheet Hours','Intranet Cost Type');

