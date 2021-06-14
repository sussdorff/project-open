-- upgrade-3.4.1.0.3-3.4.1.0.4.sql

SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-3.4.1.0.3-3.4.1.0.4.sql','');

create or replace function inline_1 ()
returns integer as '
declare
        v_menu                  integer;
        v_parent_menu         	integer;
        v_employees             integer;
begin
        select group_id into v_employees from groups where group_name = ''Employees'';
 
        select menu_id into v_parent_menu
        from im_menus where label = ''reporting-timesheet'';
 
        v_menu := im_menu__new (
                null,                                   -- p_menu_id
                ''im_menu'',                            -- object_type
                now(),                                  -- creation_date
                null,                                   -- creation_user
                null,                                   -- creation_ip
                null,                                   -- context_id
                ''intranet-reporting'',   		-- package_name
                ''timesheet-productivity-calendar-view-workdays-simple'', 				-- label
                ''Timesheet Productivity Report - Monthly View - Simple'',  				-- name
                ''/intranet-reporting/timesheet-productivity-calendar-view-workdays-simple.tcl'',   	-- url
                -10,                                    -- sort_order
                v_parent_menu,                          -- parent_menu_id
                null                                    -- p_visible_tcl
        );
 
        PERFORM acs_permission__grant_permission(v_menu, v_employees, ''read'');
        return 0;
end;' language 'plpgsql';
select inline_1 ();
drop function inline_1();
