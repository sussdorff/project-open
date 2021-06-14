-- upgrade-4.0.2.0.6-4.0.2.0.7.sql

SELECT acs_log__debug('/packages/intranet-dynfield/sql/postgresql/upgrade/upgrade-4.0.2.0.6-4.0.2.0.7.sql','');


SELECT im_menu__new (
	null,							-- p_menu_id
	'im_menu',						-- object_type
	now(),							-- creation_date
	null,							-- creation_user
	null,							-- creation_ip
	null,							-- context_id
	'intranet-dynfield',					-- package_name
	'dynfield_otype_risk',					-- label
	'Risk',							-- name
	'/intranet-dynfield/object-type?object_type=im_risk',	-- url
	175,							-- sort_order
	(select menu_id from im_menus where label = 'dynfield_otype'),	-- parent_menu_id
	null							-- p_visible_tcl
);

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'dynfield_otype_risk'),
	(select group_id from groups where group_name='Employees'), 
	'read'
);
