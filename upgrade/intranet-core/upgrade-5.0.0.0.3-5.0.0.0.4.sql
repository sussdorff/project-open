-- upgrade-5.0.0.0.3-5.0.0.0.4.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.0.0.3-5.0.0.0.4.sql','');


-- Add a new constraint to avoid projects that end before they start.
create or replace function inline_0()
returns integer as $body$
DECLARE
	v_count		integer;
BEGIN
	select	count(*) into v_count from pg_constraint
	where	conname = 'im_projects_start_end_chk';
	IF v_count > 0 THEN return 0; END IF;

	update im_projects set end_date = start_date where end_date < start_date;
	alter table im_projects add constraint im_projects_start_end_chk check(end_date >= start_date);
	
	return 0;

END;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();


