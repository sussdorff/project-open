-- upgrade-3.4.0.1.0-3.4.0.2.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-3.4.0.1.0-3.4.0.2.0.sql','');


-- ------------------------------------------------------
-- Add new field to im_hours to record in which invoice contained
-- ------------------------------------------------------

create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
        select count(*) into v_count from user_tab_columns
	where table_name = ''IM_HOURS'' and column_name = ''INVOICE_ID'';
        if v_count > 0 then return 0; end if;

	alter table im_hours
	add invoice_id integer references im_costs;

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

