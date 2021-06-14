-- upgrade-3.4.0.5.0-3.4.0.5.1.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-3.4.0.5.0-3.4.0.5.1.sql','');


update im_view_columns set
	column_name = 'Effective Date',
	column_render_tcl = '$effective_date_formatted'
where
	column_id = 22013;



update im_menus set enabled_p = 'f' where label = 'costs';
update im_menus set enabled_p = 'f' where label = 'finance_exchange_rates';
update im_menus set enabled_p = 'f' where label = 'finance_expenses';
