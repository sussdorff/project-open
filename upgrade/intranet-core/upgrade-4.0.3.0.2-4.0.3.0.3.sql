-- upgrade-4.0.3.0.2-4.0.3.0.3.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.0.2-4.0.3.0.3.sql','');


-- Modify the project's unique constraints in order to deal
-- with duplicate projects on the top-level



create or replace function inline_0 ()
returns integer as $body$
declare
	v_count  integer;
	row	 RECORD;
begin
	-- Drop the old unique constraints
	select count(*) into v_count from pg_constraint
	where lower(conname) = 'im_projects_name_un';
	IF v_count > 0 THEN alter table im_projects drop constraint im_projects_name_un; END IF;

	-- Disambiguate project names
	FOR row IN
		select	* 
		from	(
			select	count(*) as cnt, 
				project_name, 
				company_id,
				coalesce(parent_id,0) as parent_id
			from	im_projects
			group by 
				project_name, 
				company_id,
				coalesce(parent_id,0)
			) t 
		where	cnt > 1
	LOOP
		RAISE NOTICE 'upgrade-4.0.3.0.2-4.0.3.0.3.sql: Found ambigous project name "%", adding the project_id at the end', row.project_name;
		update	im_projects
		set	project_name = project_name || ' (' || project_id || ')'
		where	project_name = row.project_name and
			company_id = row.company_id and
			coalesce(parent_id,0) = coalesce(row.parent_id,0);

	END LOOP;

	-- Create the new unique indices
	select count(*) into v_count from pg_class
	where lower(relname) = 'im_projects_name_un';
	IF v_count = 0 THEN 
	   	create unique index im_projects_name_un on im_projects (project_name, company_id, coalesce(parent_id,0));
	END IF;

	return 0;
end;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();




create or replace function inline_0 ()
returns integer as $body$
declare
	v_count  integer;
        row      RECORD;
begin
	-- Drop the old unique constraints
	select count(*) into v_count from pg_constraint
	where lower(conname) = 'im_projects_nr_un';
	IF v_count > 0 THEN alter table im_projects drop constraint im_projects_nr_un; END IF;


	-- Disambiguate project_nrs
	FOR row IN
		select	* 
		from	(
			select	count(*) as cnt, 
				project_nr, 
				company_id,
				coalesce(parent_id,0) as parent_id
			from	im_projects
			group by 
				project_nr, 
				company_id,
				coalesce(parent_id,0)
			) t 
		where	cnt > 1
	LOOP
		RAISE NOTICE 'upgrade-4.0.3.0.2-4.0.3.0.3.sql: Found ambigous project_nr "%", adding the project_id at the end', row.project_nr;
		update	im_projects
		set	project_nr = project_nr || '_' || project_id
		where	project_nr = row.project_nr and
			company_id = row.company_id and
			coalesce(parent_id,0) = coalesce(row.parent_id,0);

	END LOOP;


	-- Create the new unique indices
	select count(*) into v_count from pg_class
	where lower(relname) = 'im_projects_nr_un';
	IF v_count = 0 THEN 
	   	create unique index im_projects_nr_un on im_projects (project_nr, company_id, coalesce(parent_id,0));
	END IF;

	return 0;
end;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();




create or replace function inline_0 ()
returns integer as $body$
declare
	v_count  integer;
	row	 RECORD;
begin
	-- Drop the old unique constraints
	select count(*) into v_count from pg_constraint
	where lower(conname) = 'im_projects_path_un';
	IF v_count > 0 THEN alter table im_projects drop constraint im_projects_path_un; END IF;

	-- Disambiguate project_paths
	FOR row IN
		select	* 
		from	(
			select	count(*) as cnt, 
				project_path, 
				company_id,
				coalesce(parent_id,0) as parent_id
			from	im_projects
			group by 
				project_path, 
				company_id,
				coalesce(parent_id,0)
			) t 
		where	cnt > 1
	LOOP
		RAISE NOTICE 'upgrade-4.0.3.0.2-4.0.3.0.3.sql: Found ambigous project_path "%", adding the project_id at the end', row.project_path;
		update	im_projects
		set	project_path = project_path || '_' || project_id
		where	project_path = row.project_path and
			company_id = row.company_id and
			coalesce(parent_id,0) = coalesce(row.parent_id,0);

	END LOOP;

	-- Create the new unique indices
	select count(*) into v_count from pg_class
	where lower(relname) = 'im_projects_path_un';
	IF v_count = 0 THEN 
	   	create unique index im_projects_path_un on im_projects (project_path, company_id, coalesce(parent_id,0));
	END IF;

	return 0;
end;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();


