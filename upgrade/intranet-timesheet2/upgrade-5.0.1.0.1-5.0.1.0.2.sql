-- upgrade-5.0.1.0.1-5.0.1.0.2.sql
SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-5.0.1.0.1-5.0.1.0.2.sql','');

create or replace function im_absences_working_days_month (user_id integer, month integer, year integer)
returns setof record as $BODY$

declare
        v_user_id               ALIAS FOR $1;
        v_month                 ALIAS FOR $2;
        v_year                  ALIAS FOR $3;
        v_count                 integer;
        v_number_days_month     integer;
        v_first_day_month       INTEGER NOT NULL := 1;
        v_seperator             CHAR DEFAULT '-';
        v_date_first_day        varchar(10) DEFAULT v_year || v_seperator || v_month || v_seperator || '01';
        v_date_last_day         varchar(10);
        v_date_weekday          date;
        v_dow                   integer;
        sql_result              record;
        r                       record;
        v_r_varchar             varchar(2);
begin
    
    SELECT DATE_PART('days', DATE_TRUNC('month', v_date_first_day::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL) into v_number_days_month;
    SELECT to_char(v_date_first_day::date + '1 month'::interval - '1 day'::interval, 'YYYY-MM-DD') into v_date_last_day;  

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
                (
        -- User Absences 
                SELECT
                        date_part('day',d) as absence_day
                from
                        im_user_absences a,
                        users u,
                        (select im_day_enumerator as d from im_day_enumerator(v_date_first_day::date, v_date_last_day::date)) d
                where
                        a.owner_id = u.user_id and
                        a.start_date <=  v_date_last_day::date and
                        a.end_date >= v_date_first_day::date and
                        d.d between a.start_date and a.end_date and
                        u.user_id = v_user_id
                UNION
        -- Bank holidays
        SELECT
            date_part('day',d) as absence_day
        FROM
            im_user_absences a,
            (select im_day_enumerator as d from im_day_enumerator(v_date_first_day::date, v_date_last_day::date)) d
        WHERE
            a.start_date <=  v_date_last_day::date and
            a.end_date >= v_date_first_day::date and
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
end;$BODY$
language 'plpgsql';
