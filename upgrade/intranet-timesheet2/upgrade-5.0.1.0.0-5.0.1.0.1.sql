-- upgrade-5.0.1.0.0-5.0.1.0.1.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-5.0.1.0.0-5.0.1.0.1.sql','');


create or replace function inline_0()
returns integer as $body$
DECLARE
	v_count		integer;
BEGIN
	select	count(*) into v_count from user_tab_columns
	where	lower(table_name) = 'im_hours' and lower(column_name) = 'creation_date';
	IF v_count > 0 THEN return 1; END IF;

	alter table im_hours add column creation_date timestamptz default now();

	return 0;
END;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();




SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-timesheet2',		-- package_name
		'timesheet_admin',		-- label
		'Timesheet Admin',		-- name
		'/intranet-timesheet2/hours/admin',
		900,				-- sort_order
		(select menu_id from im_menus where label = 'timesheet2_timesheet'),
		null
);


SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-timesheet2',		-- package_name
		'absences_admin',		-- label
		'Absences Admin',		-- name
		'/intranet-timesheet2/absences/admin',
		900,				-- sort_order
		(select menu_id from im_menus where label = 'timesheet2_absences'),
		null
);


update im_menus set url = '/intranet-timesheet2/hours/admin' where label = 'timesheet_admin';
update im_menus set url = '/intranet-timesheet2/absences/admin' where label = 'absences_admin';



-- Set default absence colors
update im_categories set aux_string2 = 'CCCCC9' where category_id = 5005; -- grey

