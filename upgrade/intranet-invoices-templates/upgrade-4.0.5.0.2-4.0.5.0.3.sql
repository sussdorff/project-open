SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.0.5.0.2-4.0.5.0.3.sql','');
                                                                                           
create or replace function inline_0 ()
returns integer as $BODY$
declare
        v_count           integer;
begin

	begin
		insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
		extra_select, extra_where, sort_order, visible_for) values (3018,30,NULL,'Add Payment','$new_payment_amount','','',18,'');
        exception when others then
                raise notice '/intranet-invoices/sql/postgresql/upgrade/upgrade-upgrade-4.0.5.0.1-4.0.5.0.2.sql: Could not create column "Add Payment"';
        end;

	begin
		insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
		extra_select, extra_where, sort_order, visible_for) values (3020,30,NULL,'Payment Type','$new_payment_type_id','','',19,'');
        exception when others then
                raise notice '/intranet-invoices/sql/postgresql/upgrade/upgrade-upgrade-4.0.5.0.1-4.0.5.0.2.sql: Could not create column "Payment Type"';
        end;

        return 1;

end;$BODY$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();