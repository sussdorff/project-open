-- upgrade-4.0.3.3.2-4.0.3.3.3.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-4.0.3.3.2-4.0.3.3.3.sql','');


-- Activate the new finance indicator page
update im_menus
set url = '/intranet-cost/index'
where label = 'finance';



update im_component_plugins set component_tcl = '
im_ad_hoc_query -format html -package_key intranet-cost "
select	''<a href=/intranet-invoices/view?invoice_id='' || c.cost_id || ''>'' || c.cost_name || ''</a>'' as document_nr,
	''<a href=/intranet-cost/cost-centers/new?cost_center_id='' || c.cost_center_id || ''>'' || im_cost_center_code_from_id(c.cost_center_id) || ''</a>'' as cost_center,
	''<a href=/intranet/companies/view?company_id='' || c.customer_id || ''>'' || im_company__name(c.customer_id) || ''</a>'' as customer_name,
	c.effective_date::date + c.payment_days as due_date,
	c.amount::text || '' '' || c.currency as amount,
	c.paid_amount::text || '' '' || c.paid_currency as paid_amount
from	im_costs c
where	c.cost_type_id = 3700 and
	c.cost_status_id not in (3810, 3814, 3816, 3818)
order by coalesce(c.amount,0) DESC
limit 10
"'
where plugin_name = 'Top 10 Unpaid Customer Invoices';




update im_component_plugins set component_tcl = '
im_ad_hoc_query -format html -package_key intranet-cost "
select
	''<a href=/intranet-invoices/view?invoice_id='' || c.cost_id || ''>'' || c.cost_name || ''</a>'' as document_nr,
	''<a href=/intranet-cost/cost-centers/new?cost_center_id='' || c.cost_center_id || ''>'' || im_cost_center_code_from_id(c.cost_center_id) || ''</a>'' as cost_center,
	''<a href=/intranet/companies/view?company_id='' || c.provider_id || ''>'' || im_company__name(c.provider_id) || ''</a>'' as provider_name,
	c.effective_date::date + c.payment_days as due_date,
	c.amount::text || '' '' || c.currency as amount,
	c.paid_amount::text || '' '' || c.paid_currency as paid_amount
from	im_costs c
where	c.cost_type_id = 3704 and
	c.cost_status_id not in (3810, 3814, 3816, 3818)
order by coalesce(c.amount,0) DESC
limit 10
"'
where plugin_name = 'Top 10 Unpaid Provider Bills';

