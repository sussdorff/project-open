-- 
-- packages/intranet-timesheet2/sql/postgresql/upgrade/4.0.1.0.1-4.0.1.0.2.sql
-- 
-- Copyright (c) 2011, cognovís GmbH, Hamburg, Germany
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
-- 
-- @author Malte Sussdorff (malte.sussdorff@cognovis.de)
-- @creation-date 2011-06-08
-- @cvs-id $Id$
--

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/4.0.1.0.1-4.0.1.0.2.sql','');

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
