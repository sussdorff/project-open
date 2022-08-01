-- 5.0.1.0.0-5.0.1.0.1.sql
SELECT acs_log__debug('/packages/intranet-rule-engine/sql/postgresql/upgrade/upgrade-5.0.1.0.0-5.0.1.0.1.sql','');

-- Does not need a v_count check, because it can be executed multiple times...
alter table im_rule_logs alter column rule_log_date set default now();

