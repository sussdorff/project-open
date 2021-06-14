-- upgrade-4.1.0.0.0-4.1.0.1.0.sql
SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.1.0.0.0-4.1.0.1.0.sql','');

create or replace function inline_0() 
returns integer as $body$
DECLARE
	v_count		integer;
BEGIN
	select	count(*) into v_count from pg_class
	where	lower(relname) = 'im_timesheet_task_dependency_seq';
	IF v_count > 0 THEN return 1; END IF;

	create sequence im_timesheet_task_dependency_seq start 1;

	alter table im_timesheet_task_dependencies 
	drop constraint im_timesheet_task_dependencies_pkey;

	alter table im_timesheet_task_dependencies
	add column dependency_id integer
	default nextval('im_timesheet_task_dependency_seq')
	constraint im_timesheet_task_dependency_pk
	primary key;

	PERFORM im_category_new(9740,'Active', 'Intranet Gantt Task Dependency Status');

	alter table im_timesheet_task_dependencies
	add column dependency_status_id integer default 9740
	constraint im_timesheet_task_map_dep_status_nn
	not null
	constraint im_timesheet_task_map_dep_status_fk
	references im_categories;

	create unique index im_timesheet_task_dependency_un
	on im_timesheet_task_dependencies (task_id_one, task_id_two);

	PERFORM acs_object_type__create_type (
		'im_timesheet_task_dependency',		-- object_type
		'Gantt Task Dependency',		-- pretty_name
		'Gantt Task Dependencies',		-- pretty_plural
		'acs_object',				-- supertype
		'im_timesheet_task_dependencies',	-- table_name
		'dependency_id',			-- id_column
		'intranet-timesheet2-tasks-deps',	-- package_name
		'f',					-- abstract_p
		null,					-- type_extension_table
		'im_timesheet_task_dependency__name'	-- name_method
	);

	update acs_object_types set
		status_type_table = 'im_timesheet_task_dependencies',
		status_column = 'dependency_status_id',
		type_column = 'dependency_type_id'
	where object_type = 'im_timesheet_task_dependency';

	PERFORM im_rest_object_type__new(
		null,
		'im_rest_object_type',
		now(),
		0,
		'0.0.0.0',
		null,
		'im_timesheet_task_dependency',
		null,
		null
	);

	return 0;  
END;
$body$ language 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();

