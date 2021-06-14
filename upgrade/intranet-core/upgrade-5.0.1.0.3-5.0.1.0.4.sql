-- upgrade-5.0.1.0.3-5.0.1.0.4.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.1.0.3-5.0.1.0.4.sql','');


insert into im_views (view_id, view_name, visible_for, view_type_id)
values (28, 'project_timesheet_log_select', 'view_projects', 1400);



--
delete from im_view_columns where column_id >= 2800 and column_id < 2899;
--

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2800,28,NULL,'Log',
'"<a class=button href=/intranet-timesheet2/hours/new?show_week_p=0&project_id=$project_id&julian_date=[im_opt_val julian_date]
>&nbsp;Log Hours</a>"','','',0,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2805,28,NULL,'Project nr',
'"<A HREF=/intranet/projects/view?project_id=$project_id>$project_nr</A>"',
'','',5,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2810,28,NULL,'Project Name',
'"<A HREF=/intranet/projects/view?project_id=$project_id>$project_name</A>"','','',10,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2815,28,NULL,'Client',
'"<A HREF=/intranet/companies/view?company_id=$company_id>$company_name</A>"',
'','',15,'im_permission $user_id view_companies');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2828,28,NULL,'Type',
'$project_type','','',28,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2825,28,NULL,'Project Manager',
'"<A HREF=/intranet/users/view?user_id=$project_lead_id>$lead_name</A>"',
'','',25,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2830,28,NULL,'Start Date',
'$start_date_formatted','','',30,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2835,28,NULL,'Delivery Date',
'$end_date_formatted','','',35,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2840,28,NULL,'Status',
'$project_status','','',40,'');

