-- upgrade-5.0.0.0.6-5.0.0.0.7.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.0.0.6-5.0.0.0.7.sql','');

ALTER TABLE auth_authorities ALTER COLUMN short_name SET NOT NULL;
