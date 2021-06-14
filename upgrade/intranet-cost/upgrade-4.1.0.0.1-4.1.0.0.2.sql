-- upgrade-4.1.0.0.1-4.1.0.0.2.sql
SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-4.1.0.0.1-4.1.0.0.2.sql','');
SELECT im_category_new (3816,'Requested','Intranet Cost Status');
SELECT im_category_new (3818,'Rejected','Intranet Cost Status');
SELECT im_category_new (3820,'Accepted','Intranet Cost Status');
