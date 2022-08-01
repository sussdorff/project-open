-- upgrade-5.0.1.0.1-5.0.1.0.2.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.1.0.1-5.0.1.0.2.sql','');



-------------------------------------------------------------
-- Function to check for a valid date
-------------------------------------------------------------

create or replace function is_date(s varchar) 
returns boolean as $body$
begin
	perform s::date;
	return true;
	exception when others then
		return false;
	end;
$body$ language plpgsql;



update im_component_plugins
set plugin_name = 'Home Gantt Tasks'
where plugin_name = 'Home Timesheet Tasks';

update im_categories
set category_type = 'Intranet Gantt Task Scheduling Type'
where category_type = 'Intranet Timesheet Task Scheduling Type';

update acs_privileges set pretty_name = 'Edit Gantt Task', pretty_plural = 'Edit Gantt Task' where pretty_name = 'Edit Timesheet Task';
update acs_privileges set pretty_name = 'View Gantt Task', pretty_plural = 'View Gantt Task' where pretty_name = 'View Timesheet Task';


update im_dynfield_widgets 
set parameters = '{custom {category_type "Intranet Gantt Task Fixed Task Type"}}'
where parameters = '{custom {category_type "Intranet Timesheet Task Fixed Task Type"}}';

update im_dynfield_widgets 
set parameters = '{custom {category_type "Intranet Gantt Task Scheduling Type"}}'
where parameters = '{custom {category_type "Intranet Timesheet Task Scheduling Type"}}';

update im_dynfield_widgets 
set parameters = '{custom {category_type "Intranet Gantt Task Fixed Task Type"}}'
where parameters = '{custom {category_type "Intranet Timesheet Task Fixed Task Type"}}';


SELECT im_dynfield_widget__new (
        null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
        'gantt_fixed_task_type', 'Gantt Fixed Task Type', 'Gantt Fixed Task Type',
        10007, 'integer', 'im_category_tree', 'integer',
        '{custom {category_type "Intranet Gantt Task Fixed Task Type"}}'
);

update acs_object_types set pretty_name = 'Gantt Task' where pretty_name = 'Timesheet Task';
update acs_object_types set pretty_plural = 'Gantt Tasks' where pretty_plural = 'Timesheet Tasks';

update acs_object_types set pretty_name = 'Gantt Task Dependency' where pretty_name = 'Timesheet Task Dependency';
update acs_object_types set pretty_plural = 'Gantt Task Dependencies' where pretty_plural = 'Timesheet Task Dependencies';


update im_menus set name = 'Gantt Task' where name = 'Timesheet Task';


