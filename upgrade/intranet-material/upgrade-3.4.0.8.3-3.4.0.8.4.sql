-- upgrade-3.4.0.8.3-3.4.0.8.4.sql

SELECT acs_log__debug('/packages/intranet-material/sql/postgresql/upgrade/upgrade-3.4.0.8.3-3.4.0.8.4.sql','');


-------------------------------
-- Material Types
-- delete from im_categories where category_type = 'Intranet Material Type';

SELECT im_category_new(9000, 'Other', 'Intranet Material Type');
SELECT im_category_new(9002, 'Maintenance', 'Intranet Material Type');
SELECT im_category_new(9004, 'Licenses', 'Intranet Material Type');
SELECT im_category_new(9006, 'Consulting', 'Intranet Material Type');
SELECT im_category_new(9008, 'Software Dev.', 'Intranet Material Type');
SELECT im_category_new(9010, 'Web Site Dev.', 'Intranet Material Type');
SELECT im_category_new(9012, 'Generic PM', 'Intranet Material Type');
SELECT im_category_new(9014, 'Translation', 'Intranet Material Type');

-- reserved until 9099
