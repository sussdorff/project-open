-- upgrade-5.0.2.0.0-5.0.2.0.1.sql

SELECT acs_log__debug('/packages/intranet-csv-import/sql/postgresql/upgrade/upgrade-5.0.2.0.0-5.0.2.0.1.sql','');

CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS $BODY$
 
DECLARE
	v_admins		integer;
	v_csv_export_menu	integer;
	v_reporting_menu	integer;
	v_report_menu_id	integer;
BEGIN

	select group_id into v_admins from groups where group_name = 'P/O Admins';

	-- Create new Sub-Menu 'CSV-Export'
	select menu_id from im_menus where label = 'reporting' into v_reporting_menu;

	v_csv_export_menu := im_menu__new (
        null,                                           -- p_menu_id
        'im_menu',                                      -- object_type
        now(),                                          -- creation_date
        null,                                           -- creation_user
        null,                                           -- creation_ip
        null,                                           -- context_id
        'intranet-reporting',                           -- package_name
        'reporting-csv-export',                         -- label
        'CSV Export',                                   -- name
        '/intranet-reporting/',                         -- url
        1000,                                           -- sort_order
        v_reporting_menu,                               -- parent_menu_id
        null                                            -- p_visible_tcl
	);
	
	-- Make it available to SysAdmins only
	PERFORM acs_permission__grant_permission(v_csv_export_menu, v_admins, 'read');

	-- Export Persons
	v_report_menu_id := im_report_new (
        'Export Persons',		-- report_name
        'csv_export_persons',		-- report_code
        'intranet-csv-import',          -- package_key
        10,                             -- report_sort_order
        v_csv_export_menu,  		-- parent_menu_id
	'
        SELECT
            pa.email                         ,
            u.username                       ,
            pe.first_names                   ,
            pe.last_name                     ,
            uc.home_phone                    ,
            uc.work_phone                    ,
            uc.cell_phone                    ,
            uc.pager                         ,
            uc.fax                           ,
            uc.aim_screen_name               ,
            uc.icq_number                    ,
            uc.ha_line1                      ,
            uc.ha_line2                      ,
            uc.ha_city                       ,
            uc.ha_state                      ,
            uc.ha_postal_code                ,
            uc.ha_country_code               ,
            uc.wa_line1                      ,
            uc.wa_line2                      ,
            uc.wa_city                       ,
            uc.wa_state                      ,
            uc.wa_postal_code                ,
            uc.wa_country_code               ,
            uc.note                          ,
            (select email from parties where party_id=e.supervisor_id) as supervisor,
            e.availability                   ,
            e.personnel_number               ,
            e.ss_number                      ,
            to_char(e.hourly_cost,''9999.99''),
            e.salary                         ,
            e.social_security                ,
            e.insurance                      ,
            e.other_costs                    ,
            e.salary_payments_per_year       ,
            e.birthdate                      ,
            e.job_title                      ,
            e.job_description                ,
            e.voluntary_termination_p        ,
            e.termination_reason             ,
            e.signed_nda_p                   ,
            e.vacation_days_per_year         ,
            e.vacation_balance               ,
            im_profiles_from_user_id(u.user_id) as profiles
        FROM
            parties pa,
            persons pe,
            users u
                LEFT OUTER JOIN users_contact uc ON (u.user_id = uc.user_id)
                LEFT OUTER JOIN im_employees e ON (u.user_id = e.employee_id),
            group_member_map m,
            membership_rels mr
        WHERE
            pa.party_id = pe.person_id
            AND pe.person_id = u.user_id
            AND u.user_id = m.member_id
            AND m.group_id = acs__magic_object_id(''registered_users'')
            AND m.rel_id = mr.rel_id
            AND m.container_id = m.group_id
            AND m.rel_type = ''membership_rel''
	'
	);

	-- Make report available to SysAdmins only
	PERFORM acs_permission__grant_permission(v_report_menu_id, v_admins, 'read');


        -- Export Companies 
	-- This is a copy of ~/packages/intranet-dw-light/companies.csv 
        v_report_menu_id := im_report_new (
        'Export Companies',             -- report_name
        'csv_export_companies',         -- report_code
        'intranet-csv-import',          -- package_key
        20,                             -- report_sort_order
        v_csv_export_menu,              -- parent_menu_id
        '
        select
                c.*,
                im_name_from_id(primary_contact_id) as primary_contact_id_deref,
                im_name_from_id(accounting_contact_id) as accounting_contact_id_deref,
                im_name_from_id(default_bill_template_id) as default_bill_template_id_deref,
                im_name_from_id(default_delnote_template_id) as default_delnote_template_id_deref,
                im_name_from_id(default_invoice_template_id) as default_invoice_template_id_deref,
                im_integer_from_id(default_payment_days) as default_payment_days_deref,
                im_name_from_id(default_payment_method_id) as default_payment_method_id_deref,
                im_name_from_id(default_po_template_id) as default_po_template_id_deref,
                im_integer_from_id(default_vat) as default_vat_deref,
                im_name_from_id(note) as note_deref,
                im_numeric_from_id(default_surcharge_perc) as default_surcharge_perc_deref,
                im_numeric_from_id(default_discount_perc) as default_discount_perc_deref,
                im_numeric_from_id(default_tax) as default_tax_deref,
                im_name_from_id(referral_source) as referral_source_deref,
                im_name_from_id(vat_number) as vat_number_deref,
                im_numeric_from_id(default_pm_fee_perc) as default_pm_fee_perc_deref,
                c.note as company_note,
                o.*,
                c.primary_contact_id as company_contact_id,
                im_name_from_user_id(c.accounting_contact_id) as accounting_contact_name,
                im_email_from_user_id(c.accounting_contact_id) as accounting_contact_email,
                im_name_from_user_id(c.primary_contact_id) as company_contact_name,
                im_email_from_user_id(c.primary_contact_id) as company_contact_email,
                im_category_from_id(c.company_type_id) as company_type,
                im_category_from_id(c.company_status_id) as company_status,
                im_category_from_id(c.annual_revenue_id) as annual_revenue
        from
                (       select  office_id,
                                office_name,
                                office_path,
                                phone,
                                fax,
                                address_line1,
                                address_line2,
                                address_city,
                                address_state,
                                address_postal_code,
                                address_country_code,
                                contact_person_id
                        from    im_offices
                ) o,
                im_companies c
        where
                c.main_office_id = o.office_id
        '
        );

        -- Make report available to SysAdmins only
        PERFORM acs_permission__grant_permission(v_report_menu_id, v_admins, 'read');


        -- Export Projects
        v_report_menu_id := im_report_new (
        'Export Projects',               -- report_name
        'csv_export_projects',           -- report_code
        'intranet-csv-import',          -- package_key
        30,                             -- report_sort_order
        v_csv_export_menu,              -- parent_menu_id
        '
        select 
            (select project_nr from im_projects where project_id = child.parent_id) as parent_nrs, 
            child.project_nr,
            child.project_name,
            (select company_name from im_companies where company_id = child.company_id) as customer_name,
            (select email from parties where party_id = child.project_lead_id) as project_manager,
            im_category_from_id(child.project_status_id) as project_status,
            im_category_from_id(child.project_type_id) as project_type,
            child.start_date,
            child.end_date,
            child.percent_completed,
            child.project_budget,
            child.project_budget_hours,
            im_category_from_id(child.on_track_status_id) as on_track_status,
            child.release_item_p,
            child.milestone_p,
            (select project_nr from im_projects where project_id = child.program_id) as program_name,
            (select email from parties where party_id = child.corporate_sponsor) as corporate_sponsor,
            child.note,
            child.description
        from
            (select  p.* from im_projects p) parent,
            (select  p.* from im_projects p) child
                left outer join im_timesheet_tasks t on (t.task_id = child.project_id)
                left outer join im_gantt_projects gp on (gp.project_id = child.project_id)
                left outer join im_cost_centers cc on (t.cost_center_id = cc.cost_center_id)
        where
            child.tree_sortkey between parent.tree_sortkey and tree_right(parent.tree_sortkey)
            and child.project_status_id not in (82)
            and child.project_type_id <> 100
        order by
            child.tree_sortkey
        '
        );

        -- Make report available to SysAdmins only
        PERFORM acs_permission__grant_permission(v_report_menu_id, v_admins, 'read');


        -- Export Tasks
	v_report_menu_id := im_report_new (
        'Export Tasks',               -- report_name
        'csv_export_tasks',           -- report_code
        'intranet-csv-import',          -- package_key
        40,                             -- report_sort_order
        v_csv_export_menu,              -- parent_menu_id
        '
        select 
            (select project_nr from im_projects where project_id = child.parent_id) as parent_nrs, 
            child.project_nr,
            child.project_name,
            im_category_from_id(child.project_status_id) as project_status,
            im_category_from_id(child.project_type_id) as project_type,
            child.start_date,
            child.end_date,
            child.percent_completed,
            child.release_item_p,
            child.milestone_p,
            child.note,
            child.description,
            (select material_name from im_materials where material_id = t.material_id) as material,
            (select category from im_categories where category_id = t.uom_id) as uom,
            planned_units,
            billable_units,
            (select cost_center_name from im_cost_centers where cost_center_id = t.cost_center_id) as cost_center,
            invoice_id,
            priority,
            t.sort_order,
            gantt_project_id,
            scheduling_constraint_id,
            scheduling_constraint_date,
            effort_driven_type_id,
            deadline_date,
            effort_driven_p
        from
            (select  p.* from im_projects p) parent,
            (select  p.* from im_projects p) child
                left outer join im_timesheet_tasks t on (t.task_id = child.project_id)
                left outer join im_gantt_projects gp on (gp.project_id = child.project_id)
                left outer join im_cost_centers cc on (t.cost_center_id = cc.cost_center_id)
        where
            child.tree_sortkey between parent.tree_sortkey and tree_right(parent.tree_sortkey)
            and child.project_status_id not in (82)
            and child.project_type_id = 100
        order by
            child.tree_sortkey
        '
        );

        -- Make report available to SysAdmins only
        PERFORM acs_permission__grant_permission(v_report_menu_id, v_admins, 'read');


        -- Export Project-Task Relationships
        v_report_menu_id := im_report_new (
        'Export Project-Task Relationships',               -- report_name
        'csv_export_project_task_relationships',           -- report_code
        'intranet-csv-import',          -- package_key
        50,                             -- report_sort_order
        v_csv_export_menu,              -- parent_menu_id
        '
        select  
            ''person'' as object_type_one, 
            (select email from parties where party_id = r.object_id_two) as object_id_one,   
            ''im_project'' as object_type_two, 
            (select im_project_nr_parent_list(r.object_id_one)) as object_id_two,
            (select category from im_categories where category_id = bom.object_role_id) as role_id,
            bom.percentage
        from    
                acs_rels r,
                im_biz_object_members bom
        where   
                r.rel_id = bom.rel_id and
                r.object_id_one in (select project_id from im_projects where project_status_id <> 82)        
	'
        );

        -- Make report available to SysAdmins only
        PERFORM acs_permission__grant_permission(v_report_menu_id, v_admins, 'read');


        -- Export Finance Documents
        v_report_menu_id := im_report_new (
        'Export Finance Documents',     -- report_name
        'csv_export_fin_docs',          -- report_code
        'intranet-csv-import',          -- package_key
        60,                             -- report_sort_order
        v_csv_export_menu,              -- parent_menu_id
        '
        select
            -- INVOICES 
            (select email from parties where party_id = i.company_contact_id) as company_contact,
            (select category from im_categories where category_id = i.payment_method_id ) payment_method,
            reference_document_id,
            (select office_path from im_offices where office_id = i.invoice_office_id) as office,
            i.discount_perc,
            i.discount_text,
            i.surcharge_perc,
            i.surcharge_text,
            i.deadline_start_date,
            i.deadline_interval,     
            -- COST
            (select company_path from im_companies where company_id = c.customer_id) as customer,
            (select company_path from im_companies where company_id = c.provider_id) as provider,    
            c.cost_name || ''s'' as cost_name, 
            c.cost_nr ,   
            (select cost_center_name from im_cost_centers where cost_center_id = c.cost_center_id ) as cost_center,   
            (select category from im_categories where category_id = c.cost_status_id) as cost_status,  
            (select category from im_categories where category_id = c.cost_type_id) as cost_type, 
            (select category from im_categories where category_id = c.cost_status_id) as cost_status,
            (select category from im_categories where category_id = c.template_id) as cost_template,
            c.effective_date,
            c.payment_days,
            c.currency,
            CASE c.vat = 0
                  WHEN true THEN ''''
                  ELSE to_char(c.vat,''99.99'')
            END as vat,
            CASE c.tax = 0
                  WHEN true THEN ''''
                  ELSE to_char(c.tax,''99.99'')
            END as tax,
            c.note,
            (select im_project_nr_parent_list(c.project_id)) as project
         from   
            im_invoices i, 
            im_costs c
         where 
            i.invoice_id = c.cost_id
         order by 
            c.cost_id DESC
        '
        );

        -- Make report available to SysAdmins only
        PERFORM acs_permission__grant_permission(v_report_menu_id, v_admins, 'read');


        -- Export Invoice Items
        v_report_menu_id := im_report_new (
        'Export Invoice Items',         -- report_name
        'csv_export_invoice_items',     -- report_code
        'intranet-csv-import',          -- package_key
        70,                             -- report_sort_order
        v_csv_export_menu,              -- parent_menu_id
        '
        select
            -- INVOICE ITEMS 
            item_name,
            (select project_nr from im_projects where project_id = ii.project_id) as project_id,
            (select invoice_nr from im_invoices where invoice_id = ii.invoice_id) || ''s'' as invoice_nr,
            item_units,
            (select category from im_categories where category_id = ii.item_uom_id) as item_uom,
            price_per_unit,
            currency,
            sort_order,
            item_type_id,
            item_status_id,
            description,
            (select material_name from im_materials where material_id = ii.item_material_id) as item_material,
            (select im_project_nr_parent_list(ii.task_id)) as task,
            -- created_from_item_id,
            -- item_source_invoice_id,
            -- INVOICES 
            (select email from parties where party_id in ((select company_contact_id from im_invoices where invoice_id = ii.invoice_id)) ) as company_contact,
            (select category from im_categories where category_id in ((select payment_method_id from im_invoices where invoice_id = ii.invoice_id))) payment_method,
            -- reference_document_id,
            (select office_path from im_offices where office_id in((select invoice_office_id from im_invoices where invoice_id = ii.invoice_id))) as office,
            (select discount_perc       from im_invoices where invoice_id = ii.invoice_id) as discount_perc,
            (select discount_text       from im_invoices where invoice_id = ii.invoice_id) as discount_text,
            (select surcharge_perc      from im_invoices where invoice_id = ii.invoice_id) as surcharge_perc,
            (select surcharge_text      from im_invoices where invoice_id = ii.invoice_id) as surcharge_text,
            (select deadline_start_date from im_invoices where invoice_id = ii.invoice_id) as deadline_start_date,
            (select deadline_interval   from im_invoices where invoice_id = ii.invoice_id) as deadline_interval,     
            -- COST
            (select cost_name           from im_costs where cost_id = ii.invoice_id) || ''s'' as cost_name, 
            (select cost_nr             from im_costs where cost_id = ii.invoice_id) as cost_nr,   
            (select cost_center_name from im_cost_centers where cost_center_id in (select cost_center_id from im_costs where cost_id = ii.invoice_id)) as cost_center,   
            (select category from im_categories where category_id in (select cost_status_id from im_costs where cost_id = ii.invoice_id)) as cost_status_id,  
            (select category from im_categories where category_id in (select cost_type_id from im_costs where cost_id = ii.invoice_id)) as cost_type_id 
        from   
            im_invoice_items ii
        '
        );

        -- Make report available to SysAdmins only
        PERFORM acs_permission__grant_permission(v_report_menu_id, v_admins, 'read');


        -- Export Expense Bundles
        v_report_menu_id := im_report_new (
        'Export Expense Bundles',      	-- report_name
        'csv_export_expense_bundles',  	-- report_code
        'intranet-csv-import',          -- package_key
        80,                             -- report_sort_order
        v_csv_export_menu,              -- parent_menu_id
        '
        select 
            c.cost_name as expense_name, 
            c.effective_date as expense_date,
            c.currency as expense_currency, 
            (select im_project_nr_parent_list(c.project_id)) as parent_nrs,
            (select category from im_categories where category_id = c.cost_status_id) as cost_status,
            (select category from im_categories where category_id = c.cost_type_id) as cost_type,
            CASE c.amount = 0
                  WHEN true THEN ''0.00''
                  ELSE trim(to_char(c.amount,''999999999.99''))
            END as amount,
            CASE c.vat = 0
                  WHEN true THEN ''0.00''
                  ELSE trim(to_char(c.vat,''99.99''))
            END as vat,
            c.note,
            (select company_path from im_companies where company_id = c.customer_id) as customer, 
            (select company_path from im_companies where company_id = c.provider_id) as provider,
            c.cost_id as bundle_id_old
        from 
            acs_objects o, 
            im_costs c
        where 
            c.cost_id = o.object_id 
            and o.object_type = ''im_expense_bundle''
        ;        '
        );

        -- Make report available to SysAdmins only
        PERFORM acs_permission__grant_permission(v_report_menu_id, v_admins, 'read');


        -- Export Expense Items
        v_report_menu_id := im_report_new (
        'Export Expense Items',		-- report_name
        'csv_export_expense_items',     -- report_code
        'intranet-csv-import',          -- package_key
        90,                             -- report_sort_order
        v_csv_export_menu,              -- parent_menu_id
        '
        select 
            c.cost_name as expense_name, 
            c.effective_date as expense_date,
            c.currency as expense_currency, 
            (select category from im_categories where category_id = c.cost_status_id) as cost_status,
            (select category from im_categories where category_id = c.cost_type_id) as cost_type,    
            CASE c.amount = 0
                  WHEN true THEN ''0.00''
                  ELSE trim(to_char(c.amount,''999999999.99''))
            END as amount,
            CASE c.vat = 0
                  WHEN true THEN ''0.00''
                  ELSE trim(to_char(c.vat,''99.99''))
            END as vat,
            (select project_nr from im_projects where project_id = c.project_id) as project_nr,
            c.note,
            e.external_company_name,
            e.external_company_vat_number,
            e.receipt_reference,
            (select category from im_categories where category_id = e.expense_type_id) as expense_type,
            e.billable_p,
            CASE e.reimbursable = 0
                  WHEN true THEN ''0.00''
                  ELSE trim(to_char(e.reimbursable,''999.99''))
            END as reimbursable,
            (select category from im_categories where category_id = e.expense_payment_type_id) as expense_payment_type,
            (select company_path from im_companies where company_id = c.customer_id) as customer, 
            -- (select company_path from im_companies where company_id = c.provider_id) as provider,
            (select email from parties where party_id = c.provider_id) as provider,
            e.bundle_id as bundle_id_old
        from 
            im_expenses e, 
            im_costs c 
        where 
            c.cost_id = e.expense_id
        '
        );

        -- Make report available to SysAdmins only
        PERFORM acs_permission__grant_permission(v_report_menu_id, v_admins, 'read');


        -- Export Hours
        v_report_menu_id := im_report_new (
        'Export Hours',               -- report_name
        'csv_export_hours',           -- report_code
        'intranet-csv-import',        -- package_key
        100,                          -- report_sort_order
        v_csv_export_menu,            -- parent_menu_id
        '
        select
                (select email from parties where party_id = h.user_id) as user_id,
                (select im_project_nr_parent_list(h.project_id)) as project_id,
                day,
                hours,
                billing_rate,
                billing_currency,
                note,
                (select category from im_categories where category_id = h.cost_id) as cost_type,
                (select invoice_nr from im_invoices where invoice_id = h.invoice_id) as invoice_nr,
                internal_note,
                (select material_name from im_materials where material_id = h.material_id) as material,
                days
        from
                im_hours h
        '
        );

        -- Make report available to SysAdmins only
        PERFORM acs_permission__grant_permission(v_report_menu_id, v_admins, 'read');

        RETURN 1;
 
END;$BODY$ LANGUAGE 'plpgsql';
 
SELECT inline_0 ();
DROP FUNCTION inline_0 ();








