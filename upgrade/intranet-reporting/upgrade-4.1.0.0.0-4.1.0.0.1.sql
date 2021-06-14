-- upgrade-4.1.0.0.0-4.1.0.0.1.sql

SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-4.1.0.0.0-4.1.0.0.1.sql','');


-- Delete all reports of a module. Used in <module-name>-drop.sql
-- Needs to be executed before im_menu__del_module because it 
-- relies on the im_menu.package_name field.
create or replace function im_report__del_module (varchar) 
returns integer as $body$
DECLARE
	p_module_name		alias for $1;
	row			RECORD;
	v_count			integer;
BEGIN
	v_count := 0;
	FOR row IN
		select	menu_id,
			report_id
		from	im_menus m,
			im_reports r
		where	r.report_menu_id = m.menu_id and
			m.package_name = p_module_name
	LOOP
		PERFORM im_report__delete(row.report_id);
		PERFORM im_menu__delete(row.menu_id);
		v_count := v_count + 1;
	END LOOP;

	return v_count;
end;$body$ language 'plpgsql';

