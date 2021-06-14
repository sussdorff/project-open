-- upgrade-3.2.8.0.0-3.2.9.0.0.sql

SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-3.2.8.0.0-3.2.9.0.0.sql','');


create or replace function inline_1 ()
returns integer as '
declare
        v_count                 integer;
	v_menu_id		integer;
begin
	select	menu_id into v_menu_id from im_menus
	where	label = ''reporting-timesheet-cube''
		and package_name = ''intranet-reporting'';

	PERFORM im_menu__delete(v_menu_id);

    return 0;
end;' language 'plpgsql';
select inline_1 ();
drop function inline_1();


create or replace function inline_1 ()
returns integer as '
declare
        v_count                 integer;
	v_menu_id		integer;
	row			RECORD;
begin
	FOR row IN
		select	*
		from	im_menus
		where	label like ''reporting-finance-%''
			and package_name = ''intranet-reporting''
	LOOP
		PERFORM im_menu__delete(row.menu_id);
	END LOOP;

	return 0;
end;' language 'plpgsql';
select inline_1 ();
drop function inline_1();


create or replace function inline_1 ()
returns integer as '
declare
        v_count                 integer;
	v_menu_id		integer;
	row			RECORD;
begin
	FOR row IN
		select	*
		from	im_menus
		where	(label like ''reporting-project-trans-%'' OR
			 label like ''reporting-trans-%'')
			and package_name = ''intranet-reporting''
	LOOP
		PERFORM im_menu__delete(row.menu_id);
	END LOOP;

	return 0;
end;' language 'plpgsql';
select inline_1 ();
drop function inline_1();


create or replace function inline_1 ()
returns integer as '
declare
        v_count                 integer;
        v_menu_id               integer;
        row                     RECORD;
begin
        FOR row IN
                select  *
                from    im_menus
                where   label like ''%cube%''
                        and package_name = ''intranet-reporting''
        LOOP
                PERFORM im_menu__delete(row.menu_id);
        END LOOP;

        return 0;
end;' language 'plpgsql';
select inline_1 ();
drop function inline_1();



-- Users-Contacts
--

create or replace function inline_0 ()
returns integer as '
declare
        -- Menu IDs
        v_menu                  integer;
        v_main_menu             integer;

        -- Groups
        v_employees             integer;
        v_accounting            integer;
        v_senman                integer;
        v_customers             integer;
        v_freelancers           integer;
        v_proman                integer;
        v_admins                integer;
        v_reg_users             integer;
BEGIN
        select group_id into v_admins from groups where group_name = ''P/O Admins'';
        select group_id into v_senman from groups where group_name = ''Senior Managers'';
        select group_id into v_proman from groups where group_name = ''Project Managers'';
        select group_id into v_accounting from groups where group_name = ''Accounting'';
        select group_id into v_employees from groups where group_name = ''Employees'';
        select group_id into v_customers from groups where group_name = ''Customers'';
        select group_id into v_freelancers from groups where group_name = ''Freelancers'';
        select group_id into v_reg_users from groups where group_name = ''Registered Users'';

        select menu_id into v_main_menu from im_menus where label=''reporting-other'';

        v_menu := im_menu__new (
                null,                                   -- p_menu_id
                ''im_menu'',                         -- object_type
                now(),                                  -- creation_date
                null,                                   -- creation_user
                null,                                   -- creation_ip
                null,                                   -- context_id
                ''intranet-reporting'',         -- package_name
                ''reporting-user-contacts'', -- label
                ''Users & Contact Information'', -- name
                ''/intranet-reporting/user-contacts'', -- url
                50,                                     -- sort_order
                v_main_menu,                            -- parent_menu_id
                null                                    -- p_visible_tcl
        );

        PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
        PERFORM acs_permission__grant_permission(v_menu, v_senman, ''read'');
        PERFORM acs_permission__grant_permission(v_menu, v_accounting, ''read'');

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

