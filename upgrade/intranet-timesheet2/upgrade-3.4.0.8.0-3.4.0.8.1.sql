-- upgrade-3.4.0.8.0-3.4.0.8.1.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-3.4.0.8.0-3.4.0.8.1.sql','');


update im_menus
set url = '/intranet-reporting/timesheet-customer-project?'
where url = '/intranet-reporting/timesheet-customer-project??';



create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
	select count(*) into v_count from user_tab_columns
	where table_name = ''IM_USER_ABSENCES'' and column_name = ''GROUP_ID'';
        if v_count > 0 then return 0; end if;

	alter table im_user_absences add group_id integer
	constraint im_user_absences_group_fk references groups;

	-- Add a constraint to make sure that the owner_id isnt set accidentally
	-- if the absence refers to a group.
	alter table im_user_absences add constraint im_user_absences_group_ck
	check (not (group_id is not null and absence_type_id != 5005));

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
	select count(*) into v_count from user_tab_columns
	where table_name = ''IM_HOURS'' and column_name = ''DAYS'';
        if v_count > 0 then return 0; end if;

	alter table im_hours add days numeric(5,2);

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();





-- add_absences_for_group allows to define absences for groups of users
SELECT acs_privilege__create_privilege('add_absences_for_group','Add Absences For Group','Add Absences For Group');
SELECT acs_privilege__add_child('admin', 'add_absences_for_group');

-- Allow the Accounting guys, HR dept and Senior managers to add absences for all users
SELECT im_priv_create('add_absences_for_group', 'Accounting');
SELECT im_priv_create('add_absences_for_group', 'HR Managers');
SELECT im_priv_create('add_absences_for_group', 'Senior Managers');



delete from im_view_columns where column_id = 20005;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (20005,200,NULL,'User',
'"$user_link"','','',5,'');





create or replace function inline_0 ()
returns integer as '
declare
	v_menu		   integer;	
	v_parent_menu	   integer;
	v_employees	   integer;
	v_count		   integer;
BEGIN
    select group_id into v_employees from groups where group_name = ''Employees'';

    select count(*) into v_count from im_menus where label = ''reporting-timesheet-weekly-report'';
    IF v_count > 0 THEN return 0; END IF;

    select menu_id into v_parent_menu from im_menus where label=''reporting-timesheet'';

    v_menu := im_menu__new (
	null,				-- p_menu_id
	''im_menu'',			-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id
	''intranet-timesheet2'',	-- package_name
	''reporting-timesheet-weekly-report'',	-- label
	''Timesheet Weekly Report'',	-- name
	''/intranet-timesheet2/weekly_report?'', -- url
	77,				-- sort_order
	v_parent_menu,			-- parent_menu_id
	null				-- p_visible_tcl
    );

    PERFORM acs_permission__grant_permission(v_menu, v_employees, ''read'');

    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();





create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_user_absence'';
	IF v_count > 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_user_absence'', ''im_user_absences'', ''absence_id'');

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();





-- Create a plugin for the Vacation Balance
SELECT im_component_plugin__new (
	null,				-- plugin_id
	'im_component_plugin',		-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id
	'Vacation Balance',		-- plugin_name
	'intranet-timesheet2',		-- package_name
	'left',				-- location
	'/intranet/users/view',		-- page_url
	null,				-- view_name
	20,				-- sort_order
	'im_absence_vacation_balance_component -user_id_from_search $user_id'	-- component_tcl
);

-- The component itself does a more thorough check
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins where plugin_name = 'Vacation Balance' and package_name = 'intranet-timesheet2'), 
	(select group_id from groups where group_name = 'Employees'),
	'read'
);



-- Force the re-calculation of all im_project.cost_logged_hours and cost_logged_days caches
update im_projects
set cost_cache_dirty = now();


