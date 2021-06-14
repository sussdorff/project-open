-- upgrade-5.0.0.0.1-5.0.0.0.2.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-workflow/sql/postgresql/upgrade/upgrade-5.0.0.0.1-5.0.0.0.2.sql','');

delete from im_view_columns where view_id = 270;
delete from im_views where view_id = 270;
insert into im_views (view_id, view_name, visible_for, view_type_id)
values (270, 'ticket_list', 'view_tickets', 1400);


insert into im_view_columns (
        column_id, view_id, sort_order,
	column_name,
	column_render_tcl,
        visible_for
) values (
        27099,270,-1,
        '<input type=checkbox name=_dummy onclick="acs_ListCheckAll(''ticket'',this.checked)">',
        '$action_checkbox',
        ''
);

insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl)
values (27001,270,1,'OK','<center>[im_project_on_track_bb $on_track_status_id]</center>');

insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl) values
(27005,270,5, 'Prio','"$ticket_prio"');

delete from im_view_columns where column_id = 27010;
insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl) values
(27010,270,10, 'Nr','"<a href=/intranet-helpdesk/new?form_mode=display&ticket_id=$ticket_id>$project_nr</a>\
<a href=/intranet-helpdesk/new?form_mode=edit&ticket_id=$ticket_id>[im_gif wrench]</a>"');

insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl) values
(27020,270,20,'Name','"<a href=/intranet-helpdesk/new?form_mode=display&ticket_id=$ticket_id>$project_name</A>"');

insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl) values
(270220,270,22,'Conf Item','"<A href=/intranet-confdb/new?form_mode=display&conf_item_id=$conf_item_id>$conf_item_name</a>"');

-- insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl) values
-- (27025,270,25,'Queue','"<href=/intranet-helpdesk/queue/?queue_id=$ticket_queue_id>$ticket_queue_name</A>"');

insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl) values
(27030,270,30,'Type','$ticket_type');
insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl) values
(27040,270,40,'Status','$ticket_status');

insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl) values
(27050,270,50,'Customer','"<A href=/intranet/companies/view?company_id=$company_id>$company_name</A>"');
insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl) values
(27060,270,60,'Contact','"<A href=/intranet/users/view?user_id=$ticket_customer_contact_id>$ticket_customer_contact</a>"');

-- insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl) values
-- (27070,270,70,'Assignee','"<A href=/intranet/users/view?user_id=$ticket_assignee_id>$ticket_assignee</a>"');

insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl) values
(27080,270,80,'SLA','"<A href=/intranet/projects/view?project_id=$sla_id>$sla_name</a>"');

update im_view_columns set visible_for = 'im_permission $current_user_id "view_tickets_all"'
where column_id = 27080;
