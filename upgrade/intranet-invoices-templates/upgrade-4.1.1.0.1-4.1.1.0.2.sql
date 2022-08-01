-- upgrade-4.1.1.0.1-4.1.1.0.2.sql

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.1.1.0.1-4.1.1.0.2.sql','');


SELECT  im_component_plugin__new (
        null,                           		-- plugin_id
        'acs_object',                			-- object_type
        now(),                        			-- creation_date
        null,                           		-- creation_user
        null,                           		-- creation_ip
        null,                           		-- context_id
        'Financial Mails', 		-- plugin_name
        'intranet-invoices',            		-- package_name
        'left',                        		-- location
        '/intranet-invoices/view',      		-- page_url
        null,                           		-- view_name
        5,                              		-- sort_order
        'im_mail_object_component -context_id $invoice_id -return_url $return_url'  	-- component_tcl
);


create or replace function inline_0 () returns integer as $body$
        DECLARE
                v_plugin_id     integer;
		v_employees	integer;
        BEGIN

	select  plugin_id
        into    v_plugin_id
        from    im_component_plugins pl
        where   plugin_name = 'Financial Mails';

	select group_id into v_employees from groups where group_name = 'Employees';
 
        PERFORM im_grant_permission(v_plugin_id, v_employees, 'read');

	return 1; 
		
        END;
$body$ language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();
