-- upgrade-5.0.2.4.0-5.0.2.4.1.sql

SELECT acs_log__debug('/packages/intranet-csv-import/sql/postgresql/upgrade/upgrade-5.0.2.4.0-5.0.2.4.1.sql','');


-- A report that shows activities per day
SELECT im_report_new (
	'Export Tickets',					-- report_name
	'csv_export_tickets',					-- report_code
	'intranet-csv-import',							-- package_key
	100,									-- report_sort_order
	(select menu_id from im_menus where label = 'reporting-csv-export'),	-- parent_menu_id
	'dummy - will be replaced below'    	    				-- SQL to execute
);

update im_menus 
set parent_menu_id = (select menu_id from im_menus where label = 'reporting-csv-export')
where name = 'Export Tickets';

update im_reports 
set report_sql = '
        select 
            p_sla.project_nr as sla, 
            p_ticket.project_nr as ticket_nr,
            p_ticket.project_name as ticket_name,
            im_category_from_id(t.ticket_status_id) as ticket_status,
            im_category_from_id(t.ticket_type_id) as ticket_type,
            im_category_from_id(t.ticket_prio_id) as ticket_prio,
            im_email_from_user_id(t.ticket_customer_contact_id) as customer_contact,
            im_email_from_user_id(t.ticket_assignee_id) as assignee,
            p_ticket.start_date::date as date,
            im_conf_item_nr_from_id(t.ticket_conf_item_id) as conf_item_nr,
            acs_object__name(t.ticket_queue_id) as ticket_queue,
            coalesce(p_ticket.note, '') || coalesce(t.ticket_note,'') as note,
            coalesce(p_ticket.description, '') || coalesce(t.ticket_description, '') as description,
            im_cost_center_code_from_id(t.ticket_dept_id) as department
        from
            im_projects p_sla,
            im_projects p_ticket,
            im_tickets t
        where
            p_sla.project_id = p_ticket.parent_id and
            p_ticket.project_id = t.ticket_id
        order by t.ticket_id
'
where report_code = 'csv_export_tickets';


