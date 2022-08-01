-- 5.0.2.4.2-5.0.2.4.3.sql
SELECT acs_log__debug('/packages/intranet-rule-engine/sql/postgresql/upgrade/upgrade-5.0.2.4.2-5.0.2.4.3.sql','');





-- Create a Rule plugin for the RiskViewPage.
SELECT im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',			-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'Risk Rule Audit',			-- plugin_name
	'intranet-rule-engine',			-- package_name
	'left',					-- location
	'/intranet-riskmanagement/view',		-- page_url
	null,					-- view_name
	900,					-- sort_order
	'im_rule_audit_component -object_id $risk_id'	-- component_tcl
);

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-rule-engine.Risk_Rule_Audit "Risk Rule Audit"'
where plugin_name = 'Risk Rule Audit';



