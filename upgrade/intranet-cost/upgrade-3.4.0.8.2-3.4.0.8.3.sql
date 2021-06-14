-- upgrade-3.4.0.8.2-3.4.0.8.3.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-3.4.0.8.2-3.4.0.8.3.sql','');

-- Add types from Inter-Company invoicing
SELECT im_category_new (3730,'InterCo Invoice','Intranet Cost Type');
SELECT im_category_new (3732,'InterCo Quote','Intranet Cost Type');

-- Add Provider Receipt for NAV integration
SELECT im_category_new (3734,'Provider Receipt','Intranet Cost Type');

