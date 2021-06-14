-- 
-- 
-- 
-- @author Malte Sussdorff (malte.sussdorff@cognovis.de)
-- @creation-date 2013-01-14
-- @cvs-id $Id$
--
-- upgrade-4.0.3.3.4-4.0.3.3.5.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.0.3.3.4-4.0.3.3.5.sql','');

create or replace function im_absences_month_absence_duration_type (user_id integer, month integer, year integer, absence_type_id integer)
returns setof record as $BODY$

declare
        v_user_id               ALIAS FOR $1;
        v_month                 ALIAS FOR $2;
        v_year                  ALIAS FOR $3;
        v_absence_type_id       ALIAS FOR $4;
        v_default_date_format   varchar(10) := 'yyyy/mm/dd';
        v_dow                   integer;
        v_month_found           integer;
        v_sql_result            record;
        v_record                record;
        v_searchsql             text;
        v_sql                   text;

begin
    -- sql to get all absences
    v_sql := $$select a.start_date, a.end_date, duration_days, absence_type_id from im_user_absences a where a.owner_id = $$;
    v_sql := v_sql || v_user_id;
    v_sql := v_sql || $$ and ((date_part('month', a.start_date) = $$;
    v_sql := v_sql || v_month;
    v_sql := v_sql || $$ AND date_part('year', a.start_date) = $$;
    v_sql := v_sql || v_year;
    v_sql := v_sql || $$ ) OR (date_part('month', a.end_date) = $$;
    v_sql := v_sql || v_month;
    v_sql := v_sql || $$ AND date_part('year', a.end_date) = $$;
    v_sql := v_sql || v_year;
    v_sql := v_sql || $$ )) and a.absence_status_id in (16000, 16004)$$;

    -- Limit absence when absence_type_id is provided
    IF      0 != v_absence_type_id THEN
            v_sql := v_sql || ' and a.absence_type_id = ' || v_absence_type_id;
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
                        IF v_month_found = v_month THEN
                        -- Limit output to weekdays only
                                select into v_dow extract (dow from v_sql_result.d);
                                IF v_dow <> 0 AND v_dow <> 6 THEN
                                        return next v_sql_result;
                                END IF;
                        END IF;
                END LOOP;
        END LOOP;
end;$BODY$
language 'plpgsql';
