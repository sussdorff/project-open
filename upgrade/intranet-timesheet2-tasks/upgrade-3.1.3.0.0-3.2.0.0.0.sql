-- upgrade-3.1.3.0.0-3.2.0.0.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-3.1.3.0.0-3.2.0.0.0.sql','');


-- Source important duplicate-tollerant pl/sql routines
\i ../../../../intranet-core/sql/postgresql/upgrade/upgrade-3.0.0.0.first.sql


--------------------------------------------------------
-- Convert TimesheetTasks to Projects
--------------------------------------------------------


--------------------------------------------------------
-- 1. Create a new project for each timesheet task
create or replace function inline_0 ()
returns integer as '
DECLARE
        row		RECORD;
	v_count		integer;
	v_name		varchar;
BEGIN
    select count(*) into v_count from user_tab_columns
    where lower(table_name) = ''im_timesheet_tasks'' and lower(column_name) = ''project_id'';
    IF v_count = 0 THEN return 0; END IF;

    for row in
        select	t.*,
		p.company_id
        from	im_timesheet_tasks t,
		im_projects p
	where
		p.project_id = t.project_id
		and t.task_id not in (select project_id from im_projects)
	order by
		t.project_id
    loop
	RAISE NOTICE ''create projects for tasks: task_nr=%, project_id=%'', row.task_nr, row.project_id;

        -- Make project_name unique in case of duplicates
        v_name := row.task_name;
	select	count(*) into v_count from im_projects p
	where	p.project_name = v_name and p.company_id = row.company_id;
        IF v_count > 0 THEN v_name := v_name || '' '' || row.task_id; END IF;

	insert into im_projects (
		project_id, project_name, project_nr,
		project_path, parent_id, company_id,
		project_type_id, project_status_id, 
		description,
		percent_completed
	) values (
		row.task_id, v_name, substring(row.task_nr from 1 for 80) || row.project_id::varchar,
		substring(row.task_nr from 1 for 80) || row.project_id::varchar, row.project_id, row.company_id,
		100, 76,
		row.description,
		row.percent_completed
	);
    end loop;
    return 0;
END;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


--------------------------------------------------------
-- 2. Remove tasks that don't have a project_id
-- (the referential integrity must have broken
-- at some moment in the past)


-- ToDo: Maybe create a new dummy project and MOVE the 
-- tasks to this dummy project so that the tasks and 
-- their timesheet information isn't lost?

create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = ''im_hours'' and lower(column_name) = ''timesheet_task_id'';
        IF v_count = 0 THEN return 0; END IF;

	delete from im_hours
	where timesheet_task_id in (
		select	t.task_id
		from	im_timesheet_tasks t
		where	t.project_id not in (select project_id from im_projects)
	);

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
        where lower(table_name) = ''im_timesheet_tasks'' and lower(column_name) = ''project_id'';
        IF v_count = 0 THEN return 0; END IF;

	delete from im_timesheet_tasks 
	where project_id not in (select project_id from im_projects);

        return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();


--------------------------------------------------------
-- 3. Change the foreign key constraint from acs_objects
-- to im_projects
--
alter table im_timesheet_tasks
drop constraint im_timesheet_task_fk;

alter table im_timesheet_tasks
add constraint im_timesheet_task_fk
FOREIGN KEY (task_id) references im_projects;


create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from pg_constraint
        where lower(conname) = ''im_timesheet_tasks_pk'';
        IF v_count > 0 THEN return 0; END IF;

	alter table im_timesheet_tasks
	add constraint im_timesheet_tasks_pk
	primary key(task_id);

        return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();




--------------------------------------------------------
-- 4. Delete the fields in im_timesheet_tasks that are
-- not necessary anymore (taken over by im_project)


create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = ''im_timesheet_tasks'' and lower(column_name) = ''project_id'';
        IF v_count = 0 THEN return 0; END IF;

	alter table im_timesheet_tasks drop column project_id;
	alter table im_timesheet_tasks drop column task_name;
	alter table im_timesheet_tasks drop column task_type_id;
	alter table im_timesheet_tasks drop column task_status_id;
	alter table im_timesheet_tasks drop column description;
	alter table im_timesheet_tasks drop column task_nr;
	alter table im_timesheet_tasks drop column percent_completed;
	alter table im_timesheet_tasks drop column start_date;
	alter table im_timesheet_tasks drop column end_date;
	alter table im_timesheet_tasks drop column gantt_project_id;

        return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();



--------------------------------------------------------
-- Migrate reported_unis_cache to im_projects
--------------------------------------------------------

-- Create a unified view to tasks

-- ToDo: If exists...


create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from pg_class
        where lower(relname) = ''im_timesheet_tasks_view'';
        IF v_count = 0 THEN return 0; END IF;

	drop view im_timesheet_tasks_view;

        return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();



-- ToDo: If not yet exists...
-- sum of timesheet hours cached here for reporting

create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = ''im_projects'' and lower(column_name) = ''reported_hours_cache'';
        IF v_count > 0 THEN return 0; END IF;

	alter table im_projects add reported_hours_cache numeric(12,2);

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
        where lower(table_name) = ''im_timesheet_tasks'' and lower(column_name) = ''reported_units_cache'';
        IF v_count = 0 THEN return 0; END IF;

	alter table im_timesheet_tasks drop reported_units_cache;

        return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();



delete from im_view_columns where column_id = 91014;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91014,910,NULL,'Log',
'"<a href=[export_vars -base $timesheet_report_url { task_id { project_id $project_id } return_url}]>
$reported_hours_cache</a>"','','',14,'');


delete from im_view_columns where column_id = 91108;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91108,911,NULL,'Log',
'"<a href=[export_vars -base $timesheet_report_url { task_id { project_id $project_id } return_url}]>
$reported_hours_cache</a>"','','',8,'');



-- Defines the relationship between two tasks, based on
-- the data model of GanttProject.
-- <depend id="5" type="2" difference="0" hardness="Strong"/>

create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = ''im_timesheet_task_dependencies'';
        IF v_count > 0 THEN return 0; END IF;

		create table im_timesheet_task_dependencies (
			task_id_one		integer
						constraint im_timesheet_task_map_one_nn
						not null
						constraint im_timesheet_task_map_one_fk
						references acs_objects,
			task_id_two		integer
						constraint im_timesheet_task_map_two_nn
						not null
						constraint im_timesheet_task_map_two_fk
						references acs_objects,
			dependency_type_id	integer
						constraint im_timesheet_task_map_dep_type_fk
						references im_categories,
			difference		numeric(12,2),
			hardness_type_id	integer
						constraint im_timesheet_task_map_hardness_fk
						references im_categories,
		
			primary key (task_id_one, task_id_two)
		);
		
		create index im_timesheet_tasks_dep_task_one_idx 
		on im_timesheet_task_dependencies (task_id_one);
		
		create index im_timesheet_tasks_dep_task_two_idx 
		on im_timesheet_task_dependencies (task_id_two);


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
        where lower(table_name) = ''im_timesheet_task_allocations'';
        IF v_count = 0 THEN return 0; END IF;

		-- Allocate a user to a specific task 
		-- with a certain percentage of his time
		--
		create table im_timesheet_task_allocations (
			task_id			integer
						constraint im_timesheet_task_alloc_task_nn
						not null
						constraint im_timesheet_task_alloc_task_fk
						references acs_objects,
		        user_id			integer
						constraint im_timesheet_task_alloc_user_fk
						references users,
			role_id			integer
						constraint im_timesheet_task_alloc_role_fk
						references im_categories,
			percentage		numeric(6,2),
		--				-- No check anymore - might want to alloc 120%...
		--				constraint im_timesheet_task_alloc_perc_ck
		--				check (percentage >= 0 and percentage <= 200),
			task_manager_p		char(1)
						constraint im_timesheet_task_resp_ck
						check (task_manager_p in (''t'',''f'')),
			note			varchar(1000),
		
			primary key (task_id, user_id)
		);

		create index im_timesheet_tasks_dep_alloc_task_idx 
		on im_timesheet_task_allocations (task_id);

		create index im_timesheet_tasks_dep_alloc_user_idx 
		on im_timesheet_task_allocations (user_id);


        return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();



create or replace function im_timesheet_task__name (integer)
returns varchar as '
declare
        p_task_id alias for $1; -- timesheet_task_id
        v_name  varchar(1000);
begin
        select  project_name
        into    v_name
        from    im_projects
        where   project_id = p_task_id;
        return v_name;
end;' language 'plpgsql';



-- Delete a single timesheet_task (if we know its ID...)
create or replace function im_timesheet_task__delete (integer)
returns integer as '
declare
        p_task_id alias for $1; -- timesheet_task_id
begin
        -- Erase the timesheet_task
        delete from     im_timesheet_tasks
        where           task_id = p_task_id;

        -- Erase the object
        PERFORM im_project__delete(p_task_id);
        return 0;
end;' language 'plpgsql';


create or replace function im_timesheet_task__new (
	integer, varchar, timestamptz, integer, varchar, integer,
	varchar, varchar, integer, integer, integer, integer, integer, integer, varchar
) returns integer as '
declare
	p_task_id		alias for $1;		-- timesheet task_id default null
	p_object_type		alias for $2;		-- object_type default ''im_timesheet task''
	p_creation_date		alias for $3;		-- creation_date default now()
	p_creation_user		alias for $4;		-- creation_user
	p_creation_ip		alias for $5;		-- creation_ip default null
	p_context_id		alias for $6;		-- context_id default null

	p_task_nr		alias for $7;
	p_task_name		alias for $8;
	p_project_id		alias for $9;
	p_material_id		alias for $10;
	p_cost_center_id	alias for $11;
	p_uom_id		alias for $12;
	p_task_type_id		alias for $13;
	p_task_status_id	alias for $14;
	p_description		alias for $15;

	v_task_id		integer;
	v_company_id		integer;
    begin
	select	p.company_id
	into	v_company_id
	from	im_projects p
	where	p.project_id = p_project_id;

	v_task_id := im_project__new (
		p_task_id,		-- object_id
		p_object_type,		-- object_type
		p_creation_date,	-- creation_date
		p_creation_user,	-- creation_user
		p_creation_ip,		-- creation_ip
		p_context_id,		-- context_id

		p_task_name,		-- project_name
		p_task_nr,		-- project_nr
		p_task_nr,		-- project_path
		p_project_id,		-- parent_id
		v_company_id,		-- company_id
		p_task_type_id,		-- project_type
		p_task_status_id	-- project_status
	);

	update	im_projects
	set	description = p_description
	where	project_id = v_task_id;

	insert into im_timesheet_tasks (
		task_id,
		material_id,
		uom_id
	) values (
		v_task_id,
		p_material_id,
		p_uom_id
	);

	return v_task_id;
end;' language 'plpgsql';


SELECT im_category_new(100, 'Task', 'Intranet Project Type');



create or replace view im_timesheet_tasks_view as
select
	t.task_id,
	t.material_id,
	t.uom_id,
	t.planned_units,
	t.billable_units,
	t.cost_center_id,
	t.invoice_id,
	t.priority,
	t.sort_order,
        p.parent_id as project_id,
        p.project_name as task_name,
        p.project_nr as task_nr,
        p.percent_completed,
        p.project_type_id as task_type_id,
        p.project_status_id as task_status_id,
        p.start_date,
        p.end_date,
        p.reported_hours_cache,
        p.reported_hours_cache as reported_units_cache
from
        im_projects p,
        im_timesheet_tasks t
where
        t.task_id = p.project_id
;

