-- upgrade-4.1.0.0.1-4.1.0.0.2.sql

SELECT acs_log__debug('/packages/intranet-mail/sql/postgresql/upgrade/upgrade-4.1.0.0.2-4.1.0.0.3.sql','');


alter table acs_mail_log add column filesystem_files text;