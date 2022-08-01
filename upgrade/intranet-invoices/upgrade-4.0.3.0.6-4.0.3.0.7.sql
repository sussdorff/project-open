-- upgrade-4.0.3.0.6-4.0.3.0.7.sql
SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.0.3.0.6-4.0.3.0.7.sql','');

update im_view_columns set column_name = 'Document No' where column_name = 'Document #';
