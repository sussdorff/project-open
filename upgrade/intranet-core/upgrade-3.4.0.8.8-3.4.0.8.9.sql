-- upgrade-3.4.0.8.8-3.4.0.8.9.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.8.8-3.4.0.8.9.sql','');




-- Add a gif for every object type

create or replace function inline_0 ()
returns integer as $body$
declare
	v_count		integer;
begin
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'acs_object_types' and lower(column_name) = 'object_type_gif';
	IF v_count > 0 THEN return 1; END IF;

	alter table acs_object_types
	add object_type_gif text default 'default_object_type_gif';

	RETURN 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



update acs_object_types set object_type_gif = 'table'			where object_type = 'im_biz_object';
update acs_object_types set object_type_gif = 'link'			where object_type = 'im_biz_object_member';
update acs_object_types set object_type_gif = 'package'			where object_type = 'im_company';
update acs_object_types set object_type_gif = 'link'			where object_type = 'im_company_employee_rel';
update acs_object_types set object_type_gif = 'plugin'			where object_type = 'im_component_plugin';
update acs_object_types set object_type_gif = 'computer'		where object_type = 'im_conf_item';
update acs_object_types set object_type_gif = 'link'			where object_type = 'im_conf_item_project_rel';
update acs_object_types set object_type_gif = 'page_world'		where object_type = 'im_cost';
update acs_object_types set object_type_gif = 'calculator' 		where object_type = 'im_cost_center';
update acs_object_types set object_type_gif = 'table_add'		where object_type = 'im_dynfield_attribute';
update acs_object_types set object_type_gif = 'table_edit'		where object_type = 'im_dynfield_widget';
update acs_object_types set object_type_gif = 'money'			where object_type = 'im_expense';
update acs_object_types set object_type_gif = 'money_add'		where object_type = 'im_expense_bundle';
update acs_object_types set object_type_gif = 'comment'			where object_type = 'im_forum_topic';
update acs_object_types set object_type_gif = 'phone'			where object_type = 'im_freelance_rfq';
update acs_object_types set object_type_gif = 'phone_sound'		where object_type = 'im_freelance_rfq_answer';
update acs_object_types set object_type_gif = 'folder_page'		where object_type = 'im_fs_file';
update acs_object_types set object_type_gif = 'user_suit'		where object_type = 'im_gantt_person';
update acs_object_types set object_type_gif = 'cog'			where object_type = 'im_gantt_project';
update acs_object_types set object_type_gif = 'report_key'		where object_type = 'im_indicator';
update acs_object_types set object_type_gif = 'page_add'		where object_type = 'im_investment';
update acs_object_types set object_type_gif = 'page'			where object_type = 'im_invoice';
update acs_object_types set object_type_gif = 'page_link'		where object_type = 'im_invoice_item';
update acs_object_types set object_type_gif = 'link'			where object_type = 'im_key_account_rel';
update acs_object_types set object_type_gif = 'link'			where object_type = 'im_mail_from';
update acs_object_types set object_type_gif = 'link'			where object_type = 'im_mail_to';
update acs_object_types set object_type_gif = 'link'			where object_type = 'im_mail_related_to';
update acs_object_types set object_type_gif = 'box'			where object_type = 'im_material';
update acs_object_types set object_type_gif = 'palette'			where object_type = 'im_menu';
update acs_object_types set object_type_gif = 'note'			where object_type = 'im_note';
update acs_object_types set object_type_gif = 'package_link'		where object_type = 'im_office';
update acs_object_types set object_type_gif = 'group'			where object_type = 'im_profile';
update acs_object_types set object_type_gif = 'cog'			where object_type = 'im_project';
update acs_object_types set object_type_gif = 'sum'			where object_type = 'im_release_item';
update acs_object_types set object_type_gif = 'page_refresh'		where object_type = 'im_repeating_cost';
update acs_object_types set object_type_gif = 'report'			where object_type = 'im_report';
update acs_object_types set object_type_gif = 'table_sort'		where object_type = 'im_rest_object_type';
update acs_object_types set object_type_gif = 'tag_blue'		where object_type = 'im_ticket';
update acs_object_types set object_type_gif = 'tag_blue_add'		where object_type = 'im_ticket_queue';
update acs_object_types set object_type_gif = 'link'			where object_type = 'im_ticket_ticket_rel';
update acs_object_types set object_type_gif = 'tab'			where object_type = 'im_timesheet_conf_object';
update acs_object_types set object_type_gif = 'page_green'		where object_type = 'im_timesheet_invoice';
update acs_object_types set object_type_gif = 'cog_go'			where object_type = 'im_timesheet_task';
update acs_object_types set object_type_gif = 'page_red'		where object_type = 'im_trans_invoice';
update acs_object_types set object_type_gif = 'cog_edit'		where object_type = 'im_trans_task';
update acs_object_types set object_type_gif = 'cup'			where object_type = 'im_user_absence';

-- Important OpenACS object types
update acs_object_types set object_type_gif = 'email_edit'		where object_type = 'acs_mail_body';
update acs_object_types set object_type_gif = 'email_open'		where object_type = 'acs_mail_gc_object';
update acs_object_types set object_type_gif = 'email_link'		where object_type = 'acs_mail_link';
update acs_object_types set object_type_gif = 'email_link'		where object_type = 'acs_mail_multipart';
update acs_object_types set object_type_gif = 'email_attach'		where object_type = 'acs_mail_queue_message';
update acs_object_types set object_type_gif = 'email'			where object_type = 'acs_message';
update acs_object_types set object_type_gif = 'table'			where object_type = 'acs_object';
update acs_object_types set object_type_gif = 'telephone'		where object_type = 'authority';
update acs_object_types set object_type_gif = 'bug'			where object_type = 'bt_bug';
update acs_object_types set object_type_gif = 'bug_edit'		where object_type = 'bt_bug_revision';
update acs_object_types set object_type_gif = 'bug_go'			where object_type = 'bt_patch';
update acs_object_types set object_type_gif = 'date'			where object_type = 'calendar';
update acs_object_types set object_type_gif = 'date_edit'		where object_type = 'cal_item';
update acs_object_types set object_type_gif = 'group_gear'		where object_type = 'group';
update acs_object_types set object_type_gif = 'bell'			where object_type = 'notification';
update acs_object_types set object_type_gif = 'bell_delete'		where object_type = 'notification_delivery_method';
update acs_object_types set object_type_gif = 'bell_add'		where object_type = 'notification_interval';
update acs_object_types set object_type_gif = 'bell_go'			where object_type = 'notification_reply';
update acs_object_types set object_type_gif = 'bell_link'		where object_type = 'notification_request';
update acs_object_types set object_type_gif = 'bell_error'		where object_type = 'notification_type';
update acs_object_types set object_type_gif = 'package'			where object_type = 'apm_application';
update acs_object_types set object_type_gif = 'package'			where object_type = 'apm_package';
update acs_object_types set object_type_gif = 'package_green'		where object_type = 'apm_package_version';
update acs_object_types set object_type_gif = 'package_link'		where object_type = 'apm_parameter';
update acs_object_types set object_type_gif = 'package_link'		where object_type = 'apm_parameter_value';
update acs_object_types set object_type_gif = 'package'			where object_type = 'apm_service';
update acs_object_types set object_type_gif = 'user_red'		where object_type = 'party';
update acs_object_types set object_type_gif = 'user_green'		where object_type = 'person';
update acs_object_types set object_type_gif = 'script_gear'		where object_type = 'survsimp_question';
update acs_object_types set object_type_gif = 'script_save'		where object_type = 'survsimp_response';
update acs_object_types set object_type_gif = 'script'			where object_type = 'survsimp_survey';
update acs_object_types set object_type_gif = 'user'			where object_type = 'user';

-- Relationships
update acs_object_types set object_type_gif = 'link'			where object_type = 'admin_rel';
update acs_object_types set object_type_gif = 'link'			where object_type = 'composition_rel';
update acs_object_types set object_type_gif = 'link'			where object_type = 'cr_item_child_rel';
update acs_object_types set object_type_gif = 'link'			where object_type = 'cr_item_rel';
update acs_object_types set object_type_gif = 'link'			where object_type = 'membership_rel';
update acs_object_types set object_type_gif = 'link'			where object_type = 'relationship';
update acs_object_types set object_type_gif = 'link'			where object_type = 'user_blob_response_rel';
update acs_object_types set object_type_gif = 'link'			where object_type = 'user_portrait_rel';

-- Workflow
update acs_object_types set object_type_gif = 'arrow_refresh'		where object_type = 'workflow';
update acs_object_types set object_type_gif = 'arrow_refresh'		where object_type = 'ticket_generic_wf';
update acs_object_types set object_type_gif = 'arrow_refresh'		where object_type = 'ticket_workflow_generic_wf';
update acs_object_types set object_type_gif = 'arrow_refresh'		where object_type = 'timesheet_approval_wf';
update acs_object_types set object_type_gif = 'arrow_refresh'		where object_type = 'vacation_approval_wf';
update acs_object_types set object_type_gif = 'arrow_refresh'		where object_type = 'workflow_case_log_entry';
update acs_object_types set object_type_gif = 'arrow_refresh' 		where object_type = 'expense_approval_wf';
update acs_object_types set object_type_gif = 'arrow_refresh' 		where object_type = 'feature_request_wf';
update acs_object_types set object_type_gif = 'arrow_refresh' 		where object_type = 'project_approval_wf';
update acs_object_types set object_type_gif = 'arrow_refresh' 		where object_type = 'rfc_approval_wf';


-- Less used OpenACS object types
update acs_object_types set object_type_gif = 'default_object_type_gif'	where object_type = 'acs_activity';
update acs_object_types set object_type_gif = 'lightning'		where object_type = 'acs_event';
update acs_object_types set object_type_gif = 'email'			where object_type = 'acs_message_revision';
update acs_object_types set object_type_gif = 'default_object_type_gif'	where object_type = 'acs_named_object';
update acs_object_types set object_type_gif = 'default_object_type_gif'	where object_type = 'acs_reference_repository';

update acs_object_types set object_type_gif = 'script'			where object_type = 'acs_sc_contract';
update acs_object_types set object_type_gif = 'script_palette'		where object_type = 'acs_sc_implementation';
update acs_object_types set object_type_gif = 'script_code'		where object_type = 'acs_sc_msg_type';
update acs_object_types set object_type_gif = 'script_go'		where object_type = 'acs_sc_operation';

update acs_object_types set object_type_gif = 'default_object_type_gif'	where object_type = 'ams_object_revision';
update acs_object_types set object_type_gif = 'default_object_type_gif'	where object_type = 'application_group';
update acs_object_types set object_type_gif = 'comments'		where object_type = 'chat_room';
update acs_object_types set object_type_gif = 'comment_edit'		where object_type = 'chat_transcript';

update acs_object_types set object_type_gif = 'image_link'		where object_type = 'content_extlink';
update acs_object_types set object_type_gif = 'folder_image'		where object_type = 'content_folder';
update acs_object_types set object_type_gif = 'image'			where object_type = 'content_item';
update acs_object_types set object_type_gif = 'image_add'		where object_type = 'content_keyword';
update acs_object_types set object_type_gif = 'folder_image'		where object_type = 'content_module';
update acs_object_types set object_type_gif = 'image_edit'		where object_type = 'content_revision';
update acs_object_types set object_type_gif = 'image_link'		where object_type = 'content_symlink';
update acs_object_types set object_type_gif = 'images'			where object_type = 'content_template';

update acs_object_types set object_type_gif = 'default_object_type_gif'	where object_type = 'dynamic_group_type';
update acs_object_types set object_type_gif = 'page_world'		where object_type = 'etp_page_revision';
update acs_object_types set object_type_gif = 'image'			where object_type = 'image';

update acs_object_types set object_type_gif = 'layout_content'		where object_type = 'journal_article';
update acs_object_types set object_type_gif = 'layout'			where object_type = 'journal_entry';
update acs_object_types set object_type_gif = 'layout_header'		where object_type = 'journal_issue';

update acs_object_types set object_type_gif = 'newspaper'		where object_type = 'news_item';
update acs_object_types set object_type_gif = 'default_object_type_gif'	where object_type = 'postal_address';
update acs_object_types set object_type_gif = 'link_error'		where object_type = 'rel_constraint';
update acs_object_types set object_type_gif = 'link_add'		where object_type = 'rel_segment';
update acs_object_types set object_type_gif = 'sitemap'			where object_type = 'site_node';
update acs_object_types set object_type_gif = 'default_object_type_gif'	where object_type = 'workflow_lite';
