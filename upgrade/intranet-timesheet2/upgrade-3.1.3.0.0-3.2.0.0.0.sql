-- upgrade-3.1.3.0.0-3.2.0.0.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-3.1.3.0.0-3.2.0.0.0.sql','');


-- Very ugly - we need to reverse the introduction
-- of timesheet-tasks in for logging hours. Now
-- timesheet-tasks are a subclass of im_project.

-- Remove the timesheet_task_id constraint (leave 
-- the field for compatibility) from im_hours
-- This field is not necessary anymore, as timesheet_tasks
-- are now a subtype of project.

-- drop the primary key, because the primary key
-- can contain the timesheet_task_id:
--
create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from pg_constraint
        where lower(conname) = ''im_hours_pkey'';
        IF v_count = 0 THEN return 0; END IF;

	alter table im_hours
	drop constraint im_hours_pkey;

        return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();



create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = ''im_hours'' and lower(column_name) = ''timesheet_task_id'';
        IF v_count = 0 THEN return 0; END IF;

	-- copy the timesheet_task column to projects 
	update im_hours set project_id = timesheet_task_id
	where timesheet_task_id is not null;

	-- drop the timesheet_task_id column
	alter table im_hours drop timesheet_task_id;

        return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();




-- Add a new primary key composed by the project_id
-- and the user_id only:
create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from pg_constraint
        where lower(conname) = ''im_hours_pkey'';
        IF v_count > 0 THEN return 0; END IF;

	alter table im_hours 
	add constraint im_hours_pkey primary key (user_id, project_id, day);

        return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();





-- Recreate the indices. 
-- Got lost when removing the timesheet-task field



create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select	count(*) into v_count from pg_indexes
	where	lower(indexname) = ''im_hours_pkey'';
	if v_count > 0 then return 0; end if;

	alter table im_hours add primary key (user_id, project_id, day);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select	count(*) into v_count from pg_indexes
	where	lower(indexname) = ''im_hours_project_id_idx'';
	if v_count > 0 then return 0; end if;

	create index im_hours_project_id_idx on im_hours(project_id);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select	count(*) into v_count from pg_indexes
	where	lower(indexname) = ''im_hours_user_id_idx'';
	if v_count > 0 then return 0; end if;

	create index im_hours_user_id_idx on im_hours(user_id);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select	count(*) into v_count from pg_indexes
	where	lower(indexname) = ''im_hours_day_idx'';
	if v_count > 0 then return 0; end if;

	create index im_hours_day_idx on im_hours(day);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();













create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu		   integer;	v_parent_menu	   integer;
	-- Groups
	v_employees	   integer;	v_accounting	   integer;
	v_senman	   integer;	v_customers	   integer;
	v_freelancers      integer;	v_proman	   integer;
	v_admins	   integer;
BEGIN
    select group_id into v_admins from groups where group_name = ''P/O Admins'';
    select group_id into v_senman from groups where group_name = ''Senior Managers'';
    select group_id into v_proman from groups where group_name = ''Project Managers'';
    select group_id into v_accounting from groups where group_name = ''Accounting'';
    select group_id into v_employees from groups where group_name = ''Employees'';
    select group_id into v_customers from groups where group_name = ''Customers'';
    select group_id into v_freelancers from groups where group_name = ''Freelancers'';

    select menu_id into v_parent_menu
    from im_menus where label=''main'';

    v_menu := im_menu__new (
	null,				-- p_menu_id
	''im_menu'',			-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id
	''intranet-timesheet2'',	-- package_name
	''timesheet2_timesheet'',	-- label
	''Timesheet'',			-- name
	''/intranet-timesheet2/hours/index'', -- url
	73,				-- sort_order
	v_parent_menu,			-- parent_menu_id
	null				-- p_visible_tcl
    );

    PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
    PERFORM acs_permission__grant_permission(v_menu, v_senman, ''read'');
    PERFORM acs_permission__grant_permission(v_menu, v_proman, ''read'');
    PERFORM acs_permission__grant_permission(v_menu, v_accounting, ''read'');
    PERFORM acs_permission__grant_permission(v_menu, v_employees, ''read'');
    PERFORM acs_permission__grant_permission(v_menu, v_customers, ''read'');
    PERFORM acs_permission__grant_permission(v_menu, v_freelancers, ''read'');

    v_menu := im_menu__new (
	null,				-- p_menu_id
	''im_menu'',			-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id
	''intranet-timesheet2'',	-- package_name
	''timesheet2_absences'',	-- label
	''Absences'',			-- name
	''/intranet-timesheet2/absences/index'', -- url
	74,				-- sort_order
	v_parent_menu,			-- parent_menu_id
	null				-- p_visible_tcl
    );

    PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
    PERFORM acs_permission__grant_permission(v_menu, v_senman, ''read'');
    PERFORM acs_permission__grant_permission(v_menu, v_proman, ''read'');
    PERFORM acs_permission__grant_permission(v_menu, v_accounting, ''read'');
    PERFORM acs_permission__grant_permission(v_menu, v_employees, ''read'');
    PERFORM acs_permission__grant_permission(v_menu, v_customers, ''read'');
    PERFORM acs_permission__grant_permission(v_menu, v_freelancers, ''read'');
    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



update im_menus set url='/intranet-timesheet2/absences/index' where label = 'timesheet2_absences';



