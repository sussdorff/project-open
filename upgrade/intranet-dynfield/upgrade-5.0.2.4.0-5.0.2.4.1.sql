-- upgrade-upgrade-5.0.2.4.0-5.0.2.4.1.sql
SELECT acs_log__debug('/packages/intranet-dynfield/sql/postgresql/upgrade/upgrade-5.0.2.4.0-5.0.2.4.1.sql','');



select im_dynfield_widget__new (
	null,'im_dynfield_widget',now(),null,null,null,
	'category_cost_type',			-- widget_name
	'#intranet-core.Cost_Type#',		-- pretty_name
	'#intranet-core.Cost_Types#',		-- pretty_plural
	10007,					-- storage_type_id
	'integer',				-- acs_datatype
	'im_category_tree',			-- widget
	'integer',				-- sql_datatype
	'{custom {category_type "Intranet Cost Type"}}' 	-- parameters
);


select im_dynfield_widget__new (
	null,'im_dynfield_widget',now(),null,null,null,
	'category_expense_type',			-- widget_name
	'#intranet-core.Expense_Type#',		-- pretty_name
	'#intranet-core.Expense_Types#',		-- pretty_plural
	10007,					-- storage_type_id
	'integer',				-- acs_datatype
	'im_category_tree',			-- widget
	'integer',				-- sql_datatype
	'{custom {category_type "Intranet Expense Type"}}' 	-- parameters
);


select im_dynfield_widget__new (
	null,'im_dynfield_widget',now(),null,null,null,
	'category_material_type',			-- widget_name
	'#intranet-core.Material_Type#',		-- pretty_name
	'#intranet-core.Material_Types#',		-- pretty_plural
	10007,					-- storage_type_id
	'integer',				-- acs_datatype
	'im_category_tree',			-- widget
	'integer',				-- sql_datatype
	'{custom {category_type "Intranet Material Type"}}' 	-- parameters
);


