-- upgrade-3.4.0.8.4-3.4.0.8.5.sql

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-3.4.0.8.4-3.4.0.8.5.sql','');


-- Drop the old version of the constraint if exists
create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = ''im_invoice_items'' and lower(column_name) = ''task_id'';
        if v_count > 0 then return 0; end if;

        alter table im_invoice_items add task_id integer;

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();
