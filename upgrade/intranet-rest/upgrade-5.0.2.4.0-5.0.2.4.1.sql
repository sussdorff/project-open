SELECT acs_log__debug('/packages/intranet-rest/sql/postgresql/upgrade/upgrade-5.0.2.4.0-5.0.2.4.1.sql','');

-- Add support for custom types
SELECT im_category_new (43110, 'Custom', 'Intranet REST Custom Object Type Type');
