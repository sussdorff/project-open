-- upgrade-4.0.1.0.6-4.0.1.0.7.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.0.1.0.6-4.0.1.0.7.sql','');

drop function im_absences_get_absences_for_user(int4,date,date,int4); 

create or replace function im_absences_get_absences_for_user(int4,date,date,int4) returns setof record as $body$
    declare
            v_user_id               ALIAS FOR $1;
            v_start_date            ALIAS FOR $2;
            v_end_date              ALIAS FOR $3;
            v_absence_type_id       ALIAS FOR $4;

            v_default_date_format   varchar(10) := 'YYYY-MM-DD';
            v_dow                   integer;
            v_date_found            date;
            v_sql_result            record;
            v_record                record;
            v_searchsql             text;

    begin
           FOR v_record IN
                    -- get user absences
                    select
                            a.absence_id,
                            a.start_date,
                            a.end_date,
                            a.absence_type_id
                    from
                            im_user_absences a
                    where
                            a.group_id is null and
                            a.owner_id = v_user_id and (
                                                (
						a.start_date::date between v_start_date::date and v_end_date::date::date OR
                                                a.end_date::date between v_start_date::date and v_end_date::date::date
						)
						OR
						(
						v_start_date::date between a.start_date::date and a.end_date::date OR 
						v_end_date::date between a.start_date::date and a.end_date::date
						)
                           )
                   UNION
                      -- get all group absences
                        select
                                i.absence_id,
                                i.start_date,
                                i.end_date,
                                i.absence_type_id
                        from (
                                select
                                        a.absence_id,
                                        a.start_date,
                                        a.end_date,
                                        a.absence_type_id,
                                        a.group_id
                                from
                                        im_user_absences a
                                where
                                        group_id is not null and (
                                                (
						a.start_date::date between v_start_date::date and v_end_date::date::date OR
                                                a.end_date::date between v_start_date::date and v_end_date::date::date
						)
						OR
						(
						v_start_date::date between a.start_date::date and a.end_date::date OR 
						v_end_date::date between a.start_date::date and a.end_date::date 
						)
                                        ) 
                       ) i
                       where
                                acs_group__member_p(v_user_id, i.group_id, TRUE::boolean)
                LOOP
                    -- Enumeration over start/end date of period
                    v_searchsql = 'select
                                        im_day_enumerator as d,
                                        1 as absence_type_id,
                                        0 as absence_id
                                    from
                                        im_day_enumerator (''' || v_start_date || '''::date ,''' ||  v_end_date || '''::date +1)';

                    -- RAISE NOTICE 'im_absences_get_absences_for_user: v_searchsql= %', v_searchsql;

                    FOR v_sql_result IN EXECUTE v_searchsql
                    LOOP
                            -- Get date from seq
                            v_date_found := v_sql_result.d;
                            -- check for date
                            IF v_date_found::date >= v_record.start_date::date AND v_date_found::date <= v_record.end_date::date THEN
                                -- check for absence type
                                IF v_absence_type_id = NULL OR v_record.absence_type_id = v_record.absence_type_id THEN
                                        select into v_sql_result.absence_type_id v_record.absence_type_id;
                                        select into v_sql_result.absence_id v_record.absence_id;
                                        RETURN next v_sql_result;
                                END IF;
                            END IF;
                    END LOOP;
            END LOOP;
end;$body$ language 'plpgsql';
