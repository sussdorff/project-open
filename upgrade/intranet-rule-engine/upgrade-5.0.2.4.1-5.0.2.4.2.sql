-- 5.0.2.4.1-5.0.2.4.2.sql
SELECT acs_log__debug('/packages/intranet-rule-engine/sql/postgresql/upgrade/upgrade-5.0.2.4.1-5.0.2.4.2.sql','');

update im_rules
set rule_action_tcl = 'db_dml insert "insert into im_rule_logs (
	rule_log_object_id, rule_log_rule_id, rule_log_user_id, 
	rule_log_ip, rule_log_error_source, rule_log_error_statement, 
	rule_log_error_message, rule_log_error_env
) values (
	$new(task_id), $new(rule_id), $new(user_id), 
	''0.0.0.0'', ''task_start_notification'', ''-'', 
	''ok'', ''-'')"'
where 
	(rule_name = 'Task scheduled to start notification' OR
	rule_name = 'Task start notification to members')
;

