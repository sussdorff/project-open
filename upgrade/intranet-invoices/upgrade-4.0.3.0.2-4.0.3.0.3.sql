-- upgrade-4.0.3.0.2-4.0.3.0.3.sql

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.0.3.0.2-4.0.3.0.3.sql','');


SELECT  im_component_plugin__new (
        null,                           		-- plugin_id
        'acs_object',                			-- object_type
        now(),                        			-- creation_date
        null,                           		-- creation_user
        null,                           		-- creation_ip
        null,                           		-- context_id
        'Filestorage Financial Document', 		-- plugin_name
        'intranet-invoices',            		-- package_name
        'right',                        		-- location
        '/intranet-invoices/view',      		-- page_url
        null,                           		-- view_name
        5,                              		-- sort_order
        'im_filestorage_cost_component $user_id $invoice_id $invoice_id $return_url'  	-- component_tcl
);


create or replace function inline_0 () returns integer as $body$
        DECLARE
                v_plugin_id     integer;
		v_employees	integer;
        BEGIN

	select  plugin_id
        into    v_plugin_id
        from    im_component_plugins pl
        where   plugin_name = 'Filestorage Financial Document';

	select group_id into v_employees from groups where group_name = 'Employees';
 
        PERFORM im_grant_permission(v_plugin_id, v_employees, 'read');

	return 1; 
		
        END;
$body$ language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();
