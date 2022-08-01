-- upgrade-5.0.2.4.2-5.0.2.4.3.sql

SELECT acs_log__debug('/packages/intranet-portfolio-management/sql/postgresql/upgrade/upgrade-5.0.2.4.2-5.0.2.4.3.sql','');






-- ----------------------------------------------------------------
-- Program Portfolio Portlet
-- ----------------------------------------------------------------

SELECT	im_component_plugin__new (
	null,'im_component_plugin',now(),null,null,null,
	'Program Project Status Over Time',	-- plugin_name
	'intranet-portfolio-management', -- package_name
	'right',			-- location
	'/intranet/projects/view',	-- page_url
	null,				-- view_name
	15,				-- sort_order
	'im_program_project_status_over_time_component -program_id $project_id'	-- component_tcl
);
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins where plugin_name = 'Program Project Status Over Time'),
	(select group_id from groups where group_name = 'Employees'),
	'read'
);

