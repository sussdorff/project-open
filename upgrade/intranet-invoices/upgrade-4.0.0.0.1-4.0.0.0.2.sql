-- upgrade-4.0.0.0.1-4.0.0.0.2.sql

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.0.0.0.1-4.0.0.0.2.sql','');

create or replace function inline_1 ()
returns integer as '
declare
        v_menu                  integer;
        v_parent_menu           integer;
        v_group_id              integer;
begin 

        select menu_id into v_parent_menu
        from im_menus where label = ''invoices_customers'';
 
        v_menu := im_menu__new (
                null,                                   -- p_menu_id
                ''im_menu'',                            -- object_type
                now(),                                  -- creation_date
                null,                                   -- creation_user
                null,                                   -- creation_ip
                null,                                   -- context_id
                ''intranet-invoices'', 			-- package_name
                ''new_invoice_from_invoice'',		 -- label
                ''New Customer Invoice from Invoice'',   -- name
                ''/intranet-invoices/new-copy?target_cost_type_id=3700&source_cost_type_id=3700'',   -- url
                12,                                    -- sort_order
                v_parent_menu,                          -- parent_menu_id
                null                                    -- p_visible_tcl
        );

        select group_id into v_group_id from groups where group_name = ''Accounting''; 
        PERFORM acs_permission__grant_permission(v_menu, v_group_id, ''read'');

        select group_id into v_group_id from groups where group_name = ''Senior Managers'';
        PERFORM acs_permission__grant_permission(v_menu, v_group_id, ''read'');

        select group_id into v_group_id from groups where group_name = ''Project Managers'';
        PERFORM acs_permission__grant_permission(v_menu, v_group_id, ''read'');

        return 0;
end;' language 'plpgsql';
select inline_1 ();
drop function inline_1();

