-- upgrade-5.0.2.3.5-5.0.2.3.6.sql
SELECT acs_log__debug('/packages/intranet-crm-opportunities/sql/postgresql/upgrade/upgrade-5.0.2.3.5-5.0.2.3.6.sql','');


update im_component_plugins set component_tcl = '
	im_dashboard_histogram_sql -diagram_width 300 -sql "
		select  im_lang_lookup_category(''[ad_conn locale]'', p.opportunity_sales_stage_id) as project_status,
			round(sum(coalesce(presales_probability,0) * coalesce(presales_value,project_budget,0)) / 100.0 / 1000.0) as value,
			(select sort_order from im_categories where category_id = p.opportunity_sales_stage_id) as sort_order
		from	im_projects p
		where   p.parent_id is null and
			p.opportunity_sales_stage_id not in (select * from im_sub_categories(84018)) and
			p.project_type_id in (select * from im_sub_categories(102)) and
			(1 = [im_permission [auth::require_login] view_projects_all] OR
			p.project_id in (select r.object_id_one from acs_rels r where r.object_id_two = [auth::require_login])
			)
		group by opportunity_sales_stage_id
		order by
			sort_order,
			p.opportunity_sales_stage_id
	"' 
where plugin_name = 'Sales Pipeline by Volume' and package_name = 'intranet-crm-opportunities'; 


update im_component_plugins
set component_tcl =
        'im_dashboard_histogram_sql -diagram_width 300 -sql "
                select  im_lang_lookup_category(''[ad_conn locale]'', p.opportunity_sales_stage_id) as project_status,
                        count(*) as cnt,
                        (select sort_order from im_categories where category_id = p.opportunity_sales_stage_id) as sort_order
                from    im_projects p
                where   p.parent_id is null and
                        p.opportunity_sales_stage_id not in (select * from im_sub_categories(84018)) and
                        p.project_type_id in (select * from im_sub_categories(102)) and
			(1 = [im_permission [auth::require_login] view_projects_all] OR
			p.project_id in (select r.object_id_one from acs_rels r where r.object_id_two = [auth::require_login])
			)
                group by opportunity_sales_stage_id
                order by sort_order, p.opportunity_sales_stage_id
        "'
where package_name = 'intranet-crm-opportunities' and plugin_name ='Sales Pipeline by Number';



update im_component_plugins
set component_tcl =
	'im_ad_hoc_query -format html -package_key intranet-crm-opportunities "
		select	''<a href=/intranet/companies/view?company_id='' || cust.company_id || ''>'' || cust.company_name || ''</a>'' as company,
			''<a href=/intranet/projects/view?project_id='' || p.project_id || ''>'' || p.project_name || ''</a>'' as opportunity,
			''<div align=right>''||round(p.presales_value) || '' [im_default_currency]</div>'' as presales_value,
			''<div align=right>''||round(p.presales_probability) || ''%</div>'' as presales_probability,
			''<div align=right>''||round(p.presales_value * p.presales_probability / 100.0)||'' [im_default_currency]</div>'' as weighted_value
		from	im_projects p,
			im_companies cust
		where	p.parent_id is null and
			p.company_id = cust.company_id and
			p.opportunity_sales_stage_id not in (select * from im_sub_categories(84018)) and
			p.project_type_id in (select * from im_sub_categories(102)) and
			(1 = [im_permission [auth::require_login] view_projects_all] OR
			p.project_id in (select r.object_id_one from acs_rels r where r.object_id_two = [auth::require_login])
			)
		order by weighted_value DESC
		limit 10
	"'
where package_name = 'intranet-crm-opportunities' and plugin_name ='Top 10 Opportunities';
