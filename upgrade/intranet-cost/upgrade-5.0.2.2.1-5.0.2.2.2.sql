-- 5.0.2.2.1-5.0.2.2.2.sql
SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-5.0.2.2.1-5.0.2.2.2.sql','');


create or replace function inline_0()
returns integer as $body$
DECLARE
	v_count		integer;
BEGIN
	select	count(*) into v_count from pg_indexes where indexname = 'im_costs_type_idx';
	IF v_count = 0 THEN 
		create index im_costs_type_idx on im_costs(cost_type_id);   
	END IF;

	select	count(*) into v_count from pg_indexes where indexname = 'im_costs_project_idx';
	IF v_count = 0 THEN 
		create index im_costs_project_idx on im_costs(cost_type_id);   
	END IF;

	return 0;
END;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();




