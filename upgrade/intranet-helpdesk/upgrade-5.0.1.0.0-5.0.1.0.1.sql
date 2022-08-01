-- upgrade-5.0.1.0.0-5.0.1.0.1.sql

SELECT acs_log__debug('/packages/intranet-helpdesk/sql/postgresql/upgrade/upgrade-5.0.1.0.0-5.0.1.0.1.sql','');


update im_categories
set category = 'Ticket Container'
where category_id = 2502;





SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',		-- package_name
		'helpdesk_admin',		-- label
		'Helpdesk Admin',		-- name
		'/intranet/admin/object-type-admin?object_type=im_ticket',
		900,				-- sort_order
		(select menu_id from im_menus where label = 'helpdesk'),
		null
);


create or replace function inline_1 ()
returns integer as $body$
declare
	v_menu			integer;
	v_ticket_menu		integer;
	v_employees		integer;
begin
	select group_id into v_employees from groups where group_name = 'Employees';
	select menu_id into v_ticket_menu from im_menus where label='helpdesk';

	v_menu := im_menu__new (
		null,				-- p_menu_id
		'im_menu',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		'intranet-core',		-- package_name
		'ticket_add',			-- label
		'New Ticket',			-- name
		'/intranet-helpdesk/new',	-- url
		10,				-- sort_order
		v_ticket_menu,			-- parent_menu_id
		'[im_permission $user_id "add_tickets"]'	-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');
	return 0;
end;$body$ language 'plpgsql';
select inline_1 ();
drop function inline_1();




update im_menus set url = '/intranet-helpdesk/new' where url = '/intranet/tickets/new';
