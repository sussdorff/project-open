-- upgrade-4.1.0.0.5-4.1.0.0.6.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-4.1.0.0.5-4.1.0.0.6.sql','');


-- Show the finance component (summary view) in a projects "Summary" page
--

update im_component_plugins set component_tcl = 'im_costs_project_finance_component -user_id $user_id -project_id $project_id' where component_tcl like 'im_costs_project_finance_component%'
