-- upgrade-5.0.1.0.0-5.0.1.0.1.sql
SELECT acs_log__debug('/packages/intranet-resource-management/sql/postgresql/upgrade/upgrade-5.0.1.0.0-5.0.1.0.1.sql','');


-- Returns the work days for a given period 
-- whereas: "work days" = Number of days in period -absences -bank_holidays -weekends 
-- Expects start_date and end_date as YYYY/MM/DD
CREATE OR REPLACE FUNCTION im_absences_working_days_period_weekend_only(character varying, character varying)
RETURNS SETOF record AS $body$
DECLARE
	v_start_date		ALIAS FOR $1;
	v_end_date		ALIAS FOR $2;
	v_count			integer;
	v_seperator		CHAR DEFAULT '-';
	v_date_weekday		date;
	v_dow			integer;		
	sql_result		record;
	r			record;
begin
	FOR r in
		SELECT	series.all_days_in_period as working_day
		FROM	(SELECT	*
			FROM	im_day_enumerator(to_date(v_start_date,'yyyy-mm-dd'), to_date(v_end_date,'yyyy-mm-dd')) AS all_days_in_period
			) series
	LOOP
		select into v_dow extract (dow from r.working_day);
		IF v_dow <> 0 AND v_dow <> 6 THEN
			return next r;
		END IF;
	END LOOP;
end;$body$ LANGUAGE 'plpgsql' VOLATILE;

