-- upgrade-3.4.0.8.3-3.4.0.8.4.sql

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-3.4.0.8.3-3.4.0.8.4.sql','');


-- Create a fake object type, because im_invoice_item does not
-- "reference" acs_objects.
select acs_object_type__create_type (
	'im_invoice_item',	-- object_type
	'Invoice Item',		-- pretty_name
	'Invoice Items',	-- pretty_plural
	'acs_object',		-- supertype
	'im_invoice_items',	-- table_name
	'item_id',		-- id_column
	'intranet-invoices',	-- package_name
	'f',			-- abstract_p
	null,			-- type_extension_table
	'im_invoice_item__name'	-- name_method
);

update acs_object_types set
	status_type_table = 'im_invoice_items',
	status_column = 'item_status_id',
	type_column = 'item_type_id'
where object_type = 'im_invoice_item';


-- Do not show autmatic links to invoice items at the moment.
-- insert into acs_object_type_tables (object_type,table_name,id_column)
-- values ('im_invoice', 'im_invoices', 'invoice_id');
-- insert into acs_object_type_tables (object_type,table_name,id_column)
-- values ('im_invoice', 'im_costs', 'cost_id');

