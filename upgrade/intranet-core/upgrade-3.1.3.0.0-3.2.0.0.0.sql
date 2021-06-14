-- upgrade-3.1.3.0.0-3.2.0.0.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.1.3.0.0-3.2.0.0.0.sql','');


-- Source frequently used functions
\i upgrade-3.0.0.0.first.sql



-------------------------------------------------------------
-- Updates to upgrade to the "unified" V3.2 model where
-- Task is a subclass of Project.
-------------------------------------------------------------

-- Drop the generic uniquentess constraint on project_nr.
alter table im_projects drop constraint im_projects_nr_un;

-- Create a new constraing that makes sure that the project_nr
-- are unique per parent-project.
-- Project with parent_id != null don't have a filestorage...
--
alter table im_projects add
        constraint im_projects_nr_un
        unique(project_nr, company_id, parent_id);


-- Add a new category for the project_type.
-- Puff, difficult to find one while maintaining compatible
-- the the fixed IDs from ACS 3.4 Intranet...
--
SELECT im_category_new(100, 'Task', 'Intranet Project Type');


-------------------------------------------------------------
-- Add a "sort order" field to Projects
--
create or replace function inline_0 ()
returns integer as '
declare
	v_count	integer;
begin
	select count(*) into v_count from user_tab_columns
	where table_name = ''IM_PROJECTS'' and column_name = ''SORT_ORDER'';
	if v_count > 0 then return 0; end if;

	alter table im_projects add sort_order integer;

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



-------------------------------------------------------------
-- Add a "title_tcl" field to Components
--
create or replace function inline_0 ()
returns integer as '
declare
	v_count	 integer;
begin
	select count(*) into v_count from user_tab_columns
	where table_name = ''IM_COMPONENT_PLUGINS'' and column_name = ''TITLE_TCL'';
	if v_count > 0 then return 0; end if;

	alter table im_component_plugins add title_tcl text;

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



-- Set the default value for title_tcl as the localization
-- of the package name
update im_component_plugins 
set title_tcl = 
	'lang::message::lookup "" "' || package_name || '.' || 
	plugin_name || '" "' || plugin_name || '"'
where title_tcl is null;


-- Remove the "im_employees e" extra select from employees view
update im_view_columns set 
	extra_from = ''
where
	extra_from  = 'im_employees e'
	and column_id = 5500;



-- Manually set some components title_tcl

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-core.Offices "Offices"' 
where plugin_name = 'Company Offices';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-core.Project_Members "Project Members"' 
where plugin_name = 'Project Members';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-core.Recent_Registrations "Recent Registrations"' 
where plugin_name = 'Recent Registrations';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-core.Members "Members"' 
where plugin_name = 'Office Members';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-wiki.Project_Wiki "Project_Wiki"' 
where plugin_name = 'Project Wiki Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-core.Home_Page_Help "Home Page Help"' 
where plugin_name = 'Home Page Help Blurb';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-wiki.HomeWiki "Home Wiki"' 
where plugin_name = 'Home Wiki Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-timesheet2-tasks.Timesheet_Tasks "Timesheet Tasks"' 
where plugin_name = 'Project Timesheet Tasks';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-timesheet2-invoices.Price_List "Price List"' 
where plugin_name = 'Company Timesheet Prices';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-hr.Employee_Information "Employee Information"' 
where plugin_name = 'User Employee Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-ganttproject.Scheduling "Scheduling"' 
where plugin_name = 'Project GanttProject Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-core.Offices "Offices"' 
where plugin_name = 'User Offices';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-cost.Finance_Summary "Finance Summary"' 
where plugin_name = 'Project Finance Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-filestorage.Filestorage "Filestorage"'
where plugin_name = 'Home Filestorage Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-filestorage.Filestorage "Filestorage"' 
where plugin_name = 'Users Filestorage Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-timesheet2.Timesheet "Timesheet"' 
where plugin_name = 'Project Timesheet Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-filestorage.Sales_Filestorage "Sales Filestorage"' 
where plugin_name = 'Project Sales Filestorage Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-filestorage.Filestorage "Filestorage"' 
where plugin_name = 'Project Filestorage Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-cost "Finance"' 
where plugin_name = 'Project Cost Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-core.Projects "Projects"' 
where plugin_name = 'Home Page Project Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-core.Random_Portrait "Random Portrait"' 
where plugin_name = 'Home Random Portrait';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-forum.Forum "Forum"' 
where plugin_name = 'Home Forum Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-wiki.User_Wiki "User Wiki"' 
where plugin_name = 'User Wiki Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-wiki.Office_Wiki "Office Wiki"' 
where plugin_name = 'Office Wiki Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-timesheet.Timesheet "Timesheet"' 
where plugin_name = 'Home Timesheet Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-cost.Finance_Summary "Finance Summary"' 
where plugin_name = 'Project Finance Summary Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-security-update-client.Security_Updates "Security Updates"' 
where plugin_name = 'Security Update Client Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-forum.Forum "Forum"' 
where plugin_name = 'Project Forum Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-filestorage.Filestorage "Filestorage"' 
where plugin_name = 'Companies Filestorage Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-cost.Finance "Finance"' 
where plugin_name = 'Company Cost Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-forum.Forum "Forum"' 
where plugin_name = 'Companies Forum Component';

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-wiki.Company_Wiki "Company Wiki"' 
where plugin_name = 'Company Wiki Component';


-------------------------------------------------------------
-- Update some components to remove the "im_table_with_title"

update im_component_plugins set 
component_tcl = 'im_forum_component -user_id $user_id -forum_object_id 0 -current_page_url $current_url -return_url $return_url -export_var_list [list forum_start_idx forum_order_by forum_how_many forum_view_name ] -forum_type home -view_name [im_opt_val forum_view_name] -forum_order_by [im_opt_val forum_order_by] -start_idx [im_opt_val forum_start_idx] -restrict_to_mine_p t -restrict_to_new_topics 1',
title_tcl = 'im_forum_create_bar "<B>[_ intranet-forum.Forum_Items]<B>" 0 $return_url'
where plugin_name = 'Home Forum Component';


update im_component_plugins set
component_tcl = 'im_forum_component -user_id $user_id -forum_object_id $project_id -current_page_url $current_url -return_url $return_url -forum_type "project" -export_var_list [list project_id forum_start_idx forum_order_by forum_how_many forum_view_name] -view_name [im_opt_val forum_view_name] -forum_order_by [im_opt_val forum_order_by] -start_idx [im_opt_val forum_start_idx] -restrict_to_mine_p "f" -restrict_to_new_topics 0',
title_tcl = 'im_forum_create_bar "<B>[_ intranet-forum.Forum_Items]<B>" $project_id $return_url'
where plugin_name = 'Project Forum Component';


update im_component_plugins set
component_tcl = 'im_forum_component -user_id $user_id -forum_object_id $company_id -current_page_url $current_url -return_url $return_url -export_var_list [list company_id forum_start_idx forum_order_by forum_how_many forum_view_name ] -forum_type company -view_name [im_opt_val forum_view_name] -forum_order_by [im_opt_val forum_order_by] -restrict_to_mine_p "f" -restrict_to_new_topics 0',
title_tcl = 'im_forum_create_bar "<B>[_ intranet-forum.Forum_Items]<B>" $company_id $return_url'
where plugin_name = 'Companies Forum Component';


update im_component_plugins set
component_tcl = 'im_timesheet_project_component $user_id $project_id'
where plugin_name = 'Project Timesheet Component';


update im_component_plugins set
component_tcl = 'im_timesheet_home_component $user_id'
where plugin_name = 'Home Timesheet Component';

update im_component_plugins set
component_tcl = 'im_group_member_component $project_id $current_user_id $user_admin_p $return_url "" "" 1'
where plugin_name = 'Project Members';


update im_component_plugins set
component_tcl = 'im_office_user_component $current_user_id $user_id'
where plugin_name = 'User Offices';


update im_component_plugins set
component_tcl = 'im_office_company_component $user_id $company_id'
where plugin_name = 'Company Offices';


update im_component_plugins set
component_tcl = 'im_group_member_component $office_id $user_id $admin $return_url "" "" 1'
where plugin_name = 'Office Members';




-------------------------------------------------------------
-- Map component plugins to users

comment on table im_component_plugins is '
 Components Plugins are handeled in the database in order to allow
 customizations to survive system updates.
';

create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*)	into v_count from user_tab_columns where table_name = ''IM_COMPONENT_PLUGIN_USER_MAP'';
	IF v_count > 0 THEN return 0; END IF;

	create table im_component_plugin_user_map (
		plugin_id		integer
					constraint im_comp_plugin_user_map_plugin_fk
					references im_component_plugins,
		user_id			integer
					constraint im_comp_plugin_user_map_user_fk
					references users,
		sort_order		integer not null,
		minimized_p		char(1)
					constraint im_comp_plugin_user_map_min_p_ck
					check(minimized_p in (''t'',''f''))
					default ''f'',
		location		varchar(100) not null,
			constraint im_comp_plugin_user_map_plugin_pk
			primary key (plugin_id, user_id)
	);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


comment on table im_component_plugin_user_map is '
 This table maps Component Plugins to particular users,
 effectively allowing users to customize their GUI
 layout.
';


-- View to show a "unified" view to the component_plugins, derived
-- from the main table and the overriding user_map:
--
create or replace view im_component_plugin_user_map_all as (
	select
		  c.plugin_id,
		  c.sort_order,
		  c.location,
		  null as user_id
	from
		  im_component_plugins c
  UNION
	select
		  m.plugin_id,
		  m.sort_order,
		  m.location,
		  m.user_id
	from
		  im_component_plugin_user_map m
);





-- -----------------------------------------------------
-- User Exits Menu (Admin Page)
-- -----------------------------------------------------

create or replace function inline_1 ()
returns integer as '
declare
	v_menu			integer;
	v_admin_menu		integer;
	v_admins		  integer;
begin
    select group_id into v_admins from groups where group_name = ''P/O Admins'';
    select menu_id into v_admin_menu from im_menus where label=''admin'';

    v_menu := im_menu__new (
	null,			-- p_menu_id
	''im_menu'',		-- object_type
	now(),			-- creation_date
	null,			-- creation_user
	null,			-- creation_ip
	null,			-- context_id
	''intranet-core'',	-- package_name
	''admin_user_exists'',	-- label
	''User Exists'',	-- name
	''/intranet/admin/user_exits'', -- url
	110,			-- sort_order
	v_admin_menu,		-- parent_menu_id
	null			-- p_visible_tcl
    );

    PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
    return 0;
end;' language 'plpgsql';
select inline_1 ();
drop function inline_1();






-- 060714 fraber: Function changes its type, so we have to
-- delete first.
-- However, there is no dependency on the function by any
-- other PlPg/SQL function, so that should be OK without
-- recompilation.
drop function im_menu__name(integer);

-- Returns the name of the menu
create or replace function im_menu__name (integer) returns varchar as '
DECLARE
	p_menu_id   alias for $1;
	v_name	im_menus.name%TYPE;
BEGIN
	select  name
	into    v_name
	from    im_menus
	where   menu_id = p_menu_id;

	return v_name;
end;' language 'plpgsql';



-- ToDo: Change the "GifPath" parameter to "navbar_default" only


