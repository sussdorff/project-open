-- upgrade-5.0.2.3.6-5.0.2.3.7.sql
SELECT acs_log__debug('/packages/intranet-crm-opportunities/sql/postgresql/upgrade/upgrade-5.0.2.3.6-5.0.2.3.7.sql','');

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
