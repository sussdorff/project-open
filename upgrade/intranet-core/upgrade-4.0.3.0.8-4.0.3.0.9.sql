-- upgrade-4.0.3.0.8-4.0.3.0.9.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.0.8-4.0.3.0.9.sql','');

-- Limit of maximum hours that can be logged per day (see parameter: TimesheetMaxHoursPerDay)
-- might be not applicable for all employees. Employees working in a particular office might 
-- given the permission to log an arbirary amount of hours on a given day. 

create or replace function inline_0 ()
returns integer as $body$
declare
        v_count  integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = 'im_offices' and lower(column_name) = 'ignore_max_hours_per_day_p';

        IF v_count = 0 THEN
		alter table im_offices add column ignore_max_hours_per_day_p char(1) default 'f' check(public_p in ('t','f'));
        END IF;

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as $body$
declare
        v_count         integer;
begin
        select count(*) into v_count from im_view_columns where
              column_id = 8192 and view_id = 81;

        IF v_count > 0 THEN return 1; END IF;

	insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
	extra_select, extra_where, sort_order, visible_for) values (8192,81,NULL,'IgnoreParameterTimesheetMaxHoursPerDay',
	'$ignore_max_hours_per_day_p','','',850,'');

        RETURN 0;

end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

