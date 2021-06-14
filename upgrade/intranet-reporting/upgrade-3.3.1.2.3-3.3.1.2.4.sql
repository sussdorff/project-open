-- upgrade-3.3.1.2.3-3.3.1.2.4.sql

SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-3.3.1.2.3-3.3.1.2.4.sql','');


---------------------------------------------------------
-- im_get_hours_logged  
-- gets hours logged for user/project on particular day
-- 

CREATE OR REPLACE FUNCTION im_get_hours_logged( int4,  int4,  "varchar") RETURNS "numeric" AS '
declare
	v_user_id	ALIAS FOR $1;
        v_project_id    ALIAS FOR $2;
        v_day_substring ALIAS FOR $3;
	v_hours        	NUMERIC (5,2);
BEGIN
	select	hours 
	into	v_hours
	from	im_hours
	where	user_id = v_user_id and 
		project_id = v_project_id and 
		substring (day::varchar from 1 for 10) = v_day_substring; 
    return v_hours;
END;'
LANGUAGE 'plpgsql';

---------------------------------------------------------
-- im_get_hours_percentage  
-- gets % of hours logged for user/project on particular day based on hours spend the month
-- 

CREATE OR REPLACE FUNCTION im_get_hours_percentage(int4, int4, "varchar")
  RETURNS "numeric" AS '
    declare
        v_user_id	ALIAS FOR $1;
        v_project_id    ALIAS FOR $2;
        v_day_substring ALIAS FOR $3;
        v_hours_project NUMERIC (10,2);
        v_hours_total   NUMERIC (10,2);
        v_result   	NUMERIC (10,2);
    BEGIN
	select	sum(hours) into v_hours_project
	from	im_hours
	where	user_id = v_user_id and 
		project_id = v_project_id and 
		substring (day::varchar from 1 for 7) = v_day_substring; 

	select	sum(hours) into v_hours_total
	from	im_hours 
	where	user_id = v_user_id and 
		substring (day::varchar from 1 for 7) = v_day_substring; 

        v_result := v_hours_project * 100 / v_hours_total;
 
       return v_result;
    END;'
LANGUAGE 'plpgsql';
