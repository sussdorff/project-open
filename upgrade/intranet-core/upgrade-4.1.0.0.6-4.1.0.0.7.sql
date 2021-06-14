-- upgrade-4.1.0.0.6-4.1.0.0.7.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.0.0.6-4.1.0.0.7.sql','');


-- Fix localization errors that will break task editing and others
update lang_messages set message = 'MONTH DD YYYY' where locale = 'fr_FR' and message_key = 'localization-formbuilder_date_format';
update lang_messages set message = 'MONTH DD YYYY' where locale = 'nl_NL' and message_key = 'localization-formbuilder_date_format';
update lang_messages set message = 'MONTH DD YYYY' where locale = 'no_NO' and message_key = 'localization-formbuilder_date_format';
update lang_messages set message = 'DD MONTH YYYY' where locale = 'tr_TR' and message_key = 'localization-formbuilder_date_format';


-- Fix SQL Metadata for im_company_employee_rel
-- This fixes a bug in the REST interface
update acs_object_type_tables
set table_name = 'im_company_employee_rels'
where table_name = 'im_company_employee_rel';

-- Update a messae translation with unquoted HTML characters
update lang_messages
set message = 'C&amp;KM Help'
where message = 'C&KM Help';

