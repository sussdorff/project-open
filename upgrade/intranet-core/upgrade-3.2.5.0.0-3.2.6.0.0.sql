-- upgrade-3.2.5.0.0-3.2.6.0.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.2.5.0.0-3.2.6.0.0.sql','');


\i upgrade-3.0.0.0.first.sql


-- -------------------------------------------------------
-- Setup an invisible Users Admin menu
-- This can be extended later by other modules
-- with more Admin Links
--

create or replace function inline_0 ()
returns integer as '
declare
        -- Menu IDs
        v_menu                  integer;
        v_admin_menu            integer;
        v_main_menu             integer;
BEGIN
    select menu_id
    into v_main_menu
    from im_menus
    where label = ''users'';

    -- Main admin menu - just an invisible top-menu
    -- for all admin entries links under Users
    v_admin_menu := im_menu__new (
        null,                   -- p_menu_id
        ''im_menu'',		-- object_type
        now(),                  -- creation_date
        null,                   -- creation_user
        null,                   -- creation_ip
        null,                   -- context_id
        ''intranet-core'',      -- package_name
        ''users_admin'',        -- label
        ''Users Admin'',        -- name
        ''/intranet-core/'',    -- url
        90,                     -- sort_order
        v_main_menu,            -- parent_menu_id
        ''0''                   -- p_visible_tcl
    );

    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



