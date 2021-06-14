-- upgrade-5.0.2.4.1-5.0.2.4.2.sql
SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-5.0.2.4.1-5.0.2.4.2.sql','');


-- ------------------------------------------------------
-- Components
-- ------------------------------------------------------


-- Financial Document WF Graph
--
SELECT im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',				-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'Financial Document Workflow Graph',		-- plugin_name
	'intranet-workflow',			-- package_name
	'bottom',				-- location
	'/intranet-invoices/view',		-- page_url
	null,					-- view_name
	200,					-- sort_order
	'im_workflow_graph_component -object_id $invoice_id'
);


-- Financial Document WF Journal
--
SELECT im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',			-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'Financial Document Workflow Journal',		-- plugin_name
	'intranet-workflow',			-- package_name
	'bottom',				-- location
	'/intranet-invoices/view',		-- page_url
	null,					-- view_name
	220,					-- sort_order
	'im_workflow_journal_component -object_id $invoice_id'
);
