

-- Add fields to store results from adding up costs in 
-- the "Finance" view of a project.

alter table im_projects add	cost_quotes_cache		numeric(12,2);
alter table im_projects add	cost_invoices_cache		numeric(12,2);
alter table im_projects add	cost_timesheet_planned_cache	numeric(12,2);

alter table im_projects add	cost_purchase_orders_cache	numeric(12,2);
alter table im_projects add	cost_bills_cache		numeric(12,2);
alter table im_projects add	cost_timesheet_logged_cache	numeric(12,2);




-- 2480 - 2490 Reserved for Timesheet

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (
2481,24,NULL,'Invoices','$cost_invoices_cache','','',81,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (
2482,24,NULL,'Bills','$cost_bills_cache','','',82,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (
2483,24,NULL,'TimeCosts','$cost_timesheet_logged_cache','','',83,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (
2486,24,NULL,'Quotes','$cost_quotes_cache','','',86,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (
2487,24,NULL,'POs','$cost_purchase_orders_cache','','',87,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (
2488,24,NULL,'TimeEstim','$cost_timesheet_planned_cache','','',88,'');





-- Cost Center Menu as part of the Finance menu
--
create or replace function inline_0 ()
returns integer as '
declare
        -- Menu IDs
        v_menu                  integer;
        v_finance_menu          integer;

        -- Groups
        v_employees             integer;
        v_accounting            integer;
        v_senman                integer;
        v_customers             integer;
        v_freelancers           integer;
        v_proman                integer;
        v_admins                integer;
begin

    select group_id into v_admins from groups where group_name = ''P/O Admins'';
    select group_id into v_senman from groups where group_name = ''Senior Managers'';
    select group_id into v_accounting from groups where group_name = ''Accounting'';
    select group_id into v_customers from groups where group_name = ''Customers'';
    select group_id into v_freelancers from groups where group_name = ''Freelancers'';

    select menu_id
    into v_finance_menu
    from im_menus
    where label=''finance'';

    v_finance_menu := im_menu__new (
        null,                      -- menu_id
        ''im_menu'',            -- object_type
        now(),                     -- creation_date
        null,                      -- creation_user
        null,                      -- creation_ip
        null,                      -- context_id
        ''intranet-cost'',         -- package_name
        ''finance_cost_centers'',  -- label
        ''Cost Centers'',          -- name
        ''/intranet-cost/cost-centers/index'',     -- url
        90,                        -- sort_order
        v_finance_menu,            -- parent_menu_id
        null                       -- visible_tcl
    );


    PERFORM acs_permission__grant_permission(v_finance_menu, v_admins, ''read'');
    PERFORM acs_permission__grant_permission(v_finance_menu, v_senman, ''read'');
    PERFORM acs_permission__grant_permission(v_finance_menu, v_accounting, ''read'');
--    PERFORM acs_permission__grant_permission(v_finance_menu, v_customers, ''read'');
--    PERFORM acs_permission__grant_permission(v_finance_menu, v_freelancers, ''read'');

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();



create or replace function im_cost_center_name_from_id (integer)
returns varchar as '
DECLARE
        p_id	alias for $1;
        v_name	varchar(100);
BEGIN
        select	cc.cost_center_name
        into	v_name
        from	im_cost_centers cc
        where	cost_center_id = p_id;

        return v_name;
end;' language 'plpgsql';


