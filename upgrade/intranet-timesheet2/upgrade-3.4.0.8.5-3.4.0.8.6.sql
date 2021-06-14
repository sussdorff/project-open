-- upgrade-3.4.0.8.5-3.4.0.8.6.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-3.4.0.8.5-3.4.0.8.6.sql','');

-- table structure - versioning not yet supported 

create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from pg_tables where tablename = ''im_capacity_planning'';
        if v_count > 0 then return 0; end if;

	create sequence im_capacity_planning_id_seq;

	create table im_capacity_planning (
        	id                      integer
                	                primary key
					default nextval(''im_capacity_planning_id_seq''),
	        user_id                 integer,
        	project_id              integer,
	        month			integer,
		year			integer,
	        days_capacity           float,
		last_modified		timestamptz
	);

	alter table im_capacity_planning add constraint im_capacity_planning_un unique (id, user_id, project_id, month, year);

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


-- returns number of absence days for given absence type, month and user
--

create or replace function im_absences_month_absence_type (user_id integer, month integer, year integer, absence_type_id integer)
returns setof record as '

declare
        v_user_id               ALIAS FOR $1;
        v_month                 ALIAS FOR $2;
        v_year                  ALIAS FOR $3;
        v_absence_type_id       ALIAS FOR $4;
        v_default_date_format   varchar(10) := ''yyyy/mm/dd'';
        v_dow                   integer;
        v_month_found           integer;
        v_sql_result            record;
        v_record                record;
        v_searchsql             text;

begin
        FOR v_record IN
                select
                        a.start_date,
                        a.end_date
                from
                        im_user_absences a
                where
                        a.owner_id = v_user_id and
                        a.absence_type_id = v_absence_type_id and 
			((date_part(''month'', a.start_date) = v_month AND date_part(''year'', a.start_date) = v_year) OR (date_part(''month'', a.end_date) = v_month AND date_part(''year'', a.end_date) = v_year)) 
        LOOP
                v_searchsql = ''select im_day_enumerator as d from im_day_enumerator
                (to_date('''''' || v_record.start_date || '''''', '''''' || v_default_date_format ||  ''''''), to_date('''''' || v_record.end_date || '''''', '''''' || v_default_date_format || '''''')+1)'';
                FOR v_sql_result IN EXECUTE v_searchsql
                LOOP
                        select into v_month_found date_part(''month'', v_sql_result.d);
                        IF v_month_found = v_month THEN
                                select into v_dow extract (dow from v_sql_result.d);
                                IF v_dow <> 0 AND v_dow <> 6 THEN
                                        return next v_sql_result;
                                END IF;
                        END IF;
                END LOOP;
        END LOOP;
end;'
language 'plpgsql';


-- function returns list of working days for a user for a given month 
-- 

create or replace function im_absences_working_days_month (user_id integer, month integer, year integer)
returns setof record as '

declare
        v_user_id               ALIAS FOR $1;
        v_month                 ALIAS FOR $2;
        v_year                  ALIAS FOR $3;
        v_count                 integer;
        v_number_days_month     integer;
        v_first_day_month       INTEGER NOT NULL := 1;
        v_seperator             CHAR DEFAULT ''/'';
        v_date_first_day        date;
        v_date_last_day         date;
        v_date_weekday          date;
        v_dow                   integer;
        sql_result              record;
        r                       record;
        v_r_varchar             varchar(2);
begin

	-- Get the number of days in this month
        SELECT
                date_part(''day'', (v_year || ''-'' || v_month || ''-01'') ::date + ''1 month''::interval - ''1 day''::interval) AS days
        INTO
                v_number_days_month;
		
	-- Get the first day in the next month
        SELECT
                to_date( v_month || ''/'' || v_number_days_month || ''/'' || v_year ,''mm/dd/yyyy'')
        INTO
                v_date_last_day
        FROM
                dual;

	FOR r in
	
   	  SELECT
        	result.all_days_in_month as working_day
 	  FROM
		(
		        (SELECT
                		all_days_in_month
			FROM
        	        	generate_series(1,v_number_days_month)
	       		 AS
        	        	all_days_in_month
	        ) series

          LEFT JOIN

	        (SELECT
        	        date_part(''day'',d) as absence_day
	        from
        	        im_user_absences a,
                	users u,
	                (select im_day_enumerator as d from im_day_enumerator(v_date_first_day, v_date_last_day)) d
	        where
        	        a.owner_id = u.user_id and
                	a.start_date <=  v_date_last_day and
	                a.end_date >= v_date_first_day and
        	        d.d between a.start_date and a.end_date and
                	u.user_id = v_user_id
	        UNION
        	        SELECT
                	        date_part(''day'',d) as absence_day
	                FROM
        	                im_user_absences a,
                	        (select im_day_enumerator as d from im_day_enumerator(v_date_first_day,v_date_last_day)) d
	                WHERE
        	                a.start_date <= v_date_last_day and
                	        a.end_date >= v_date_first_day and
                        	d.d between a.start_date and a.end_date and
	                        a.absence_type_id = 5005
                ) absence_days_month
          ON
                series.all_days_in_month = absence_days_month.absence_day
	  ) result

	  WHERE
        	result.absence_day IS NULL
	LOOP
        	v_date_weekday = v_year || v_seperator || v_month || v_seperator || r.working_day;
	        select into v_dow extract (dow from v_date_weekday);
        	IF v_dow <> 0 AND v_dow <> 6 THEN
                	return next r;
	        END IF;
	END LOOP;
end;'
language 'plpgsql';

-- returns number of week days, counts all days from monday to friday
--

CREATE OR REPLACE FUNCTION im_calendar_bizdays (start_date date, end_date date) 
RETURNS int AS '

declare
        v_start_date               ALIAS FOR $1;
        v_end_date                 ALIAS FOR $2;
	  number_biz_days		     integer;
begin

SELECT 
	count(*) 
INTO 
	 number_biz_days
FROM 
	(SELECT 
		extract(''weekday'' FROM v_start_date+x) AS weekday 
	 FROM 
		generate_series(0,v_end_date-v_start_date) x) AS foo 
	 WHERE 
		weekday BETWEEN 1 AND 5;

	return number_biz_days;
end;'
language 'plpgsql';


-- Create menu item and set permissions
-- 

create or replace function inline_1 ()
returns integer as '
declare
        v_menu                  integer;
        v_parent_menu    	integer;
        v_admins                integer;
	v_managers		integer;
	v_hr_managers		integer;
begin

    select group_id into v_admins from groups where group_name = ''P/O Admins'';
    select group_id into v_managers from groups where group_name = ''Senior Managers'';
    select group_id into v_hr_managers from groups where group_name = ''HR Managers'';

    select menu_id into v_parent_menu from im_menus where label=''timesheet2_absences'';

    v_menu := im_menu__new (
        null,                   -- p_menu_id
        ''im_menu'',		-- object_type
        now(),                  -- creation_date
        null,                   -- creation_user
        null,                   -- creation_ip
        null,                   -- context_id
        ''intranet-timesheet2'', -- package_name
        ''capacity-planning'',  -- label
        ''Capacity Planning'',  -- name
        ''/intranet-timesheet2/absences/capacity-planning'', -- url
        500,                    -- sort_order
        v_parent_menu,           -- parent_menu_id
        null                    -- p_visible_tcl
    );

    PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
    PERFORM acs_permission__grant_permission(v_menu, v_managers, ''read'');
    PERFORM acs_permission__grant_permission(v_menu, v_hr_managers, ''read'');

    return 0;
end;' language 'plpgsql';
select inline_1 ();
drop function inline_1();
