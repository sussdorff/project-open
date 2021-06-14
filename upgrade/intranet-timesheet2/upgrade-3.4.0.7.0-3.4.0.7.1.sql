-- upgrade-3.4.0.7.0-3.4.0.7.1.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-3.4.0.7.0-3.4.0.7.1.sql','');


-- allow for billing rates in lower valuated billing rates
alter table im_hours alter column billing_rate type numeric(7,2);

