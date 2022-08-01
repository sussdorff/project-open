-- upgrade-4.0.3.1.2-4.0.3.1.3.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-4.0.3.1.2-4.0.3.1.3.sql','');


-- Show profit and loss in companies page
--
select im_component_plugin__new (
	null,				-- plugin_id
	'acs_object',			-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id

	'Company Profit Component',	-- plugin_name
	'intranet-cost',		-- package_name
	'left',				-- location
	'/intranet/companies/view',	-- page_url
	null,				-- view_name
	85,				-- sort_order

	'im_costs_company_profit_loss_component -company_id $company_id'	-- component_tcl
);

