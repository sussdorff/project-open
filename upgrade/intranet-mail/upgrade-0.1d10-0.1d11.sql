-- /packages/intranet-mail/sql/postgresql/upgrade/upgrade-0.1d10-0.1d11.sql

SELECT acs_log__debug('/packages/intranet-mail/sql/postgresql/upgrade/upgrade-0.1d10-0.1d11.sql','');

CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE

	v_object_id	integer;
	v_employees	integer;
	v_poadmins	integer;

BEGIN
	SELECT group_id INTO v_employees FROM groups where group_name = ''P/O Admins'';

	SELECT group_id INTO v_poadmins FROM groups where group_name = ''Employees'';

	-- Intranet Mail Project Component
	SELECT plugin_id INTO v_object_id FROM im_component_plugins WHERE plugin_name = ''Intranet Mail Project Component'' AND page_url = ''/intranet/projects/view'';

	PERFORM im_grant_permission(v_object_id,v_employees,''read'');
	PERFORM im_grant_permission(v_object_id,v_poadmins,''read'');



	-- Intranet Mail Task Component
	SELECT plugin_id INTO v_object_id FROM im_component_plugins WHERE plugin_name = ''Intranet Mail Task Component'' AND page_url = ''/intranet-cognovis/tasks/view'';

	PERFORM im_grant_permission(v_object_id,v_employees,''read'');
	PERFORM im_grant_permission(v_object_id,v_poadmins,''read'');
	
	RETURN 0;

END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();
