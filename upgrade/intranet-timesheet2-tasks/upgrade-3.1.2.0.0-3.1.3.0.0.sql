-- upgrade-3.1.2.0.0-3.1.3.0.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-3.1.2.0.0-3.1.3.0.0.sql','');


-- Add new fields to timesheet tasks
--
create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = ''im_timesheet_tasks'' and lower(column_name) = ''start_date'';
        IF v_count > 0 THEN return 0; END IF;

	alter table im_timesheet_tasks
	add start_date timestamptz;

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
        where lower(table_name) = ''im_timesheet_tasks'' and lower(column_name) = ''end_date'';
        IF v_count > 0 THEN return 0; END IF;

	alter table im_timesheet_tasks
	add end_date timestamptz;

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
        where lower(table_name) = ''im_timesheet_tasks'' and lower(column_name) = ''priority'';
        IF v_count > 0 THEN return 0; END IF;

	alter table im_timesheet_tasks
	add priority integer;

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
        where lower(table_name) = ''im_timesheet_tasks'' and lower(column_name) = ''gantt_project_id'';
        IF v_count > 0 THEN return 0; END IF;

	alter table im_timesheet_tasks
	add gantt_project_id integer;

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
        where lower(table_name) = ''im_timesheet_tasks'' and lower(column_name) = ''sort_order'';
        IF v_count > 0 THEN return 0; END IF;

	alter table im_timesheet_tasks
	add sort_order integer;

        return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();



