-- upgrade-5.0.1.0.2-5.0.1.0.3.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-5.0.1.0.2-5.0.1.0.3.sql','');


create or replace function im_absences_month_absence_duration_type (user_id integer, month integer, year integer, absence_type_id integer, include_weekends_p boolean)
returns setof record as $BODY$

declare
        p_user_id               ALIAS FOR $1;
        p_month                 ALIAS FOR $2;
        p_year                  ALIAS FOR $3;
        p_absence_type_id       ALIAS FOR $4;
        p_include_weekends_p    ALIAS FOR $5;
        v_default_date_format   varchar(10) := 'yyyy/mm/dd';
        v_dow                   integer;
        v_month_found           integer;
        v_sql_result            record;
        v_record                record;
        v_searchsql             text;
        v_sql                   text;
begin
    -- sql to get all absences for the month
   v_sql :=          $$ SELECT $$;
   v_sql := v_sql || $$    a.start_date, $$;
   v_sql := v_sql || $$    a.end_date, $$;
   v_sql := v_sql || $$    duration_days, $$;
   v_sql := v_sql || $$    absence_type_id $$;
   v_sql := v_sql || $$ FROM  $$;
   v_sql := v_sql || $$    im_user_absences a $$;
   v_sql := v_sql || $$ WHERE  $$;
   v_sql := v_sql || $$    (a.owner_id = $$ || p_user_id || $$  OR a.group_id IN (select group_id from group_distinct_member_map where member_id = $$ || p_user_id || $$))$$;
   v_sql := v_sql || $$    AND a.absence_status_id NOT IN (16002,16006) $$;
   v_sql := v_sql || $$    AND a.start_date <= (('$$ || p_year || $$-$$ || p_month || $$-01')::date + '1 month'::interval)::date $$;
   v_sql := v_sql || $$    AND a.end_date >= ('$$ || p_year || $$-$$ || p_month || $$-01')::date $$;

    -- Limit absence when absence_type_id is provided
    IF      0 != p_absence_type_id THEN
            v_sql := v_sql || ' and a.absence_type_id = ' || p_absence_type_id;
    END IF;

        FOR v_record IN
        EXECUTE v_sql
        LOOP
        -- for each absence build sequence
                v_searchsql := 'select
                    im_day_enumerator as d,
                    ' || v_record.duration_days || ' as dd,
                    ' || v_record.absence_type_id || ' as ddd
                from
                    im_day_enumerator
                    (
                     to_date(''' || v_record.start_date || ''',''' || v_default_date_format || '''),
                     to_date(''' || v_record.end_date || ''', ''' || v_default_date_format || ''') +1
                     )
                ';

                FOR v_sql_result IN EXECUTE v_searchsql
                LOOP
                        -- Limit output to elements of month inquired for
                        select into v_month_found date_part('month', v_sql_result.d);
                        IF v_month_found = p_month THEN
                        	-- Limit output to weekdays only
				IF p_include_weekends_p THEN
                    			return next v_sql_result;
               		       	ELSE
					select into v_dow extract (dow from v_sql_result.d);
					IF v_dow <> 0 AND v_dow <> 6 THEN
                              			return next v_sql_result;
                    	      		END IF;
                		END IF;
                        END IF;
                END LOOP;
        END LOOP;

    COMMENT ON FUNCTION im_absences_month_absence_duration_type(integer,integer,integer,integer,boolean) IS $$
        Function returns for each user absence found an interval of type: (days date, total_days numeric, absence_type_id integer)
        Parameter "include_weekends_p" has been added to support other than "traditional" working weeks.
	Excludes absence statuses 16002 (deleted) and 16006 (rejected).
    $$;

end;$BODY$
language 'plpgsql';
