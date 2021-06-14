-- upgrade-5.0.2.4.7-5.0.2.4.8.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.2.4.7-5.0.2.4.8.sql','');


create or replace function im_month_enumerator (date, date) 
returns setof date as $body$
declare
	p_start_date		alias for $1;
	p_end_date		alias for $2;
	row			RECORD;
BEGIN
	FOR row IN 
	    	select distinct
			to_char(im_day_enumerator, 'YYYY-MM')||'-01' as month
		from
			im_day_enumerator(p_start_date, p_end_date)
		order by month
	LOOP
		RETURN NEXT row.month;
	END LOOP;
	RETURN;
end;$body$ language 'plpgsql';

