-- upgrade-5.0.2.4.2-5.0.2.4.3.sql
SELECT acs_log__debug('/packages/intranet-resource-management/sql/postgresql/upgrade/upgrade-5.0.2.4.2-5.0.2.4.3.sql','');



---------------------------------------------------------
-- Auxillary Functions
---------------------------------------------------------

-- Returns dates of "work days" for a given period (record of type --date--) 
-- whereas: "work days" = Number of days in period - absences - bank holidays - weekends (Sat/Sun) 
-- Expects start_date and end_date in ANSI/ISO format YYYY-MM-DD
--
CREATE OR REPLACE FUNCTION im_absences_working_days_period(integer, character varying, character varying)
RETURNS SETOF record AS $body$
DECLARE
	v_user_id		ALIAS FOR $1;
	v_start_date		ALIAS FOR $2;
	v_end_date		ALIAS FOR $3;
	v_count			integer;
	v_seperator		CHAR DEFAULT '-';
	v_date_weekday		date;
	v_dow			integer;		
	sql_result		record;
	r			record;
begin
	FOR r in
		SELECT	result.all_days_in_period as working_day
		FROM	(	(SELECT	*
				FROM	im_day_enumerator(to_date(v_start_date,'yyyy-mm-dd'), to_date(v_end_date,'yyyy-mm-dd')) AS all_days_in_period
				) series
		LEFT JOIN
			(SELECT	d as absence_day
			from	im_user_absences a,
				users u,
				(select im_day_enumerator as d from im_day_enumerator(to_date(v_start_date,'yyyy-mm-dd'), to_date(v_end_date,'yyyy-mm-dd'))) d
			where	a.owner_id = u.user_id and
				a.start_date <=  to_date(v_start_date,'yyyy-mm-dd')::date and
				a.end_date >= to_date(v_start_date,'yyyy-mm-dd')::date and
				d.d between a.start_date and a.end_date and
				u.user_id = v_user_id
			UNION
				SELECT	d as absence_day
				FROM	im_user_absences a,
					(select im_day_enumerator as d from im_day_enumerator(to_date(v_start_date,'yyyy-mm-dd'), to_date(v_end_date,'yyyy-mm-dd'))) d
				WHERE	a.start_date <=  to_date(v_end_date,'yyyy-mm-dd')::date and
					a.end_date >= to_date(v_start_date,'yyyy-mm-dd')::date and
					d.d between a.start_date and a.end_date and
					a.absence_type_id = 5005
			) absence_days_month ON series.all_days_in_period = absence_days_month.absence_day
		) result
	WHERE	result.absence_day IS NULL
	LOOP
		-- v_date_weekday = v_year || v_seperator || v_month || v_seperator || r.working_day;
		-- select into v_dow extract (dow from v_date_weekday);
		select into v_dow extract (dow from r.working_day);
		IF v_dow <> 0 AND v_dow <> 6 THEN
			return next r;
		END IF;
	END LOOP;
end;$body$ LANGUAGE 'plpgsql' VOLATILE;


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



-- Returns a real[] for each day between start and end 
-- with 100 for working days and 0 for weekends
create or replace function im_resource_mgmt_weekend (integer, date, date)
returns float[] as $body$
DECLARE
	p_user_id			alias for $1;
	p_start_date			alias for $2;
	p_end_date			alias for $3;

	v_weekday			integer;
	v_date				date;
	v_work_days			float[];
	row				record;
BEGIN
	-- Initiate the result array with weekends
	v_date := p_start_date;
	WHILE (v_date <= p_end_date) LOOP
		v_work_days[v_date - p_start_date] := 100;
		v_weekday := to_char(v_date, 'D');
		IF v_weekday = 1 OR v_weekday = 7 THEN
			v_work_days[v_date - p_start_date] := 0;
		END IF;
		v_date := v_date + 1;
	END LOOP;

	return v_work_days;
END;$body$ language 'plpgsql';
-- select im_resource_mgmt_weekend(624, now()::date, '2014-06-30');



-- Returns a real[] for each day between start and end 
-- with 100 for working days and 0 for weekend + bank holidays
create or replace function im_resource_mgmt_work_days (integer, date, date)
returns float[] as $body$
DECLARE
	p_user_id			alias for $1;
	p_start_date			alias for $2;
	p_end_date			alias for $3;

	v_weekday			integer;
	v_date				date;
	v_work_days			float[];
	row				record;
BEGIN
	v_work_days = im_resource_mgmt_weekend(p_user_id, p_start_date, p_end_date);

	-- Apply "Bank Holiday" absences
	FOR row IN
		select	*
		from	im_user_absences a
		where	(a.owner_id = p_user_id OR a.group_id in (select group_id from group_distinct_member_map where member_id = p_user_id)) and
			a.end_date >= p_start_date and
			a.start_date <= p_end_date and
			a.absence_type_id = 5005 and 		-- bank holidays
			a.absence_status_id in (select child_id from im_category_hierarchy where parent_id = 16000 UNION select 16000) 		-- active
	LOOP
		RAISE NOTICE 'im_resource_mgmt_user_absence(%,%,%): Bank Holiday %', p_user_id, p_start_date, p_end_date, row.absence_name;
		v_date := row.start_date;
		WHILE (v_date <= row.end_date) LOOP
			v_work_days[v_date - p_start_date] := 0;
			v_date := v_date + 1;
		END LOOP;
	END LOOP;

	return v_work_days;
END;$body$ language 'plpgsql';
-- select im_resource_mgmt_work_days(624, now()::date, '2014-06-30');


-- Returns a real[] for each day between start and end 
-- with 100 for each day the user has taken vacation.
-- Half days off will appear with 50.
create or replace function im_resource_mgmt_user_absence (integer, date, date)
returns float[] as $body$
DECLARE
	p_user_id			alias for $1;
	p_start_date			alias for $2;
	p_end_date			alias for $3;

	v_weekday			integer;
	v_date				date;
	v_work_days			float[];
	v_result			float[];
	v_absence_duration_work_days	integer;
	v_absence_percentage		float;
	row				record;
BEGIN
	v_work_days = im_resource_mgmt_work_days(p_user_id, p_start_date, p_end_date);

	-- Initiate the result array with weekends
	v_date := p_start_date;
	WHILE (v_date <= p_end_date) LOOP
		v_result[v_date - p_start_date] := 0;
		v_date := v_date + 1;
	END LOOP;

	-- Loop through all of the user absences between start_date and end_date
	-- And add them to the result
	FOR row IN
		select	*
		from	im_user_absences a
		where	a.owner_id = p_user_id and
			a.end_date >= p_start_date and
			a.start_date <= p_end_date and
			a.absence_status_id not in (16002, 16006) 		--- deleted or rejected
	LOOP
		-- Calculate the number of work days in the absence
		v_absence_duration_work_days = 0;
		v_date := row.start_date;
		WHILE (v_date <= row.end_date) LOOP
			IF v_work_days[v_date - p_start_date] > 0 THEN
				v_absence_duration_work_days = 1 + v_absence_duration_work_days;
			END IF;
			v_date := v_date + 1;
		END LOOP;

		-- Calculate the percentage away
		IF 0 != v_absence_duration_work_days THEN
			v_absence_percentage := 100.0 * row.duration_days / v_absence_duration_work_days;
		ELSE
			-- Error: Division by zero:
			-- The vacation is completely within bank holidays.
			RAISE WARNING 'im_resource_mgmt_user_absence(%,%,%): Absence %: No workdays for vacation', p_user_id, p_start_date, p_end_date, row.absence_name;
			v_absence_percentage := 0;
		END IF;
		IF v_absence_duration_work_days > 100 THEN
			-- Error: Overlapping vacations or duration days > work days
			RAISE WARNING 'im_resource_mgmt_user_absence(%,%,%): Absence %: More duration_days=% than work_days=%', p_user_id, p_start_date, p_end_date, row.absence_name, row.duration_days, v_absence_duration_work_days;
			v_absence_percentage := 100;
		END IF;

		-- Add the absence percentage to the result set
		RAISE NOTICE 'im_resource_mgmt_user_absence(%,%,%): Absence %: dur=%, workdays=%, perc=%', p_user_id, p_start_date, p_end_date, row.absence_name, row.duration_days, v_absence_duration_work_days, v_absence_percentage;

		-- Add the vacation to the vacation days
		v_date := row.start_date;
		WHILE (v_date <= row.end_date) LOOP
			IF v_work_days[v_date - p_start_date] > 0 THEN
				v_result[v_date - p_start_date] := v_absence_percentage + v_result[v_date - p_start_date];
			END IF;
			v_date := v_date + 1;
		END LOOP;		
	END LOOP;

	return v_result;
END;$body$ language 'plpgsql';
-- select im_resource_mgmt_user_absence(624, now()::date, '2014-06-30');




-- Returns a real[] for each day between start and end 
-- with 100% if a user is fully assigned to a project.
CREATE OR REPLACE FUNCTION im_resource_mgmt_project_assignation(integer, date, date, boolean)
RETURNS double precision[] AS $BODY$
DECLARE
	p_user_id		alias for $1;
	p_start_date		alias for $2;
	p_end_date		alias for $3;
	p_productive_p		alias for $4;

	v_date			date;
	v_work_days		float[];
	v_result		float[];
	row			record;
BEGIN
	v_work_days = im_resource_mgmt_work_days(p_user_id, p_start_date, p_end_date);

	-- Initiate the result array with weekends
	v_date := p_start_date;
	WHILE (v_date <= p_end_date) LOOP
		v_result[v_date - p_start_date] := 0;
		v_date := v_date + 1;
	END LOOP;

	FOR row IN
		select	*,
			CASE WHEN c.company_path = 'internal' THEN false ELSE true END as project_productive_p
		from	im_projects p,
			im_companies c,
			acs_rels r,
			im_biz_object_members bom
		where	p.company_id = c.company_id and
			r.object_id_one = p.project_id and
			r.rel_id = bom.rel_id and
			(r.object_id_two = p_user_id OR r.object_id_two in (select group_id from group_distinct_member_map where member_id = p_user_id)) and
			bom.percentage is not null and
			bom.percentage > 0 and
			p.end_date >= p_start_date and
			p.start_date <= p_end_date
	LOOP
		RAISE NOTICE 'im_resource_mgmt_project_assignation(%,%,%): Project=%: perc=%', p_user_id, p_start_date, p_end_date, row.project_name, row.percentage;
		IF p_productive_p is NULL OR (p_productive_p = row.project_productive_p) THEN
			v_date := row.start_date;
			IF v_date < p_start_date THEN v_date := p_start_date; END IF;
	
			WHILE (v_date <= row.end_date and v_date <= p_end_date) LOOP
				v_result[v_date - p_start_date] := row.percentage + v_result[v_date - p_start_date];
				v_date := v_date + 1;
			END LOOP;
		END IF;
	END LOOP;
	return v_result;
END;$BODY$ language 'plpgsql';
-- select im_resource_mgmt_user_absence(624, now()::date, '2014-06-30', null);


