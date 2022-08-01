-- upgrade-3.5.9.9.9-4.0.0.0.0.sql

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-3.5.9.9.9-4.0.0.0.0.sql','');

-- Move the "Sel" column to the left
update im_view_columns set sort_order = 0 where column_id = 3115;




-- Drop the old version of the constraint if exists
create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = ''im_invoice_items'' and lower(column_name) = ''created_from_item_id'';
        if v_count > 0 then return 0; end if;

	-- Reference for cases where we want to link a copy
	-- back to the original
	alter table im_invoice_items add
	created_from_item_id    integer
	                        constraint im_invoice_items_created_from_fk
	                        references im_invoice_items;

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


