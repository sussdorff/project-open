-- upgrade-4.0.3.1.1-4.0.3.1.2.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-4.0.3.1.1-4.0.3.1.2.sql','');



-------------------------------------------------------------
-- New field project_cost_center_id and trigger

create or replace function inline_0()
returns integer as $body$
DECLARE
	v_count		integer;
BEGIN
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_projects' and lower(column_name) = 'project_cost_center_id';
	IF v_count > 0 THEN return 1; END IF;

	alter table im_projects
	add project_cost_center_id integer
	constraint im_projects_cost_center_fk references im_cost_centers;

	update im_projects                                                                           
	set project_cost_center_id = (select e.department_id from im_employees e where e.employee_id = im_projects.project_lead_id)
	where parent_id is null and project_cost_center_id is null;

	return 0;
END;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();


create or replace function im_project_project_cost_center_update_tr ()
returns trigger as $body$
DECLARE
	v_ccid		integer;
	row		RECORD;
BEGIN
	----------------------------------------------------------------
	-- Check if there was a change in the project_cost_center_id
	-- and propagete the change to the children
	IF
		old.project_cost_center_id is not null and
		new.project_cost_center_id is not null and
		old.project_cost_center_id != new.project_cost_center_id
	THEN 
		-- Propagate to direct subprojects
		-- These _direct_ subprojects are responsible for
		-- further propagating down, creating a recursion loop.
		-- ToDo
		RAISE NOTICE 'im_project_project_cost_center_update_tr: %: Propagating to children', new.project_id;
		FOR row IN
			select	sub_p.project_id
			from	im_projects sub_p
			where	sub_p.parent_id = new.project_id
		LOOP
			update	im_projects
			set	project_cost_center_id = new.project_cost_center_id
			where	project_id = row.project_id;
		END LOOP;
		return new;
	END IF;


	----------------------------------------------------------------
	-- Check if the project_cost_center_id needs a default value.
	IF new.project_cost_center_id is null THEN
		-- Take the project_cost_center_id from the parent if available
		IF new.parent_id is not null THEN
			select	pp.project_cost_center_id into v_ccid
			from	im_projects pp
			where	pp.project_id = new.parent_id;
			
			IF v_ccid is not null THEN
				RAISE NOTICE 'im_project_project_cost_center_update_tr: %: Using CC of parent: %', new.project_id, new.parent_id;
				update	im_projects
				set	project_cost_center_id = v_ccid
				where	project_id = new.project_id;
				-- Attention! This action triggers this same proc recursively,
				-- leading to a propagation of the value to sub-projects.
				return new;
			END IF;
		END IF;

		-- Use the department of the project manager as a default value
		select	e.department_id into v_ccid
		from	im_employees e
		where	e.employee_id = new.project_lead_id;

		IF v_ccid is not null THEN
			RAISE NOTICE 'im_project_project_cost_center_update_tr: %: Using CC of PM: %', new.project_id, new.project_lead_id;
			update	im_projects
			set	project_cost_center_id = v_ccid
			where	project_id = new.project_id;
			-- Attention! This action triggers this same proc recursively,
			-- leading to a propagation of the value to sub-projects.
			return new;
		END IF;

	END IF;

	return new;
END;$body$ language 'plpgsql';


-- Drop the trigger if it already exists
create or replace function inline_0()
returns integer as $body$
DECLARE
	v_count		integer;
BEGIN
	select count(*) into v_count from pg_trigger
	where lower(tgname) = 'im_project_project_cost_center_update_tr';
	IF v_count = 0 THEN return 1; END IF;

	DROP TRIGGER im_project_project_cost_center_update_tr ON im_projects;

	return 0;
END;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();


-- Recreate the trigger
CREATE TRIGGER im_project_project_cost_center_update_tr
AFTER UPDATE ON im_projects FOR EACH ROW
EXECUTE PROCEDURE im_project_project_cost_center_update_tr();
