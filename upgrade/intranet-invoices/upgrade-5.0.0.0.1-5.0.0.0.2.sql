-- upgrade-5.0.0.0.1-5.0.0.0.2.sql
SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-5.0.0.0.1-5.0.0.0.2.sql','');
                                                                                           
create or replace function inline_0 ()
returns integer as $BODY$
declare
        v_count           integer;
	v_next_column_id  integer;
begin

	begin
		SELECT MAX(column_id)+1 INTO v_next_column_id FROM im_view_columns;		
		insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
		extra_select, extra_where, sort_order, visible_for) values (v_next_column_id,30,NULL,'Payment date','$new_payment_date','','',19,'');
        exception when others then
                raise notice '/intranet-invoices/sql/postgresql/upgrade/upgrade-5.0.0.0.1-5.0.0.0.2.sql: Could not create column "Payment date"';
        end;

        return 1;

end;$BODY$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();
