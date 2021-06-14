-- upgrade-5.0.1.0.0-5.0.1.0.1.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.1.0.0-5.0.1.0.1.sql','');


alter table acs_logs alter column log_key type text;


drop view acs_events_dates;
drop view acs_events_activities;
alter table acs_events alter column name type text;
alter table acs_activities alter column name type text;


-- This view makes the temporal information easier to access
create view acs_events_dates as
select e.*, 
       start_date, 
       end_date
from   acs_events e,
       timespans s,
       time_intervals t
where  e.timespan_id = s.timespan_id
and    s.interval_id = t.interval_id;

-- Postgres is very strict: we must specify 'comment on view', if not a real table
comment on view acs_events_dates is '
    This view produces a separate row for each time interval in the timespan
    associated with an event.
';



-- This view provides an alternative to the get_name and get_description
-- functions
create view acs_events_activities as
select event_id, 
       coalesce(e.name, a.name) as name,
       coalesce(e.description, a.description) as description,
       coalesce(e.html_p, a.html_p) as html_p,
       coalesce(e.status_summary, a.status_summary) as status_summary,
       e.activity_id,
       timespan_id,
       recurrence_id
from   acs_events e,
       acs_activities a
where  e.activity_id = a.activity_id;

comment on view acs_events_activities is '
    This view pulls the event name and description from the underlying
    activity if necessary.
';








-- Fix foreign key constraint for projects.
-- No idea how this might have got lost...
create or replace function inline_0()
returns integer as $body$
DECLARE
	v_count		integer;
BEGIN
	select	count(*) into v_count from pg_constraint
	where	conname in ('im_projects_company_fk', 'im_project_companies_fk', 'im_project_company_fk', 'im_projects_companies_fk');
	IF v_count > 0 THEN return 1; END IF;

	-- Fix references to missing companies
	update im_projects
	set company_id = (select company_id from im_companies where company_path = 'internal')
	where company_id not in (select company_id from im_companies);
	alter table im_projects add constraint im_projects_companies_fk foreign key (company_id) references im_companies;

	return 0;
END;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();




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



-- SELECT im_menu__new (
-- 		null, 'im_menu', now(), null, null, null,
-- 		'intranet-expenses',		-- package_name
-- 		'expenses_dashboard',		-- label
-- 		'Expenses Dashboard',		-- name
-- 		'/intranet-expenses/dashboard',
-- 		20,				-- sort_order
-- 		(select menu_id from im_menus where label = 'expenses'),		-- parent_menu_id
-- 		null
-- );
-- SELECT acs_permission__grant_permission(
-- 	(select menu_id from im_menus where label = 'expenses_dashboard'),
-- 	(select group_id from groups where group_name = 'Employees'), 
-- 	'read'
-- );



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











update im_dynfield_widgets
set pretty_name = 'Translation Languages',
	pretty_plural = 'Translation Languages'
where pretty_name = '#intranet-translation.Trans_Langs#';


-- Add a new field holding the source project_id for projects being cloned.
-- Not very pretty, but there doesn't seem to be any good alternative around...
--
-- create or replace function inline_0 ()
-- returns integer as $$
-- declare
-- 	v_count			integer;
-- BEGIN
-- 	select	count(*) into v_count
-- 	from	user_tab_columns where lower(table_name) = 'im_projects' and lower(column_name) = 'clone_project_source_id';
-- 	IF v_count > 0 THEN return 1; END IF;
-- 
--	alter table im_projects add column clone_project_source_id integer;
-- 
--	return 0;
-- end;$$ language 'plpgsql';
-- select inline_0 ();
-- drop function inline_0 ();




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


update im_menus set sort_order = 100 where label = 'customers_active';
update im_menus set sort_order = 110 where label = 'customers_potential';
update im_menus set sort_order = 120 where label = 'customers_inactive';

update im_menus
set parent_menu_id = (select menu_id from im_menus where label = 'finance_admin')
where label = 'finance_exchange_rates';

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


-- Companies
update im_menus set sort_order = 200					where label = 'companies';
update im_menus set parent_menu_id = (select menu_id from im_menus where label = 'master_data') where label = 'companies';
update im_menus set sort_order = 10					where label = 'company_add';
update im_menus set sort_order = 20					where label = 'biz_card_add_company';
update im_menus set sort_order = 100, name = 'Companies List'		where label = 'companies_advanced_filtering';
update im_menus set sort_order = 200, name = 'Companies Dashboard'	where label = 'companies_dashboard';
update im_menus set enabled_p = 'f'					where label = 'customers_active';
update im_menus set enabled_p = 'f'					where label = 'customers_inactive';
update im_menus set enabled_p = 'f'					where label = 'customers_potential';


-- Offices!!!
update im_menus set sort_order = 250					where label = 'offices';
update im_menus set parent_menu_id = (select menu_id from im_menus where label = 'master_data') where label = 'offices';
update im_menus set sort_order = 10					where label = 'office_add';
update im_menus set sort_order = 100					where label = 'offices_list';




-- Users
update im_menus set sort_order = 100					where label = 'user';
update im_menus set parent_menu_id = (select menu_id from im_menus where label = 'master_data') where label = 'user';
update im_menus set sort_order = 10					where label = 'user_add';
update im_menus set sort_order = 20					where label = 'biz_card_add';
update im_menus set sort_order = 100, name = 'Users List'		where label = 'users_advanced_filtering';
update im_menus set sort_order = 110, name = 'Users Dashboard'		where label = 'users_dashboard';


-- Conf Items
update im_menus set sort_order = 300					where label = 'conf_items';
update im_menus set parent_menu_id = (select menu_id from im_menus where label = 'master_data') where label = 'conf_items';
update im_menus set sort_order = 10, name = 'New Conf Item'		where label = 'conf_item_add';
update im_menus set sort_order = 100					where label = 'conf_items_list';
update im_menus set sort_order = 110					where label = 'conf_items_dashboard';
update im_menus set sort_order = 300					where label = 'conf_item_csv_export';
update im_menus set sort_order = 310					where label = 'conf_item_csv_import';


-- Reporting
update im_menus set sort_order = 6000					where label = 'reporting';
update im_menus set sort_order = 900, enabled_p = 'f'			where label = 'dashboard';
update im_menus set sort_order = 890, enabled_p = 't'			where label = 'indicators';


-- XoWiki
update im_menus set sort_order = 9000					where label = 'xowiki';

-- Admin
update im_menus set sort_order = 9900					where label = 'admin';
update im_menus set sort_order = 1450, parent_menu_id = (select menu_id from im_menus where label = 'admin') where label = 'admin_templates';



update im_menus set sort_order = 1000, parent_menu_id = (select menu_id from im_menus where label = 'master_data') where label = 'admin_cost_centers';
update im_menus set sort_order = 1100, parent_menu_id = (select menu_id from im_menus where label = 'master_data') where label = 'material';
update im_menus set sort_order = 1300, parent_menu_id = (select menu_id from im_menus where label = 'master_data') where label = 'admin_exchange_rates';
update im_menus set sort_order = 2000, parent_menu_id = (select menu_id from im_menus where label = 'master_data') where label = 'admin_survsimp';





------------------------------------------------------
-- Increase the size of the old Oracle table fields
--

drop view users_active;

alter table users_contact alter column home_phone type text;
alter table users_contact alter column work_phone type text;
alter table users_contact alter column cell_phone type text;
alter table users_contact alter column pager type text;
alter table users_contact alter column fax type text;
alter table users_contact alter column aim_screen_name type text;
alter table users_contact alter column msn_screen_name type text;
alter table users_contact alter column icq_number type text;
alter table users_contact alter column ha_line1 type text;
alter table users_contact alter column ha_line2 type text;
alter table users_contact alter column ha_city type text;
alter table users_contact alter column ha_state type text;
alter table users_contact alter column ha_postal_code type text;
alter table users_contact alter column wa_line1 type text;
alter table users_contact alter column wa_line2 type text;
alter table users_contact alter column wa_city type text;
alter table users_contact alter column wa_state type text;
alter table users_contact alter column wa_postal_code type text;
alter table users_contact alter column note type text;

create or replace view users_active as 
select
	u.user_id, u.username, u.screen_name, u.last_visit, u.second_to_last_visit, u.n_sessions, u.first_names, u.last_name,
	c.home_phone, c.priv_home_phone, c.work_phone, c.priv_work_phone, c.cell_phone, c.priv_cell_phone, c.pager, c.priv_pager,
	c.fax, c.priv_fax, c.aim_screen_name, c.priv_aim_screen_name, c.msn_screen_name, c.priv_msn_screen_name, c.icq_number,
	c.priv_icq_number, c.m_address, c.ha_line1, c.ha_line2, c.ha_city, c.ha_state, c.ha_postal_code, c.ha_country_code,
	c.priv_ha, c.wa_line1, c.wa_line2, c.wa_city, c.wa_state, c.wa_postal_code, c.wa_country_code, c.priv_wa,
	c.note, c.current_information
from	registered_users u left outer join users_contact c on u.user_id = c.user_id;






-- Move portlets to various dashboard pages

update im_component_plugins set page_url = '/intranet/projects/dashboard' where page_url = '/intranet/projects/index';





SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,	-- system params
	'Top Customers',					-- plugin_name
	'intranet-reporting-dashboard',				-- package_name
	'left',							-- location
	'/intranet/index',					-- page_url
	null,							-- view_name
	100,							-- sort_order
	'im_dashboard_top_customers -diagram_width 580 -diagram_height 300 -diagram_max_customers 8',
	'lang::message::lookup "" intranet-reporting-dashboard.Top_Customers "Top Customers"'
);
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins where plugin_name = 'Top Customers' and page_url = '/intranet/index'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);


SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,	-- system params
	'Top Customers (Company Dashboard)',			-- plugin_name
	'intranet-reporting-dashboard',				-- package_name
	'left',							-- location
	'/intranet/companies/dashboard',			-- page_url
	null,							-- view_name
	10,							-- sort_order
	'im_dashboard_top_customers -diagram_width 580 -diagram_height 300 -diagram_max_customers 8',
	'lang::message::lookup "" intranet-reporting-dashboard.Top_Customers "Top Customers"'
);
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins 
	 where  plugin_name = 'Top Customers (Company Dashboard)' and 
	        page_url = '/intranet/companies/dashboard'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);

SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,	-- system params
	'Top Customers (Finance Dashboard)',			-- plugin_name
	'intranet-reporting-dashboard',				-- package_name
	'left',							-- location
	'/intranet-invoices/dashboard',				-- page_url
	null,							-- view_name
	10,							-- sort_order
	'im_dashboard_top_customers -diagram_width 580 -diagram_height 300 -diagram_max_customers 8',
	'lang::message::lookup "" intranet-reporting-dashboard.Top_Customers "Top Customers"'
);
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins 
	 where plugin_name = 'Top Customers (Finance Dashboard)' and 
		page_url = '/intranet-invoices/dashboard'
	),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);






--------------------------------------------------------
-- Timeline indicators for the various dashboards
--------------------------------------------------------


SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,	-- system params
	'Project Indicators Timeline',				-- plugin_name
	'intranet-reporting-indicators',			-- package_name
	'right',						-- location
	'/intranet/projects/dashboard',				-- page_url
	null,							-- view_name
	10,							-- sort_order
	'im_indicator_timeline_component -indicator_section_id [im_indicator_section_pm]',
	'lang::message::lookup "" intranet-reporting-dashboard.Indicators_Timeline "Indicators Timeline"'
);
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins 
	 where plugin_name = 'Project Indicators Timeline' and 
		page_url = '/intranet/projects/dashboard'
	),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);

SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,	-- system params
	'Customer Indicators Timeline',				-- plugin_name
	'intranet-reporting-indicators',			-- package_name
	'right',						-- location
	'/intranet/companies/dashboard',				-- page_url
	null,							-- view_name
	10,							-- sort_order
	'im_indicator_timeline_component -indicator_section_id [im_indicator_section_customers]',
	'lang::message::lookup "" intranet-reporting-dashboard.Indicators_Timeline "Indicators Timeline"'
);
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins 
	 where plugin_name = 'Customer Indicators Timeline' and 
		page_url = '/intranet/companies/dashboard'
	),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);



SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,	-- system params
	'Ticket Indicators Timeline',				-- plugin_name
	'intranet-reporting-indicators',			-- package_name
	'right',						-- location
	'/intranet-helpdesk/dashboard',				-- page_url
	null,							-- view_name
	10,							-- sort_order
	'im_indicator_timeline_component -indicator_section_id [im_indicator_section_helpdesk]',
	'lang::message::lookup "" intranet-reporting-dashboard.Indicators_Timeline "Indicators Timeline"'
);
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins 
	 where plugin_name = 'Ticket Indicators Timeline' and 
		page_url = '/intranet-helpdesk/dashboard'
	),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);


SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,	-- system params
	'Timesheet Indicators Timeline',				-- plugin_name
	'intranet-reporting-indicators',			-- package_name
	'right',						-- location
	'/intranet-timesheet2/hours/dashboard',				-- page_url
	null,							-- view_name
	10,							-- sort_order
	'im_indicator_timeline_component -indicator_section_id [im_indicator_section_timesheet]',
	'lang::message::lookup "" intranet-reporting-dashboard.Indicators_Timeline "Indicators Timeline"'
);
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins 
	 where plugin_name = 'Timesheet Indicators Timeline' and 
		page_url = '/intranet-timesheet2/hours/dashboard'
	),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);


SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,	-- system params
	'Absences Indicators Timeline',				-- plugin_name
	'intranet-reporting-indicators',			-- package_name
	'right',						-- location
	'/intranet-timesheet2/absences/dashboard',				-- page_url
	null,							-- view_name
	10,							-- sort_order
	'im_indicator_timeline_component -indicator_section_id [im_indicator_section_absences]',
	'lang::message::lookup "" intranet-reporting-dashboard.Indicators_Timeline "Indicators Timeline"'
);
select im_category_new (15260, 'Absences', 'Intranet Indicator Section');
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins 
	 where plugin_name = 'Absences Indicators Timeline' and 
		page_url = '/intranet-timesheet2/absences/dashboard'
	),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);






SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,	-- system params
	'Users Indicators Timeline',				-- plugin_name
	'intranet-reporting-indicators',			-- package_name
	'right',						-- location
	'/intranet/users/dashboard',				-- page_url
	null,							-- view_name
	10,							-- sort_order
	'im_indicator_timeline_component -indicator_section_id [im_indicator_section_hr]',
	'lang::message::lookup "" intranet-reporting-dashboard.Indicators_Timeline "Indicators Timeline"'
);
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins 
	 where plugin_name = 'Users Indicators Timeline' and 
		page_url = '/intranet/users/dashboard'
	),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);



SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,	-- system params
	'Conf Items Indicators Timeline',				-- plugin_name
	'intranet-reporting-indicators',			-- package_name
	'right',						-- location
	'/intranet-confdb/dashboard',				-- page_url
	null,							-- view_name
	10,							-- sort_order
	'im_indicator_timeline_component -indicator_section_id [im_indicator_section_confdb]',
	'lang::message::lookup "" intranet-reporting-dashboard.Indicators_Timeline "Indicators Timeline"'
);
select im_category_new (15265, 'Conf Items', 'Intranet Indicator Section');
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins 
	 where plugin_name = 'Conf Items Indicators Timeline' and 
		page_url = '/intranet-confdb/dashboard'
	),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);




SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,
	'Pre-Sales Queue',			-- plugin_name
	'intranet-reporting-dashboard',		-- package_name
	'left',				-- location
	'/intranet/projects/dashboard',		-- page_url
	null,					-- view_name
	100,					-- sort_order
	'im_dashboard_histogram_sql -diagram_width 400 -sql "
		select	im_lang_lookup_category(''[ad_conn locale]'', p.project_status_id) as project_status,
		        sum(coalesce(presales_probability,project_budget,0) * coalesce(presales_value,0)) as value
		from	im_projects p
		where	p.project_status_id not in (select * from im_sub_categories(81))
		group by project_status_id
		order by project_status
	"',
	'lang::message::lookup "" intranet-reporting-dashboard.Sales_Pipeline "Sales<br>Pipeline"'
);
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins 
	 where plugin_name = 'Pre-Sales Queue' and 
		page_url = '/intranet/projects/dashboard'
	),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);





update im_component_plugins 
set page_url = '/intranet/projects/dashboard', location = 'left'
where page_url = '/intranet/index' and plugin_name = 'Late Milestones';

update im_component_plugins 
set page_url = '/intranet/projects/dashboard', location = 'left'
where page_url = '/intranet/index' and plugin_name = 'Current Milestones';

update im_component_plugins 
set page_url = '/intranet/projects/dashboard', location = 'left'
where plugin_name = 'Projects by Status' and page_url in ('/intranet/index', '/intranet/projects/dashboard');

update im_component_plugins 
set sort_order = 500, location = 'bottom'
where plugin_name = 'MS-Project Warning Component' and page_url in ('/intranet/projects/view');



-- Ticket Portlets
update im_component_plugins 
set page_url = '/intranet-helpdesk/dashboard', location = 'left'
where page_url = '/intranet-helpdesk/index';








-- Absences per department
--
SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,
	'Users per Department',		    	-- plugin_name
	'intranet-reporting-dashboard',		-- package_name
	'left',					-- location
	'/intranet/users/dashboard',		-- page_url
	null,					-- view_name
	10,					-- sort_order
	'im_dashboard_histogram_sql -diagram_width 400 -sql "
	select	im_cost_center_code_from_id(cost_center_id) || '' - '' || im_cost_center_name_from_id(cost_center_id),
		round(coalesce(user_sum, 0.0), 1)
	from	(
		select	cost_center_id,
			tree_sortkey,
			(select count(*) from im_employees e where e.department_id = cc.cost_center_id) as user_sum
		from	im_cost_centers cc
		where	1 = 1
		) t
	where	user_sum > 0
	order by tree_sortkey
	"',
	'lang::message::lookup "" intranet-reporting-dashboard.Users_per_department "Users per Department"'
);
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins 
	 where plugin_name = 'Users per Department'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);






-- Absences per department
--
SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,
	'Average Absences Days per User',		-- plugin_name
	'intranet-reporting-dashboard',		-- package_name
	'left',					-- location
	'/intranet-timesheet2/absences/dashboard',	-- page_url
	null,					-- view_name
	10,					-- sort_order
	'im_dashboard_histogram_sql -diagram_width 400 -sql "
	select	im_cost_center_code_from_id(cost_center_id) || '' - '' || im_cost_center_name_from_id(cost_center_id),
		round(coalesce(1.0 * absence_sum / user_sum, 0.0), 1)
	from	(
		select	cost_center_id,
			tree_sortkey,
			(select count(*) from im_employees e where e.department_id = cc.cost_center_id
			) as user_sum,
			(select	sum(ua.duration_days)
			 from	im_user_absences ua,
			 	im_employees e
			 where	e.department_id = cc.cost_center_id and
			 	e.employee_id = ua.owner_id and
				ua.end_date > now()::date - 365
			) as absence_sum
		from	im_cost_centers cc
		where	1 = 1
		) t
	where	user_sum > 0
	order by tree_sortkey
	"',
	'lang::message::lookup "" intranet-reporting-dashboard.Average_absence_days_per_user_and_department "Average Absences Days per User"'
);
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins 
	 where plugin_name = 'Average Absences Days per User'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);


-- Move the security updates to the top
update im_component_plugins set sort_order = 10 where plugin_name = 'Security Update Client Component';



------------------------------------------------------
-- Create unique constraint to im_view_columns.
--

-- Delete some wrong configuration in demo machines
delete from im_view_columns where view_id = 24 and column_id = 2423 and column_name = 'PM';
delete from im_view_columns where view_id = 30 and column_id = 270223 and column_name = 'Payment date';

drop index if exists im_view_columns_columns_un;
drop index if exists im_view_columns_name_un;
create unique index im_view_columns_columns_un on im_view_columns (view_id, column_id);



-- remove duplicates
delete from im_view_columns where column_id in (
	select	-- vc.view_id,
		-- vc.column_name,
		max(vc.column_id) as del_column_id
	from	im_view_columns vc,
		(select	count(*) as cnt,
			view_id,
			column_name
		from	im_view_columns
		group by view_id, column_name
		) t
	where	t.cnt > 1 and
		vc.view_id = t.view_id and
		vc.column_name = t.column_name
	group by vc.view_id, vc.column_name
);

create unique index im_view_columns_name_un on im_view_columns (view_id, column_name);

