-- upgrade-4.0.5.0.6-4.0.5.0.7.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.5.0.6-4.0.5.0.7.sql','');

alter table im_categories add column visible_tcl varchar(1000);