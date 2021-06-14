-- upgrade-3.1.2.0.0-3.1.3.0.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.1.2.0.0-3.1.3.0.0.sql','');

\i upgrade-3.0.0.0.first.sql


-------------------------------------------------------------
-- Function used to enumerate days between stat_date and end_date
-------------------------------------------------------------

create or replace function im_day_enumerator (
	date, date
) returns setof date as '
declare
	p_start_date	    alias for $1;
	p_end_date	      alias for $2;
	v_date		  date;
	v_counter	       integer;
BEGIN
	v_date := p_start_date;
	v_counter := 100;
	WHILE (v_date < p_end_date AND v_counter > 0) LOOP
		RETURN NEXT v_date;
		v_date := v_date + 1;
		v_counter := v_counter - 1;
	END LOOP;
	RETURN;
end;' language 'plpgsql';

-- Test query
-- select * from im_day_enumerator(now()::date, now()::date + 7);



-- Add "edit_companies_all" privilege
create or replace function inline_0 ()
returns integer as '
declare
	v_count		 integer;
begin
	select count(*) into v_count from acs_privileges
	where privilege = ''edit_companies_all'';
	IF 0 != v_count THEN return 0; END IF;

	PERFORM acs_privilege__create_privilege(
		''edit_companies_all'',
		''Edit All Companies'',
		''Edit All Companies''
	);
	PERFORM acs_privilege__add_child(''admin'', ''edit_companies_all'');

    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



SELECT acs_privilege__create_privilege('edit_companies_all','Edit All Companies','Edit All Companies');
SELECT acs_privilege__add_child('admin', 'edit_companies_all');

