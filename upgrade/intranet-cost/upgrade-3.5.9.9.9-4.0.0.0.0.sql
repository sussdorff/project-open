-- upgrade-3.5.9.9.9-4.0.0.0.0.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-3.5.9.9.9-4.0.0.0.0.sql','');



SELECT im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',			-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'Top 10 Unpaid Customer Invoices',	-- plugin_name - shown in menu
	'intranet-cost',			-- package_name
	'left',					-- location
	'/intranet-cost/index',			-- page_url
	null,					-- view_name
	10,					-- sort_order
	'im_ad_hoc_query -format html -package_key intranet-cost "
select
	''<a href=/intranet-invoices/view?invoice_id='' || c.cost_id || ''>'' || c.cost_name || ''</a>'' as document_nr
	im_cost_center_code_from_id(c.cost_center_id) as cost_center,
	''<a href=/intranet/companies/view?company_id='' || c.customer_id || ''>'' || im_company__name(c.customer_id) || ''</a>'' as customer_name,
	c.effective_date::date + c.payment_days as due_date,
	c.amount::text || '' '' || c.currency as amount,
	c.paid_amount::text || '' '' || c.paid_currency as paid_amount
from	im_costs c
where	c.cost_type_id = 3700 and
	c.cost_status_id not in (3810, 3814, 3816, 3818)
order by coalesce(c.amount,0) DESC
limit 10
"',	-- component_tcl
	'lang::message::lookup "" intranet-cost.Top_10_Unpaid_Customer_Invoices "Top 10 Unpaid Customer Invoices"'
);



SELECT im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',			-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'Top 10 Unpaid Provider Bills',		-- plugin_name - shown in menu
	'intranet-cost',			-- package_name
	'left',					-- location
	'/intranet-cost/index',			-- page_url
	null,					-- view_name
	20,					-- sort_order
	'im_ad_hoc_query -format html -package_key intranet-cost "
select
	''<a href=/intranet-invoices/view?invoice_id='' || c.cost_id || ''>'' || c.cost_name || ''</a>'' as document_nr
	im_cost_center_code_from_id(c.cost_center_id) as cost_center,
	''<a href=/intranet/companies/view?company_id='' || c.provider_id || ''>'' || im_company__name(c.provider_id) || ''</a>'' as provider_name,
	c.effective_date::date + c.payment_days as due_date,
	c.amount::text || '' '' || c.currency as amount,
	c.paid_amount::text || '' '' || c.paid_currency as paid_amount
from	im_costs c
where	c.cost_type_id = 3704 and
	c.cost_status_id not in (3810, 3814, 3816, 3818)
order by coalesce(c.amount,0) DESC
limit 10
"',	-- component_tcl
	'lang::message::lookup "" intranet-cost.Top_10_Unpaid_Provider_Bills "Top 10 Unpaid Provider Bills"'
);



-- Help Blurb Portlet
--
SELECT im_component_plugin__new (
        null,                                   -- plugin_id
        'im_component_plugin',                  -- object_type
        now(),                                  -- creation_date
        null,                                   -- creation_user
        null,                                   -- creation_ip
        null,                                   -- context_id
        'Finance Home Page Help',               -- plugin_name
        'intranet-cost',                        -- package_name
        'top',                                  -- location
        '/intranet-cost/index',                 -- page_url
        null,                                   -- view_name
        10,                                     -- sort_order
        'set a "
		This page shows a section of possible reports and indicators that might help you
		to obtain a quick overview over your company finance.<br>
		The examples included below can be easily modified and extended to suit your needs. <br>
		Please login as System Administrator and click on the wrench ([im_gif wrench])
		symbols to the right of each portlet.
	"',
        'lang::message::lookup "" intranet-cost.Help_Blurb "Finance Home Page Help"'
);



