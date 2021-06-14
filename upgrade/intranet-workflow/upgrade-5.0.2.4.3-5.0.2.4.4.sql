-- upgrade-5.0.2.4.3-5.0.2.4.4.sql
SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-5.0.2.4.3-5.0.2.4.4.sql','');


update im_component_plugins
set component_tcl = 'im_workflow_home_inbox_component -filter_object_type [im_opt_val filter_object_type] -filter_workflow_key [im_opt_val filter_workflow_key] -filter_subtype_id [im_opt_val filter_subtype_id] -filter_status_id [im_opt_val filter_status_id] -filter_owner_id [im_opt_val filter_owner_id] -filter_wf_action [im_opt_val filter_wf_action]'
where plugin_name = 'Home Workflow Inbox';

