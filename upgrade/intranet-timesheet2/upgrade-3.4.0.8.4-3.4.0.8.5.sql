-- upgrade-3.4.0.8.4-3.4.0.8.5.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-3.4.0.8.4-3.4.0.8.5.sql','');


-- set the update frequency to once a minute.
update apm_parameter_values 
set attr_value = '61' 
where parameter_id in (
	select parameter_id
	from apm_parameters
	where parameter_name = 'SyncHoursInterval'
);

