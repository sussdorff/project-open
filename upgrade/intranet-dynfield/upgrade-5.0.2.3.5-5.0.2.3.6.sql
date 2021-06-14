-- upgrade-upgrade-5.0.2.3.5-5.0.2.3.6.sql
SELECT acs_log__debug('/packages/intranet-dynfield/sql/postgresql/upgrade/upgrade-5.0.2.3.5-5.0.2.3.6.sql','');


update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Company Type" translate_p 1}}' 
where widget_name = 'category_company_type';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Invoice Payment Method" translate_p 1}}' 
where widget_name = 'category_invoice_payment_method';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Invoice Payment Method" translate_p 1}}' 
where widget_name = 'category_payment_method';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Project Status" translate_p 1}}' 
where widget_name = 'project_status';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Idea Priority" translate_p 1}}' 
where widget_name = 'idea_priority';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Office Status" translate_p 1}}' 
where widget_name = 'category_office_status';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Office Type" translate_p 1}}' 
where widget_name = 'category_office_type';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Company Status" translate_p 1}}' 
where widget_name = 'category_company_status';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Gantt Task Fixed Task Type" translate_p 1}}' 
where widget_name = 'gantt_fixed_task_type';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Ticket Priority" translate_p 1}}' 
where widget_name = 'ticket_priority';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Ticket Telephony Request Type" translate_p 1}}' 
where widget_name = 'telephony_request_type';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Project Type" translate_p 1}}' 
where widget_name = 'project_type';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet UoM" translate_p 1}}' 
where widget_name = 'units_of_measure';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Translation Task Type" translate_p 1}}' 
where widget_name = 'trans_task_types';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Translation File Type" translate_p 1}}' 
where widget_name = 'trans_file_types';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Project Type" translate_p 1}}' 
where widget_name = 'category_project_type';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Project Status" translate_p 1}}' 
where widget_name = 'category_project_status';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Project On Track Status" translate_p 1}}' 
where widget_name = 'category_project_on_track_status';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Ticket Type" translate_p 1}}' 
where widget_name = 'ticket_type';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Ticket Status" translate_p 1}}' 
where widget_name = 'ticket_status';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Gantt Task Scheduling Type" translate_p 1}}' 
where widget_name = 'gantt_scheduling_constraint_type';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Opportunity Priority" translate_p 1}}' 
where widget_name = 'opportunity_priority';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Annual Revenue" translate_p 1}}' 
where widget_name = 'annual_revenue';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Biz Object Role" translate_p 1}}' 
where widget_name = 'biz_object_member_type';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Department Planner Project Priority" translate_p 1}}' 
where widget_name = 'department_planner_project_priority';
update im_dynfield_widgets set parameters = '{custom {category_type "Intranet Opportunity Sales Stage" translate_p 1}}' 
where widget_name = 'opportunity_sales_stage';

