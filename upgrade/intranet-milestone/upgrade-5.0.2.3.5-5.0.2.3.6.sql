-- 5.0.2.3.5-5.0.2.3.6.sql
SELECT acs_log__debug('/packages/intranet-milestone/sql/postgresql/upgrade/upgrade-5.0.2.3.5-5.0.2.3.6.sql','');


-----------------------------------------------------------
-- Show Milestone tracker on a project page
--

SELECT im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',			-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'Milestone Slip Tracker',		-- plugin_name
	'intranet-milestone',			-- package_name
	'left',					-- location
	'/intranet/projects/view',		-- page_url
	null,					-- view_name
	100,					-- sort_order
	'im_milestone_tracker -project_id $project_id -diagram_caption "Milestones" -diagram_width 300 -diagram_height 300'
);

SELECT acs_permission__grant_permission(
	(select min(plugin_id) from im_component_plugins where plugin_name = 'Milestone Slip Tracker'),
	(select group_id from groups where group_name = 'Employees'),
	'read'
);


