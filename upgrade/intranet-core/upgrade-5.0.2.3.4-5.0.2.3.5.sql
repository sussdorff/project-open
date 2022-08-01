-- upgrade-5.0.2.3.4-5.0.2.3.5.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.2.3.4-5.0.2.3.5.sql','');




-- -----------------------------------------------------
-- Menus
-- -----------------------------------------------------

create or replace function inline_1 ()
returns integer as $body$
declare
	v_menu			integer;
	v_user_menu		integer;
	v_employees		integer;
begin
	select group_id into v_employees from groups where group_name = 'Employees';
	select menu_id into v_user_menu from im_menus where label='user';

	v_menu := im_menu__new (
		null,				-- p_menu_id
		'im_menu',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		'intranet-core',		-- package_name
		'biz_card_add',			-- label
		'New User + Company',		-- name
		'/intranet/users/biz-card-add',	-- url
		20,				-- sort_order
		v_user_menu,			-- parent_menu_id
		'[im_permission $user_id "add_users"]'	-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');
	return 0;
end;$body$ language 'plpgsql';
select inline_1 ();
drop function inline_1();



create or replace function inline_1 ()
returns integer as $body$
declare
	v_menu			integer;
	v_user_menu		integer;
	v_employees		integer;
begin
	select group_id into v_employees from groups where group_name = 'Employees';
	select menu_id into v_user_menu from im_menus where label='companies';

	v_menu := im_menu__new (
		null,				-- p_menu_id
		'im_menu',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		'intranet-core',		-- package_name
		'biz_card_add_company',		-- label
		'New Company + Contact',	-- name
		'/intranet/users/biz-card-add',	-- url
		20,				-- sort_order
		v_user_menu,			-- parent_menu_id
		'[im_permission $user_id "add_users"]'	-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');
	return 0;
end;$body$ language 'plpgsql';
select inline_1 ();
drop function inline_1();



create or replace function inline_1 ()
returns integer as $body$
declare
	v_menu			integer;
	v_user_menu		integer;
	v_employees		integer;
begin
	select group_id into v_employees from groups where group_name = 'Employees';
	select menu_id into v_user_menu from im_menus where label='user';

	v_menu := im_menu__new (
		null,				-- p_menu_id
		'im_menu',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		'intranet-core',		-- package_name
		'user_add',			-- label
		'New User',			-- name
		'/intranet/users/new',		-- url
		10,				-- sort_order
		v_user_menu,			-- parent_menu_id
		'[im_permission $user_id "add_users"]'	-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');
	return 0;
end;$body$ language 'plpgsql';
select inline_1 ();
drop function inline_1();







create or replace function inline_1 ()
returns integer as $body$
declare
	v_menu			integer;
	v_admin_menu		integer;
	v_employees		integer;
begin
	select group_id into v_employees from groups where group_name = 'Employees';
	select menu_id into v_admin_menu from im_menus where label='admin';

	v_menu := im_menu__new (
		null,					-- p_menu_id
		'im_menu',				-- object_type
		now(),					-- creation_date
		null,					-- creation_user
		null,					-- creation_ip
		null,					-- context_id
		'intranet-core',			-- package_name
		'object_type_admin',			-- label
		'Object Type Admin',			-- name
		'/intranet/admin/object-type-admin',	-- url
		100,					-- sort_order
		v_admin_menu,				-- parent_menu_id
		null					-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');
	return 0;
end;$body$ language 'plpgsql';
select inline_1 ();
drop function inline_1();




create or replace function inline_1 ()
returns integer as $body$
declare
	v_menu			integer;
	v_project_menu		integer;
	v_employees		integer;
begin
	select group_id into v_employees from groups where group_name = 'Employees';
	select menu_id into v_project_menu from im_menus where label='projects';

	v_menu := im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',		-- package_name
		'projects_admin',		-- label
		'Projects Admin',		-- name
		'/intranet/admin/object-type-admin?object_type=im_project',
		900,				-- sort_order
		(select menu_id from im_menus where label = 'object_type_admin'),	-- parent_menu_id
		null
	);

	v_menu := im_menu__new (
		null,				-- p_menu_id
		'im_menu',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		'intranet-core',		-- package_name
		'project_add',			-- label
		'New Project',			-- name
		'/intranet/projects/new',	-- url
		10,				-- sort_order
		v_project_menu,			-- parent_menu_id
		'[im_permission $user_id "add_projects"]'	-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');
	return 0;
end;$body$ language 'plpgsql';
select inline_1 ();
drop function inline_1();



create or replace function inline_1 ()
returns integer as $body$
declare
	v_menu			integer;
	v_company_menu		integer;
	v_user_menu		integer;
	v_employees		integer;
begin
	select group_id into v_employees from groups where group_name = 'Employees';
	select menu_id into v_company_menu from im_menus where label='companies';
	select menu_id into v_user_menu from im_menus where label='user';

	v_menu := im_menu__new (
		null,				-- p_menu_id
		'im_menu',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		'intranet-core',		-- package_name
		'company_add',			-- label
		'New Company',			-- name
		'/intranet/companies/new',	-- url
		10,				-- sort_order
		v_company_menu,			-- parent_menu_id
		'[im_permission $user_id "add_companies"]'	-- p_visible_tcl
	);
	PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');

	v_menu := im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',		-- package_name
		'companies_admin',		-- label
		'Companies Admin',		-- name
		'/intranet/admin/object-type-admin?object_type=im_company',
		900,				-- sort_order
		(select menu_id from im_menus where label = 'object_type_admin'),		-- parent_menu_id
		null
	);

	v_menu := im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',			-- package_name
		'companies_advanced_filtering',		-- label
		'Advanced Filtering',			-- name
		'/intranet/companies/index?filter_advanced_p=1',
		50,					-- sort_order
		v_company_menu,				-- parent_menu_id
		null
	);

	v_menu := im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',			-- package_name
		'users_advanced_filtering',		-- label
		'Advanced Filtering',			-- name
		'/intranet/users/index?filter_advanced_p=1',
		50,					-- sort_order
		v_user_menu,				-- parent_menu_id
		null
	);

	return 0;
end;$body$ language 'plpgsql';
select inline_1 ();
drop function inline_1();




SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',		-- package_name
		'timesheet_admin',		-- label
		'Timesheet Admin',		-- name
		'/intranet/admin/object-type-admin?object_type=im_hour',
		900,				-- sort_order
		(select menu_id from im_menus where label = 'object_type_admin'),		-- parent_menu_id
		null
);


SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',		-- package_name
		'tickets_admin',		-- label
		'Tickets Admin',		-- name
		'/intranet/admin/object-type-admin?object_type=im_ticket',
		900,				-- sort_order
		(select menu_id from im_menus where label = 'object_type_admin'),		-- parent_menu_id
		null
);



SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',		-- package_name
		'expenses_admin',		-- label
		'Expenses Admin',		-- name
		'/intranet/admin/object-type-admin?object_type=im_expense_item',
		900,				-- sort_order
		(select menu_id from im_menus where label = 'object_type_admin'),		-- parent_menu_id
		null
);



SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',		-- package_name
		'absences_admin',		-- label
		'Absences Admin',		-- name
		'/intranet/admin/object-type-admin?object_type=im_user_absence',	-- url
		900,				-- sort_order
		(select menu_id from im_menus where label = 'object_type_admin'),		-- parent_menu_id
		null
);

SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',		-- package_name
		'helpdesk_admin',		-- label
		'Helpdesk Admin',		-- name
		'/intranet/admin/object-type-admin?object_type=im_ticket',
		900,				-- sort_order
		(select menu_id from im_menus where label = 'object_type_admin'),		-- parent_menu_id
		null
);

SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',		-- package_name
		'finance_admin',		-- label
		'Finance Admin',		-- name
		'/intranet/admin/object-type-admin?object_type=im_cost',
		900,				-- sort_order
		(select menu_id from im_menus where label = 'object_type_admin'),		-- parent_menu_id
		null
);

SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',		-- package_name
		'conf_items_admin',		-- label
		'Conf Items Admin',		-- name
		'/intranet/admin/object-type-admin?object_type=im_conf_item',
		900,				-- sort_order
		(select menu_id from im_menus where label = 'object_type_admin'),		-- parent_menu_id
		null
);


SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',		-- package_name
		'crm_admin',			-- label
		'CRM Admin',			-- name
		'/intranet/admin/object-type-admin?object_type=im_opportunity',
		900,				-- sort_order
		(select menu_id from im_menus where label = 'object_type_admin'),		-- parent_menu_id
		null
);




SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',		-- package_name
		'users_admin',			-- label
		'Users Admin',			-- name
		'/intranet/admin/object-type-admin?object_type=person',
		900,				-- sort_order
		(select menu_id from im_menus where label = 'object_type_admin'),		-- parent_menu_id
		null
);


SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',		-- package_name
		'users_dashboard',		-- label
		'Users Dashboard',		-- name
		'/intranet/users/dashboard',
		20,				-- sort_order
		(select menu_id from im_menus where label = 'user'),		-- parent_menu_id
		null
);
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'users_dashboard'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);



SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',		-- package_name
		'projects_dashboard',		-- label
		'Projects Dashboard',		-- name
		'/intranet/projects/dashboard',
		30,				-- sort_order
		(select menu_id from im_menus where label = 'projects'),		-- parent_menu_id
		null
);
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'projects_dashboard'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);


SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',		-- package_name
		'companies_dashboard',		-- label
		'Companies Dashboard',		-- name
		'/intranet/companies/dashboard',
		30,				-- sort_order
		(select menu_id from im_menus where label = 'companies'),		-- parent_menu_id
		null
);
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'companies_dashboard'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);


SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',		-- package_name
		'portfolio_dashboard',		-- label
		'Portfolio Dashboard',		-- name
		'/intranet-portfolio-management/dashboard',
		30,				-- sort_order
		(select menu_id from im_menus where label = 'portfolio'),		-- parent_menu_id
		null
);
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'portfolio_dashboard'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);


SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-portfolio-planner',		-- package_name
		'portfolio_planner2',		-- label
		'Portfolio Planner',		-- name
		'/intranet-portfolio-planner/index',
		30,				-- sort_order
		(select menu_id from im_menus where label = 'portfolio'),		-- parent_menu_id
		null
);
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'portfolio_dashboard'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);


SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',		-- package_name
		'timesheet_hours_list',		-- label
		'Timesheet List',		-- name
		'/intranet-timesheet2/hours/list',
		10,				-- sort_order
		(select menu_id from im_menus where label = 'timesheet2_timesheet'),		-- parent_menu_id
		null
);
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'timesheet_hours_list'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);


SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',		-- package_name
		'timesheet_hours_dashboard',	-- label
		'Timesheet Dashboard',		-- name
		'/intranet-timesheet2/hours/dashboard',
		20,				-- sort_order
		(select menu_id from im_menus where label = 'timesheet2_timesheet'),		-- parent_menu_id
		null
);
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'timesheet_hours_dashboard'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);


SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',		-- package_name
		'programs_list',		-- label
		'Programs List',			-- name
		'/intranet-portfolio-management/programs-list',
		20,				-- sort_order
		(select menu_id from im_menus where label = 'portfolio'),		-- parent_menu_id
		null
);
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'programs_list'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);



SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-timesheet2',		-- package_name
		'timesheet2_absences_list',		-- label
		'Absences List',			-- name
		'/intranet-timesheet2/absences/index',
		20,				-- sort_order
		(select menu_id from im_menus where label = 'timesheet2_absences'),		-- parent_menu_id
		null
);
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'timesheet2_absences_list'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);


SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-timesheet2',		-- package_name
		'timesheet2_absences_dashboard',		-- label
		'Absences Dashboard',			-- name
		'/intranet-timesheet2/absences/dashboard',
		20,				-- sort_order
		(select menu_id from im_menus where label = 'timesheet2_absences'),		-- parent_menu_id
		null
);
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'timesheet2_absences_dashboard'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);

SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-timesheet2',		-- package_name
		'timesheet2_hours_new',		-- label
		'New Hours',			-- name
		'/intranet-timesheet2/hours/new?show_week_p=0',
		10,				-- sort_order
		(select menu_id from im_menus where label = 'timesheet2_timesheet'),		-- parent_menu_id
		null
);
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'timesheet2_hours_new'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);




SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-invoices',		-- package_name
		'invoices_list',		-- label
		'Invoices List',		-- name
		'/intranet-invoices/list?cost_type_id=3700',
		10,				-- sort_order
		(select menu_id from im_menus where label = 'finance'),		-- parent_menu_id
		null
);
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'invoices_list'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);




SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-confdb',		-- package_name
		'conf_items_list',		-- label
		'Conf Items List',		-- name
		'/intranet-confdb/index',
		10,				-- sort_order
		(select menu_id from im_menus where label = 'conf_items'),		-- parent_menu_id
		null
);
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'conf_items_list'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);

SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-confdb',		-- package_name
		'conf_items_dashboard',		-- label
		'Conf Items Dashboard',		-- name
		'/intranet-confdb/dashboard',
		20,				-- sort_order
		(select menu_id from im_menus where label = 'conf_items'),		-- parent_menu_id
		null
);
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'conf_items_dashboard'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);


SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-expenses',		-- package_name
		'expenses_item_new',		-- label
		'New Expense Item',		-- name
		'/intranet-expenses/new',
		10,				-- sort_order
		(select menu_id from im_menus where label = 'expenses'),		-- parent_menu_id
		null
);
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'expenses_item_new'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);


SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-expenses',		-- package_name
		'expenses_item_multiple_new',		-- label
		'New Multiple Expense Item',		-- name
		'/intranet-expenses/new-multiple',
		10,				-- sort_order
		(select menu_id from im_menus where label = 'expenses'),		-- parent_menu_id
		null
);
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'expenses_item_multiple_new'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);





SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',			-- package_name
		'master_data',				-- label
		'Master Data',				-- name
		'/intranet/master-data',
		9800,				-- sort_order
		(select menu_id from im_menus where label = 'main'),		-- parent_menu_id
		null
);
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'master_data'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);




SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',			-- package_name
		'offices',				-- label
		'Offices',				-- name
		'/intranet/offices/index',
		250,					-- sort_order
		(select menu_id from im_menus where label = 'master_data'),		-- parent_menu_id
		null
);
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'offices'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);


SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',			-- package_name
		'office_add',				-- label
		'New Office',				-- name
		'/intranet/offices/new',
		10,					-- sort_order
		(select menu_id from im_menus where label = 'offices'),		-- parent_menu_id
		null
);
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'office_add'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);


SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',			-- package_name
		'offices_list',				-- label
		'Offices List',				-- name
		'/intranet/offices/index',
		100,					-- sort_order
		(select menu_id from im_menus where label = 'offices'),		-- parent_menu_id
		null
);
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'offices_list'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);




-- Create menu entry for main user view page,
-- similar to projects
--
select im_menu__new (
	null, 'im_menu', now(), null, null, null,
	'intranet-core',		-- package_name
	'user_page',			-- label
	'User',				-- name
	'/intranet/users/view',		-- url
	30,				-- sort_order
	(select menu_id from im_menus where label = 'top'),
	null				-- p_visible_tcl
);

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'user_page'),
	(select group_id from groups where group_name = 'Employees'),
	'read'
);



select im_menu__new (
	null, 'im_menu', now(), null, null, null,
	'intranet-core',		-- package_name
	'user_summary',			-- label
	'Summary',			-- name
	'/intranet/users/view',		-- url
	10,				-- sort_order
	(select menu_id from im_menus where label = 'user_page'),
	null				-- p_visible_tcl
);

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'user_summary'),
	(select group_id from groups where group_name = 'Employees'),
	'read'
);




select im_menu__new (
	null,				-- p_menu_id
	'im_menu',			-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id
	'intranet-core',		-- package_name
	'admin_request_monitor',		-- label
	'Request Monitor',		-- name
	'/request-monitor/index',	-- url
	2200,				-- sort_order
	(select menu_id from im_menus where label = 'admin'),
	'[im_package_exists_p "xotcl-request-monitor"]'				-- p_visible_tcl
);





update im_menus
set parent_menu_id = (select menu_id from im_menus where label = 'object_type_admin')
where label in (
	'users_admin',
	'crm_admin',
	'projects_admin',
	'companies_admin',
	'timesheet_admin',
	'absences_admin',
	'tickets_admin',
	'finance_admin',
	'conf_items_admin',
	'expenses_admin'
);



-- Move dashboard to intranet-invoices
update im_component_plugins set page_url = '/intranet-invoices/dashboard' where page_url in ('/intranet-cost/index', '/intranet-cost/dashboard');

-- Home
update im_menus set sort_order = 100					where label = 'home';
update im_menus set sort_order = 10, enabled_p = 'f'			where label = 'home_summary';

-- Projects
update im_menus set sort_order = 400					where label = 'projects';
update im_menus set sort_order = 10					where label = 'project_add';
update im_menus set sort_order = 20, name = 'Projects List'		where label = 'projects_filter_advanced';
update im_menus set sort_order = 30, name = 'Projects List Profit & Loss'	where label = 'projects_profit_loss';
update im_menus set sort_order = 35, enabled_p = 'f'			where label = 'project_programs';
update im_menus set sort_order = 40, name = 'Milestones List'		where label = 'milestones';
update im_menus set parent_menu_id = (select menu_id from im_menus where label = 'projects') where label = 'milestones';

update im_menus set sort_order = 50, name = 'Programs List'		where label = 'programs_list';
update im_menus set parent_menu_id = (select menu_id from im_menus where label = 'projects') where label = 'programs_list';
update im_menus set url = '/intranet-portfolio-management/programs-list' where label = 'programs_list';

update im_menus set sort_order = 60, name = 'Projects Dashboard'	where label = 'projects_dashboard';
update im_menus set sort_order = 200					where label = 'traffic_light_report';
update im_menus set sort_order = 500					where label = 'openoffice_project_phases_risks_pptx';
update im_menus set sort_order = 550					where label = 'openoffice_project_phases_risks_odp';
update im_menus set enabled_p = 'f'					where label = 'projects_open';
update im_menus set enabled_p = 'f'					where label = 'projects_potential';
update im_menus set enabled_p = 'f'					where label = 'projects_closed';


-- Portfolio
update im_menus set sort_order = 500					where label = 'portfolio';
update im_menus set sort_order = 20					where label = 'portfolio_planner';
update im_menus set sort_order = 30, enabled_p = 'f'			where label = 'portfolio_dashboard';
update im_menus set sort_order = 40					where label = 'strategic_vs_roi';
update im_menus set sort_order = 50					where label = 'risk_vs_roi';

-- Resource Management
update im_menus set sort_order = 600					where label = 'resource_management';
update im_menus set sort_order = 0, enabled_p = 'f'			where label = 'resource_management_home';
update im_menus set sort_order = 100, name = 'Resource Assignments'	where label = 'projects_resources_assignation_percentage';
update im_menus set sort_order = 400					where label = 'department_planner';
update im_menus set sort_order = 450, enabled_p = 'f'			where label = 'projects_admin_gantt_resources';
update im_menus set parent_menu_id = (select menu_id from im_menus where label = 'resource_management') where label = 'projects_admin_gantt_resources';
update im_menus set sort_order = 600					where label = 'capacity-planning';
update im_menus set parent_menu_id = (select menu_id from im_menus where label = 'resource_management') where label = 'capacity-planning';

-- Tickets
update im_menus set sort_order = 700					where label = 'helpdesk';
update im_menus set sort_order = 10					where label = 'ticket_add';
update im_menus set sort_order = 100, name = 'Tickets List'		where label = 'helpdesk_summary';
update im_menus set sort_order = 110, name = 'Tickets Dashboard'	where label = 'helpdesk_dashboard';

-- Timesheet
update im_menus set sort_order = 1000					where label = 'timesheet2_timesheet';
update im_menus set sort_order = 10, name = 'New Hours'			where label = 'timesheet_hours_new';
update im_menus set sort_order = 100, name = 'Timesheet List'		where label = 'timesheet_hours_list';
update im_menus set url = '/intranet-reporting/timesheet-customer-project?preconf=my_hours' where label = 'timesheet_hours_list';
update im_menus set sort_order = 110, name = 'Timesheet Dashboard'	where label = 'timesheet_hours_dashboard';
update im_menus set sort_order = 900, name = 'Admin Timesheet', visible_tcl = '0' where label = 'timesheet_hours_new_admin';

-- Absences
update im_menus set sort_order = 1200					where label = 'timesheet2_absences';
update im_menus set sort_order = 30					where label = 'timesheet2_absences_vacation';
update im_menus set sort_order = 40					where label = 'timesheet2_absences_personal';
update im_menus set sort_order = 50					where label = 'timesheet2_absences_sick';
update im_menus set sort_order = 60					where label = 'timesheet2_absences_travel';
update im_menus set sort_order = 70					where label = 'timesheet2_absences_bankholiday';
update im_menus set sort_order = 100					where label = 'timesheet2_absences_list';
update im_menus set sort_order = 110					where label = 'timesheet2_absences_dashboard';

-- Finance
update im_menus set sort_order = 1600					where label = 'finance';
update im_menus set sort_order = 10, name = 'Finance List'		where label = 'invoices_list';
update im_menus set sort_order = 20, name = 'Finance Dashboard', url = '/intranet-invoices/dashboard' where label = 'costs_home';
update im_menus set sort_order = 30, name = 'Finance List Complete'	where label = 'costs';
update im_menus set sort_order = 80					where label = 'invoices_customers';
update im_menus set sort_order = 90					where label = 'invoices_providers';
update im_menus set sort_order = 100					where label = 'finance_exchange_rates';
update im_menus set parent_menu_id = (select menu_id from im_menus where label = 'finance_admin') where label = 'finance_exchange_rates';
update im_menus set sort_order = 990					where label = 'invoices_providers_csv';


-- Expenses
update im_menus set sort_order = 1800					where label = 'expenses';
update im_menus set sort_order = 10					where label = 'expenses_item_new';
update im_menus set sort_order = 20					where label = 'expenses_item_multiple_new';

update im_menus set sort_order = 100, name = 'Expenses List', enabled_p = 't' where label = 'finance_expenses';
update im_menus set parent_menu_id = (select menu_id from im_menus where label = 'expenses') where label = 'finance_expenses';
update im_menus set visible_tcl = '0'  	     	     	  	   	where label = 'finance_expenses';

update im_menus set sort_order = 110, name = 'Expenses List', enabled_p = 't' where label = 'expenses_list';
update im_menus set parent_menu_id = (select menu_id from im_menus where label = 'expenses') where label = 'expenses_list';
update im_menus set url = '/intranet-expenses/index' 	  	   	where label = 'expenses_list';


update im_menus set sort_order = 110, name = 'Expenses Dashboard', enabled_p = 'f' where label = 'expenses_dashboard';
update im_menus set sort_order = 500, visible_tcl = '0'			where label = 'expense_bundles_payment';


-- Ideas
update im_menus set sort_order = 2000					where label = 'ideas';
update im_menus set sort_order = 10					where label = 'ideas_top';
update im_menus set sort_order = 30					where label = 'ideas_hot';
update im_menus set sort_order = 40					where label = 'ideas_new';
update im_menus set sort_order = 80					where label = 'ideas_accepted';
update im_menus set sort_order = 90					where label = 'ideas_done';

-- Workflow
update im_menus set sort_order = 2500, enabled_p = 'f'			where label = 'workflow';

-- CRM
update im_menus set sort_order = 3000					where label = 'crm';
update im_menus set sort_order = 10, name = 'New Opportunity'		where label = 'add_opportunity';
update im_menus set sort_order = 100, name = 'Opportunities List'	where label = 'crm_opportunities';
update im_menus set sort_order = 110, name = 'Opportunities Dashboard'	where label = 'crm_home';

-- Reporting
update im_menus set sort_order = 6000					where label = 'reporting';
update im_menus set sort_order = 900, enabled_p = 'f'			where label = 'dashboard';
update im_menus set sort_order = 890, enabled_p = 't'			where label = 'indicators';

-- XoWiki
update im_menus set sort_order = 9000					where label = 'xowiki';

-- Master Data
update im_menus set sort_order = 9800					where label = 'master_data';
update im_menus set url = '/intranet/master-data'			where label = 'master_data';


update im_menus set sort_order = 1000, parent_menu_id = (select menu_id from im_menus where label = 'master_data') where label = 'admin_cost_centers';
update im_menus set sort_order = 1100, parent_menu_id = (select menu_id from im_menus where label = 'master_data') where label = 'material';
update im_menus set sort_order = 1300, parent_menu_id = (select menu_id from im_menus where label = 'master_data') where label = 'admin_exchange_rates';
update im_menus set sort_order = 2000, parent_menu_id = (select menu_id from im_menus where label = 'master_data') where label = 'admin_survsimp';

-- Master Data - Companies
update im_menus set sort_order = 200					where label = 'companies';
update im_menus set parent_menu_id = (select menu_id from im_menus where label = 'master_data') where label = 'companies';
update im_menus set sort_order = 10					where label = 'company_add';
update im_menus set sort_order = 20					where label = 'biz_card_add_company';
update im_menus set sort_order = 100, name = 'Companies List'		where label = 'companies_advanced_filtering';
update im_menus set sort_order = 200, name = 'Companies Dashboard'	where label = 'companies_dashboard';

update im_menus set sort_order = 100 where label = 'customers_active';
update im_menus set sort_order = 110 where label = 'customers_potential';
update im_menus set sort_order = 120 where label = 'customers_inactive';
update im_menus set enabled_p = 'f'					where label = 'customers_active';
update im_menus set enabled_p = 'f'					where label = 'customers_inactive';
update im_menus set enabled_p = 'f'					where label = 'customers_potential';

-- Master Data - Offices
update im_menus set sort_order = 250					where label = 'offices';
update im_menus set parent_menu_id = (select menu_id from im_menus where label = 'master_data') where label = 'offices';
update im_menus set sort_order = 10					where label = 'office_add';
update im_menus set sort_order = 100					where label = 'offices_list';

-- Master Data - Users
update im_menus set sort_order = 100					where label = 'user';
update im_menus set parent_menu_id = (select menu_id from im_menus where label = 'master_data') where label = 'user';
update im_menus set sort_order = 10					where label = 'user_add';
update im_menus set sort_order = 20					where label = 'biz_card_add';
update im_menus set sort_order = 100, name = 'Users List'		where label = 'users_advanced_filtering';
update im_menus set sort_order = 110, name = 'Users Dashboard'		where label = 'users_dashboard';

-- Master Data - Conf Items
update im_menus set sort_order = 300					where label = 'conf_items';
update im_menus set parent_menu_id = (select menu_id from im_menus where label = 'master_data') where label = 'conf_items';
update im_menus set sort_order = 10, name = 'New Conf Item'		where label = 'conf_item_add';
update im_menus set sort_order = 100					where label = 'conf_items_list';
update im_menus set sort_order = 110					where label = 'conf_items_dashboard';
update im_menus set sort_order = 300					where label = 'conf_item_csv_export';
update im_menus set sort_order = 310					where label = 'conf_item_csv_import';





-- Admin
update im_menus set sort_order = 9900					where label = 'admin';
update im_menus set sort_order = 100   		      			where label = 'admin_home';
update im_menus set sort_order = 200					where label = 'openacs_api_doc';
update im_menus set sort_order = 300					where label = 'admin_backup';
update im_menus set sort_order = 400					where label = 'admin_flush';
update im_menus set sort_order = 500					where label = 'openacs_cache';
update im_menus set sort_order = 600					where label = 'admin_categories';
update im_menus set sort_order = 700					where label = 'admin_consistency_check';
update im_menus set sort_order = 900					where label = 'openacs_developer';
update im_menus set sort_order = 1000					where label = 'dynfield_admin';
update im_menus set sort_order = 1100					where label = 'admin_dynview';
update im_menus set sort_order = 1400					where label = 'openacs_shell';
update im_menus set sort_order = 1500					where label = 'admin_templates';
update im_menus set parent_menu_id = (select menu_id from im_menus where label = 'admin') where label = 'admin_templates';
update im_menus set sort_order = 1600					where label = 'openacs_auth';
update im_menus set sort_order = 1700					where label = 'openacs_l10n';
update im_menus set sort_order = 1800					where label = 'admin_menus';
update im_menus set sort_order = 1900					where label = 'object_type_admin';
update im_menus set sort_order = 2000					where label = 'admin_packages';
update im_menus set sort_order = 2100					where label = 'admin_parameters';
update im_menus set sort_order = 2200					where label = 'admin_components';
update im_menus set sort_order = 2300					where label = 'admin_profiles';
update im_menus set sort_order = 2400					where label = 'admin_request_monitor';
update im_menus set sort_order = 2401, menu_gif_small = 'arrow_right'	where label = 'openacs_request_monitor';
update im_menus set sort_order = 2500					where label = 'admin_rest';
update im_menus set sort_order = 2600					where label = 'openacs_restart_server';
update im_menus set sort_order = 2700					where label = 'rules';
update im_menus set sort_order = 2800					where label = 'openacs_ds';
update im_menus set sort_order = 2900					where label = 'selectors_admin';
update im_menus set sort_order = 3000					where label = 'openacs_sitemap';
update im_menus set sort_order = 3100					where label = 'software_updates';
update im_menus set sort_order = 3200					where label = 'admin_sysconfig';
update im_menus set sort_order = 3300					where label = 'admin_user_exits';
update im_menus set sort_order = 3400					where label = 'admin_usermatrix';
update im_menus set sort_order = 3500					where label = 'admin_workflow';

