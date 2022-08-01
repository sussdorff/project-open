--  upgrade-3.2.3.0.0-3.2.4.0.0.sql

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-3.2.3.0.0-3.2.4.0.0.sql','');


-- New Quote from Quote
--
create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_invoices_new_menu	integer;
	v_finance_menu		integer;

	-- Groups
	v_employees		integer;
	v_accounting		integer;
	v_senman		integer;
	v_customers		integer;
	v_freelancers		integer;
	v_proman		integer;
	v_admins		integer;

	v_count			integer;
begin
    select group_id into v_admins from groups where group_name = ''P/O Admins'';
    select group_id into v_senman from groups where group_name = ''Senior Managers'';
    select group_id into v_accounting from groups where group_name = ''Accounting'';
    select group_id into v_customers from groups where group_name = ''Customers'';
    select group_id into v_freelancers from groups where group_name = ''Freelancers'';

    select menu_id into v_invoices_new_menu from im_menus
    where label=''invoices_customers'';

    select count(*) into v_count from im_menus 
    where label = ''invoices_customers_new_quote_from_quote'';

    IF v_count = 0 THEN
	    v_finance_menu := im_menu__new (
		null,					-- menu_id
		''im_menu'',				-- object_type
		now(),					-- creation_date
		null,					-- creation_user
		null,					-- creation_ip
		null,					-- context_id
		''intranet-invoices'',			-- package_name
		''invoices_customers_new_quote_from_quote'',  	-- label
		''New Quote from Quote'',		-- name
		''/intranet-invoices/new-copy?target_cost_type_id=3702\&source_cost_type_id=3702'',
		120,					-- sort_order
		v_invoices_new_menu,			-- parent_menu_id
		null					-- visible_tcl
	    );

	    PERFORM acs_permission__grant_permission(v_finance_menu, v_admins, ''read'');
	    PERFORM acs_permission__grant_permission(v_finance_menu, v_senman, ''read'');
	    PERFORM acs_permission__grant_permission(v_finance_menu, v_accounting, ''read'');
	    PERFORM acs_permission__grant_permission(v_finance_menu, v_customers, ''read'');
	    PERFORM acs_permission__grant_permission(v_finance_menu, v_freelancers, ''read'');
    END IF;

    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



create or replace function inline_0 ()
returns integer as '
declare
        v_menu                  integer;
        v_invoices_customers    integer;
        v_accounting            integer;
        v_senman                integer;
        v_admins                integer;
        v_count                 integer;
begin
    select group_id into v_admins from groups where group_name = ''P/O Admins'';
    select group_id into v_senman from groups where group_name = ''Senior Managers'';
    select group_id into v_accounting from groups where group_name = ''Accounting'';

    select menu_id into v_invoices_customers from im_menus where label=''invoices_customers'';
    select count(*) into v_count from im_menus
    where label = ''invoices_customers_new_invoice_from_delnote'';
    IF v_count = 0 THEN
            v_menu := im_menu__new (
                null,                      -- menu_id
                ''im_menu'',          	-- object_type
                now(),                    -- creation_date
                null,                      -- creation_user
                null,                      -- creation_ip
                null,                      -- context_id
                ''intranet-invoices'',          -- package_name
                ''invoices_customers_new_invoice_from_delnote'',        -- label
                ''New Customer Invoice from Delivery Note'',    -- name
                ''/intranet-invoices/new-copy?target_cost_type_id=3700\&source_cost_type_id=3724'',
                325,                                            -- sort_order
                v_invoices_customers,                           -- parent_menu_id
                null                                            -- visible_tcl
            );
            PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
            PERFORM acs_permission__grant_permission(v_menu, v_senman, ''read'');
            PERFORM acs_permission__grant_permission(v_menu, v_accounting, ''read'');
    END IF;
    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();
