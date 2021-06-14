-- upgrade-4.0.3.3.3-4.0.3.3.4.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.3.3-4.0.3.3.4.sql','');

create or replace function inline_0 ()
returns integer as $body$
declare
        v_count  	integer;
begin
	-- Sanity check if column exists        
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_offices' and lower(column_name) = 'ignore_max_hours_per_day_p';
	IF v_count = 0 THEN
		return 1;
	END IF;

	-- delete column ignore_max_hours_per_day_p if it has not been used
        select count(*) into v_count from im_offices
        where ignore_max_hours_per_day_p != 'f';

        IF v_count = 0 THEN
		alter table im_offices drop column ignore_max_hours_per_day_p; 
        END IF;
	delete from im_view_columns where column_id = 8192;

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

