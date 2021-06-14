-- /packages/intranet-cost/sql/postgres/upgrade/upgrade-3.2.7.0.0-3.2.8.0.0.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-3.2.7.0.0-3.2.8.0.0.sql','');


-- Dirty field with date when the cache became "dirty"

create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = ''im_projects'' and lower(column_name) = ''cost_cache_dirty'';
        IF v_count > 0 THEN return 0; END IF;

	ALTER TABLE im_projects ADD cost_cache_dirty timestamptz;

        return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();





-- Audit fields
create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = ''im_costs'' and lower(column_name) = ''last_modified'';
        IF v_count > 0 THEN return 0; END IF;

	ALTER TABLE im_costs add last_modified           timestamptz;
	ALTER TABLE im_costs add last_modifying_user     integer;
	ALTER TABLE im_costs add constraint im_costs_last_mod_user foreign key (last_modifying_user) references users;
	ALTER TABLE im_costs add last_modifying_ip 	 varchar(20);

        return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();




delete from im_view_columns where column_id = 2134;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2134,21,NULL,'Expenses',
'$cost_expense_logged_cache','','',34,'expr [im_permission $user_id view_finance] && [im_cc_read_p]');


delete from im_view_columns where column_id = 2137;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2137,21,NULL,'Profit',
'[expr [n20 $cost_invoices_cache] - [n20 $cost_bills_cache] - [n20 $cost_expense_logged_cache] - [n20 $cost_timesheet_logged_cache]]',
'','',37,'expr [im_permission $user_id view_finance] && [im_cc_read_p]');


-- Add entry to show invalid cost cache
delete from im_view_columns where column_id = 2110;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2110,21,NULL,'Invalid Since',
'"<font color=red>[string range $cost_cache_dirty 0 9]</font>"','','',10,'');






-------------------------------------------------------------
-- Invalidate the cost cache of related projects
-- (set dirty-flag to current date)
-------------------------------------------------------------

create or replace function im_cost_project_cache_invalidator (integer)
returns integer as '
declare
	p_project_id	alias for $1;

	v_project_id	integer;
	v_count		integer;
	v_parent_id	integer;
	v_last_dirty	timestamptz;
begin
	v_project_id := p_project_id;
	v_count := 20;
	
	WHILE v_project_id is not null AND v_count > 0 LOOP

		-- Get the projects parent and existing dirty flag to continue...
		select parent_id, cost_cache_dirty
		into v_parent_id, v_last_dirty
		from im_projects
		where project_id = v_project_id;

		-- Skip if the update if the project cache is already dirty
		-- Also, we keep a record which was the oldest dirty cache,
		-- so that the cleanup orden stays chronologic with the oldest
		-- dirty cache first.
		IF v_last_dirty is not null THEN return v_count; END IF;

		-- Set the "dirty"-flag. There is a sweeper to cleanup afterwards.
	        RAISE NOTICE ''im_cost_project_cache_invalidator: invalidating cost cache of project %'', p_project_id;
		update im_projects
		set cost_cache_dirty = now()
		where project_id = v_project_id;

		-- Continue with the parent_id
		v_project_id := v_parent_id;

		-- Decrease the loop-protection counter
		v_count := v_count-1;
	END LOOP;

        return v_count;
end;' language 'plpgsql';







-------------------------------------------------------------
-- Trigger for im_cost to invalidate project cost cache on changes
-------------------------------------------------------------


-------------------------------------------------------------
-- Costs Delete Trigger

create or replace function inline_0 () 
returns integer as '
declare
        v_count         integer;
begin
	select count(*) into v_count from pg_trigger
	where lower(tgname) = ''im_costs_project_cache_up_tr'';
	IF v_count = 0 THEN return 0; END IF;
	DROP TRIGGER im_costs_project_cache_up_tr ON im_costs;
        return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();

create or replace function im_cost_project_cache_up_tr ()
returns trigger as '
begin
        RAISE NOTICE ''im_cost_project_cache_up_tr: %'', new.cost_id;
	PERFORM im_cost_project_cache_invalidator (old.project_id);
	PERFORM im_cost_project_cache_invalidator (new.project_id);
        return new;
end;' language 'plpgsql';

CREATE TRIGGER im_costs_project_cache_up_tr
AFTER UPDATE
ON im_costs
FOR EACH ROW
EXECUTE PROCEDURE im_cost_project_cache_up_tr();



-------------------------------------------------------------
-- Costs Insert Trigger

create or replace function inline_0 () 
returns integer as '
declare
        v_count         integer;
begin
	select count(*) into v_count from pg_trigger
	where lower(tgname) = ''im_costs_project_cache_ins_tr'';
	IF v_count = 0 THEN return 0; END IF;
	DROP TRIGGER im_costs_project_cache_ins_tr ON im_costs;
        return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();


create or replace function im_cost_project_cache_ins_tr ()
returns trigger as '
begin
        RAISE NOTICE ''im_cost_project_cache_ins_tr: %'', new.cost_id;
	PERFORM im_cost_project_cache_invalidator (new.project_id);
        return new;
end;' language 'plpgsql';

CREATE TRIGGER im_costs_project_cache_ins_tr
AFTER INSERT
ON im_costs
FOR EACH ROW
EXECUTE PROCEDURE im_cost_project_cache_ins_tr();


-------------------------------------------------------------
-- Costs Delete Trigger

create or replace function inline_0 () 
returns integer as '
declare
        v_count         integer;
begin
	select count(*) into v_count from pg_trigger
	where lower(tgname) = ''im_costs_project_cache_del_tr'';
	IF v_count = 0 THEN return 0; END IF;
	DROP TRIGGER im_costs_project_cache_del_tr ON im_costs;
        return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();


create or replace function im_cost_project_cache_del_tr ()
returns trigger as '
begin
        RAISE NOTICE ''im_cost_project_cache_del_tr: %'', old.cost_id;
	PERFORM im_cost_project_cache_invalidator (old.project_id);
        return new;
end;' language 'plpgsql';

CREATE TRIGGER im_costs_project_cache_del_tr
AFTER DELETE
ON im_costs
FOR EACH ROW
EXECUTE PROCEDURE im_cost_project_cache_del_tr();





-------------------------------------------------------------
-- Trigger for im_projects to invalidate project cost cache on changes:
-- Changing the parent_id of a project or setting the parent_id
-- of a project invalidates the cost caches of its superprojects.


-------------------------------------------------------------
-- Project Update Trigger

create or replace function inline_0 () 
returns integer as '
declare
        v_count         integer;
begin
	select count(*) into v_count from pg_trigger
	where lower(tgname) = ''im_projects_project_cache_up_tr'';
	IF v_count = 0 THEN return 0; END IF;
	DROP TRIGGER im_projects_project_cache_up_tr ON im_projects;
        return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();

create or replace function im_project_project_cache_up_tr ()
returns trigger as '
begin
        RAISE NOTICE ''im_project_project_cache_up_tr: %'', new.project_id;

	IF new.parent_id != old.parent_id THEN
		PERFORM im_cost_project_cache_invalidator (old.parent_id);
		PERFORM im_cost_project_cache_invalidator (new.parent_id);
	END IF;

	IF new.parent_id is null AND old.parent_id is not null THEN
		PERFORM im_cost_project_cache_invalidator (old.parent_id);
	END IF;

	IF new.parent_id is not null AND old.parent_id is null THEN
		PERFORM im_cost_project_cache_invalidator (new.parent_id);
	END IF;
        return new;
end;' language 'plpgsql';

CREATE TRIGGER im_projects_project_cache_up_tr
AFTER UPDATE
ON im_projects
FOR EACH ROW
EXECUTE PROCEDURE im_project_project_cache_up_tr();


