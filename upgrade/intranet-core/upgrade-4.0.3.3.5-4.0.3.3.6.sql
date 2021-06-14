-- upgrade-4.0.3.3.5-4.0.3.3.6.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.3.5-4.0.3.3.6.sql','');



update	im_menus set 
	parent_menu_id = (select menu_id from im_menus where label = 'resource_management'),
	url = '/intranet-resource-management/resources-planning-liwo'
where	label = 'projects_resource_planning';




