-- upgrade-5.0.2.4.3-5.0.2.4.4.sql
SELECT acs_log__debug('/packages/intranet-riskmanagement/sql/postgresql/upgrade/upgrade-5.0.2.4.3-5.0.2.4.4.sql','');



-----------------------------------------------------------
-- Risk List Long
--

insert into im_views (view_id, view_name, visible_for, view_type_id) values (211, 'im_risk_list_long', 'view_risks', 1400);

-- Add a "select all" checkbox to select all risks in the list
insert into im_view_columns (
        column_id, view_id, sort_order,
	column_name,
	column_render_tcl,
        visible_for
) values (
        21100, 211, 0,
        '<input type=checkbox name=_dummy onclick="acs_ListCheckAll(''risk'',this.checked)">',
        '"<input type=checkbox name=risk_id.$risk_id id=risk.$risk_id>"',
        ''
);

insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl) values
(21110, 211, 10, 'Name', '"<a href=[export_vars -base "/intranet-riskmanagement/new" {{form_mode display} risk_id return_url}]>$risk_name</a>"');

insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl) values
(21120, 211, 20, 'Project', '"<a href=[export_vars -base "/intranet/projects/view" {{project_id $risk_project_id}}]>$risk_project_name</a>"');

insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl) values
(21125, 211, 25, 'Creator', '"<a href=[export_vars -base "/intranet/users/view" {{user_id $creation_user}}]>$creation_user_name/a>"');

insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl) values
(21130,211,30,'Type','$risk_type');

insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl) values
(21140,211,40,'Status','$risk_status');


insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl) values
(21170,211,70,'Impact','$risk_impact');

insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl) values
(21180,211,80,'Percent','$risk_probability_percent');



