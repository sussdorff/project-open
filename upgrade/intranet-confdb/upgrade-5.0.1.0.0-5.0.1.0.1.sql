-- upgrade-5.0.1.0.0-5.0.1.0.1.sql

SELECT acs_log__debug('/packages/intranet-confdb/sql/postgresql/upgrade/upgrade-5.0.1.0.0-5.0.1.0.1.sql','');


CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS $BODY$
declare
        v_count                 integer;
begin
	select count(*) into v_count from pg_class where relname = 'im_conf_item_code_seq';
        IF v_count > 0 THEN return 1; END IF;
	CREATE SEQUENCE im_conf_item_code_seq START 10001;
        return 0;
end;$BODY$ LANGUAGE 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();


SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-confdb',		-- package_name
		'conf_items_admin',		-- label
		'Conf Items Admin',		-- name
		'/intranet/admin/object-type-admin?object_type=im_conf_item',
		900,				-- sort_order
		(select menu_id from im_menus where label = 'conf_items'),
		null
);



create or replace function inline_1 ()
returns integer as $body$
declare
	v_menu			integer;
	v_conf_item_menu		integer;
	v_employees		integer;
begin
	select group_id into v_employees from groups where group_name = 'Employees';
	select menu_id into v_conf_item_menu from im_menus where label='conf_items';

	v_menu := im_menu__new (
		null,				-- p_menu_id
		'im_menu',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		'intranet-confdb',		-- package_name
		'conf_item_add',		-- label
		'New Conf Item',		-- name
		'/intranet-confdb/new',		-- url
		10,				-- sort_order
		v_conf_item_menu,		-- parent_menu_id
		'[im_permission $user_id "add_conf_items"]'	-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');
	return 0;
end;$body$ language 'plpgsql';
select inline_1 ();
drop function inline_1();





update im_menus 
set parent_menu_id = (select menu_id from im_menus where label = 'conf_items_admin') 
where label in (
      	'conf_item_csv_export',
      	'conf_item_csv_import',
      	'nagios',
      	'nagios_import_conf'
);
