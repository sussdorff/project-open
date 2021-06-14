-- upgrade-4.1.0.0.3-4.1.0.0.4.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.1.0.0.3-4.1.0.0.4.sql','');
		
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
    v_sql := v_sql || $$ ))$$; 

    -- Limit absence when absence_type_id is provided
    IF      0 != v_absence_type_id THEN
            v_sql := v_sql || ' and a.absence_type_id = ' || v_absence_type_id;
    END IF;

    -- Limit to only active absences
    v_sql := v_sql || $$ and a.absence_status_id in (select 16000 from dual UNION
      select    h.child_id
      from	im_categories c,
      		im_category_hierarchy h
		where h.parent_id = 16000
                and h.child_id = c.category_id
		and (c.enabled_p = 't' OR c.enabled_p is NULL)) $$;

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

CREATE OR REPLACE FUNCTION inline_0 () 
RETURNS INTEGER AS
$$
declare
        v_count                 integer;
	v_attribute_id 		integer;	
begin
        select count(*) into v_count from im_dynfield_layout_pages
        where page_url = '/intranet-timesheet2/weekly-report' and object_type = 'person';

        IF      0 != v_count
        THEN
                RAISE NOTICE 'upgrade-4.1.0.0.3-4.1.0.0.4.sql failed - layout page already present';
	ELSE

	insert into im_dynfield_layout_pages (
	   page_url,object_type,layout_type,default_p
	) values (
       	  '/intranet-timesheet2/weekly-report','person','table','f'
	);
        END IF;

        select count(*) into v_count from im_dynfield_layout_pages
        where page_url = '/intranet-timesheet2/leave-entitlements/remaining-vacation' and object_type = 'person';

        IF      0 != v_count
        THEN
                RAISE NOTICE 'upgrade-4.1.0.0.3-4.1.0.0.4.sql failed - layout page already present for remaining vacation';
	ELSE

	insert into im_dynfield_layout_pages (
	   page_url,object_type,layout_type,default_p
	) values (
	   '/intranet-timesheet2/leave-entitlements/remaining-vacation','person','table','f'
	);
        END IF;

 	select attribute_id into v_attribute_id from im_dynfield_attributes where widget_name = 'employee_supervisors';

	IF v_attribute_id > 0
	THEN
        select count(*) into v_count from im_dynfield_layout
        where page_url = '/intranet-timesheet2/weekly-report' and attribute_id = v_attribute_id;

        IF      0 != v_count
        THEN
                RAISE NOTICE 'upgrade-4.1.0.0.3-4.1.0.0.4.sql failed - employee supervisors already present in weekly report';
	ELSE

	insert into im_dynfield_layout (
	  attribute_id, page_url, pos_y, label_style
	) values (
	  v_attribute_id, '/intranet-timesheet2/weekly-report', 1, 'plain'
	);
        END IF;
	END IF;

 	select attribute_id into v_attribute_id from im_dynfield_attributes where widget_name = 'employee_status';
	
	IF v_attribute_id > 0
	THEN
        select count(*) into v_count from im_dynfield_layout
        where page_url = '/intranet-timesheet2/weekly-report' and attribute_id = v_attribute_id;

        IF      0 != v_count
        THEN
                RAISE NOTICE 'upgrade-4.1.0.0.3-4.1.0.0.4.sql failed - employee status already present in weekly report';
	ELSE

	insert into im_dynfield_layout (
	  attribute_id, page_url, pos_y, label_style
	) values (
       	  v_attribute_id, '/intranet-timesheet2/weekly-report', 1, 'plain'
	);
        END IF;

        select count(*) into v_count from im_dynfield_layout
        where page_url = '/intranet-timesheet2/leave-entitlements/remaining-vacation' and attribute_id = v_attribute_id;

        IF      0 != v_count
        THEN
                RAISE NOTICE 'upgrade-4.1.0.0.3-4.1.0.0.4.sql failed - employee status already present in remaining vacation';
	ELSE

	insert into im_dynfield_layout (
	  attribute_id, page_url, pos_y, label_style
	) values (
       	  v_attribute_id, '/intranet-timesheet2/leave-entitlements/remaining-vacation', 1, 'plain'
	);
        END IF;
	END IF;
    return 1;

end;
$$ LANGUAGE 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();