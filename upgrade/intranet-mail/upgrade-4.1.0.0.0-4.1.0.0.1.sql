-- /packages/intranet-mail/sql/postgresql/upgrade/upgrade-0.1d11-0.1d12.sql

SELECT acs_log__debug('/packages/intranet-mail/sql/postgresql/upgrade/upgrade-4.1.0.0.0-4.1.0.0.1.sql','');

-- Component for users
SELECT im_component_plugin__new (
        null,                           -- plugin_id
        'acs_object',                   -- object_type
        now(),                          -- creation_date
        null,                           -- creation_user
        null,                           -- creation_ip
        null,                           -- context_id
        'Intranet Mail User Component',        -- plugin_name
        'intranet-mail',                  -- package_name
        'right',                        -- location
        '/intranet/users/view',      -- page_url
        null,                           -- view_name
        12,                             -- sort_order
        'im_mail_object_component -party_id $user_id -return_url $return_url'
);




CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE

	v_object_id	integer;
	v_employees	integer;
	v_poadmins	integer;

BEGIN
	SELECT group_id INTO v_employees FROM groups where group_name = ''P/O Admins'';

	SELECT group_id INTO v_poadmins FROM groups where group_name = ''Employees'';


	-- Intranet Mail Ticket Component
	SELECT plugin_id INTO v_object_id FROM im_component_plugins WHERE plugin_name = ''Intranet Mail User Component'' AND page_url = ''/intranet/users/view'';

	PERFORM im_grant_permission(v_object_id,v_employees,''read'');
	PERFORM im_grant_permission(v_object_id,v_poadmins,''read'');
	
	RETURN 0;

END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();

SELECT im_component_plugin__new (
        null,                           -- plugin_id
        'acs_object',                   -- object_type
        now(),                          -- creation_date
        null,                           -- creation_user
        null,                           -- creation_ip
        null,                           -- context_id
        'Intranet Mail Company Component',        -- plugin_name
        'intranet-mail',                  -- package_name
        'right',                        -- location
        '/intranet/companies/view',      -- page_url
        null,                           -- view_name
        12,                             -- sort_order
        'im_mail_object_component -recipient_id $company_id -return_url $return_url'
);




CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE

    v_object_id	integer;
    v_employees	integer;
    v_poadmins	integer;

BEGIN
    SELECT group_id INTO v_employees FROM groups where group_name = ''P/O Admins'';

    SELECT group_id INTO v_poadmins FROM groups where group_name = ''Employees'';


    -- Intranet Mail Ticket Component
    SELECT plugin_id INTO v_object_id FROM im_component_plugins WHERE plugin_name = ''Intranet Mail Company Component'' AND page_url = ''/intranet/companies/view'';

    PERFORM im_grant_permission(v_object_id,v_employees,''read'');
    PERFORM im_grant_permission(v_object_id,v_poadmins,''read'');

    RETURN 0;

END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();