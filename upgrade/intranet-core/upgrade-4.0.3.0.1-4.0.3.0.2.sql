-- upgrade-4.0.3.0.1-4.0.3.0.2.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.0.1-4.0.3.0.2.sql','');


-- Deal with PostgreSQL 8.4 tighter casting rules
--
CREATE OR REPLACE FUNCTION last_day(date)
RETURNS date AS $body$
DECLARE
        p_date_in alias for $1;         -- date_id
       	v_date_out      date;
begin		
       	select to_date(date_trunc('month',add_months(p_date_in,1))::text, 'YYYY-MM-DD'::text) - 1 into v_date_out;
       	return v_date_out;
end;$body$ LANGUAGE 'plpgsql';
