-- upgrade-5.0.2.4.2-5.0.2.4.3.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-invoices/sql/postgresql/upgrade/upgrade-5.0.2.4.2-5.0.2.4.3.sql','');


create or replace function inline_0()
returns integer as $body$
DECLARE
	v_count		integer;
BEGIN
	select	count(*) into v_count from user_tab_columns
	where	lower(table_name) = 'intranet_timesheet_prices' and
		lower(column_name) = 'project_id';
	IF v_count > 0 THEN return 1; END IF;

	alter table im_timesheet_prices
	add column project_id integer
		constraint im_timesheet_prices_project_fk
		references im_projects;

	return 0;
END;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();






