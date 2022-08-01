-- 5.0.2.3.0-5.0.2.3.1.sql
SELECT acs_log__debug('/packages/intranet-rule-engine/sql/postgresql/upgrade/upgrade-5.0.2.3.0-5.0.2.3.1.sql','');

SELECT im_category_new (85204, 'Cron24', 'Intranet Rule Invocation Type');
