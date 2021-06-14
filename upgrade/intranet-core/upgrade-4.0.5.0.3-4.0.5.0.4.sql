-- upgrade-4.0.5.0.2-4.0.5.0.3.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.5.0.3-4.0.5.0.4.sql','');


-- fraber 131230: Disabling the Member State column
-- The column contains an error and is also not necessary
