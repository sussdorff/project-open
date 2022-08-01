-- upgrade-5.0.1.0.0-5.0.1.0.1.sql
SELECT acs_log__debug('/packages/intranet-crm-opportunities/sql/postgresql/upgrade/upgrade-5.0.1.0.0-5.0.1.0.1.sql','');

update im_component_plugins set component_tcl = '
	im_dashboard_histogram_sql -diagram_width 300 -sql "
		select  im_category_from_id(p.opportunity_sales_stage_id) as project_status,
			round(sum(coalesce(presales_probability,0) * coalesce(presales_value,project_budget,0)) / 100.0 / 1000.0) as value,
			(select sort_order from im_categories where category_id = p.opportunity_sales_stage_id) as sort_order
		from	im_projects p
		where   p.parent_id is null
			and p.project_status_id not in (select * from im_sub_categories(84018))
			and project_type_id = 102
		group by opportunity_sales_stage_id
		order by
			sort_order,
			p.opportunity_sales_stage_id
	"
' 
where plugin_name = 'Sales Pipeline by Volume' and package_name = 'intranet-crm-opportunities'; 

update lang_messages 
set message = 'Opportunities by Volume (thousands)'
where message = 'Opportunities by Volume';



update im_component_plugins set component_tcl = '
	im_dashboard_histogram_sql -diagram_width 300 -sql "
		select  im_category_from_id(p.opportunity_sales_stage_id) as project_status,
			count(*) as cnt,
			(select sort_order from im_categories where category_id = p.opportunity_sales_stage_id) as sort_order
		from	im_projects p
		where   p.parent_id is null
			and p.project_status_id not in (select * from im_sub_categories(84018))
			and project_type_id = 102
		group by opportunity_sales_stage_id
		order by 
			sort_order, 
			p.opportunity_sales_stage_id
	"
'
where plugin_name = 'Sales Pipeline by Number' and package_name = 'intranet-crm-opportunities';



update im_component_plugins set component_tcl = '
	im_ad_hoc_query -format html -package_key intranet-crm-opportunities "
		select
			''<a href=/intranet/companies/view?company_id='' || cust.company_id || ''>'' || cust.company_name || ''</a>'' as company,
			''<a href=/intranet/projects/view?project_id='' || p.project_id || ''>'' || p.project_name || ''</a>'' as opportunity,
			p.presales_value,
			p.presales_probability,
			round(p.presales_value * p.presales_probability / 100.0) as weighted_value
		from	im_projects p,
			im_companies cust
		where	p.parent_id is null and
			p.project_type_id = 102 and
			p.company_id = cust.company_id
		order by weighted_value DESC
		limit 10
"'
where plugin_name = 'Top 10 Opportunities' and package_name = 'intranet-crm-opportunities';






SELECT im_menu__new (
		null, 'im_menu', now(), null, null, null,
		'intranet-core',		-- package_name
		'crm_admin',			-- label
		'CRM Admin',			-- name
		'/intranet-crm-opportunities/admin',
		900,				-- sort_order
		(select menu_id from im_menus where label = 'crm'),
		null
);


create or replace function inline_1 ()
returns integer as $body$
declare
	v_menu			integer;
	v_crm_menu		integer;
	v_employees		integer;
begin
	select group_id into v_employees from groups where group_name = 'Employees';
	select menu_id into v_crm_menu from im_menus where label='crm';

	v_menu := im_menu__new (
		null,				-- p_menu_id
		'im_menu',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		'intranet-crm-opportunities',	-- package_name
		'add_opportunity',		-- label
		'New Opportunity',		-- name
		'/intranet-crm-opportunities/new',		-- url
		10,				-- sort_order
		v_crm_menu,			-- parent_menu_id
		'[im_permission $user_id "add_projects"]'	-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');
	return 0;
end;$body$ language 'plpgsql';
select inline_1 ();
drop function inline_1();


SELECT im_component_plugin__new (
	null,						-- plugin_id
	'im_component_plugin',				-- object_type
	now(),						-- creation_date
	null,						-- creation_user
	null,						-- creation_ip
	null,						-- context_id
	'Sales Pipeline - Volume vs. Probability',	-- plugin_name
	'intranet-crm-opportunities',			-- package_name
	'left',						-- location
	'/intranet-crm-opportunities/index',		-- page_url
	null,						-- view_name
	200,						-- sort_order
	'im_opportunity_pipeline -diagram_width 600 -diagram_height 600',
	'lang::message::lookup "" intranet-crm-opportunities.Sales_Pipeline_Volume_vs_Probability "Sales Pipeline - Volume vs. Probability"'
);

SELECT acs_permission__grant_permission(
        (select plugin_id from im_component_plugins where plugin_name = 'Sales Pipeline - Volume vs. Probability' and package_name = 'intranet-crm-opportunities'),
        (select group_id from groups where group_name = 'Employees'),
        'read'
);



