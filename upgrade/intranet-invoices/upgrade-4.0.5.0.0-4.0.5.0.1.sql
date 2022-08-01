-- upgrade4.0.5.0.0-4.0.5.0.1.sql
SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.0.5.0.0-4.0.5.0.1.sql','');

-- Defined InterCo Quote and Invoices as provider document
-- 
SELECT im_category_hierarchy_new(3730,3708);
SELECT im_category_hierarchy_new(3732,3708);

-- Provider Receipt is a Provider Document
SELECT im_category_hierarchy_new(3734,3710);

-- Add category that marks the VAT to be calculated on line item level
SELECT im_category_new (42021,'Material Based Taxation','Intranet VAT Type');
update im_categories set aux_int1=0 where category_id = 42021;


