-- intranet-reporting-dashboard/sql/postgresql/upgrade/upgrade/upgrade-5.0.2.4.1-5.0.2.4.2.sql

SELECT acs_log__debug('/packages/intranet-reporting-dashboard/sql/postgresql/upgrade/upgrade-5.0.2.4.1-5.0.2.4.2.sql','');



-- Revenues by department
--
SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,
	'Revenue by Department',		-- plugin_name
	'intranet-reporting-dashboard',		-- package_name
	'left',					-- location
	'/intranet-invoices/dashboard',		-- page_url
	null,					-- view_name
	120,					-- sort_order
	'im_dashboard_revenue_by_dept -diagram_width 600 -diagram_height 500',
	'lang::message::lookup "" intranet-reporting-dashboard.Revenue_by_Department "Revenue by Department"'
);

SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins where plugin_name = 'Revenue by Department'),
	(select group_id from groups where group_name = 'Senior Managers'), 
	'read'
);


