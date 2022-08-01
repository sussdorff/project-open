-- 5.0.2.3.4-5.0.2.3.5.sql

SELECT acs_log__debug('/packages/intranet-reporting-finance/sql/postgresql/upgrade/upgrade-5.0.2.3.4-5.0.2.3.5.sql','');



select im_menu__delete(
       (select menu_id from im_menus where label = 'reporting-finance-expenses-cube' and package_name = 'intranet-reporting-finance')
);






SELECT im_menu__new (
	null, 'im_menu', now(), null, null, null,
	'intranet-reporting-finance',				-- package_name
	'reporting-finance-cash-flow',			-- label
	'Finance - Cash Flow',				-- name
	'/intranet-reporting-finance/finance-cash-flow', -- url
	50,						-- sort_order
	(select menu_id from im_menus where label='reporting-finance'),
	null						-- p_visible_tcl
);

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'reporting-finance-cash-flow'),
	(select group_id from groups where group_name = 'Senior Managers'),
	'read'
);

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'reporting-finance-cash-flow'),
	(select group_id from groups where group_name = 'Accounting'),
	'read'
);



