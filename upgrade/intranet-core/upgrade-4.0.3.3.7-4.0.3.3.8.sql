-- upgrade-4.0.3.3.7-4.0.3.3.8.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.3.7-4.0.3.3.8.sql','');


-- Add a checkbox column to the ProjectHiearchyPortlet.
-- The column is only visible if $bulk_actions_p=1

delete from im_view_columns where column_id = 2500;

insert into im_view_columns (view_id, column_id, sort_order, column_name, column_render_tcl, visible_for)
values (25,2500,0,'<input type=checkbox name=_dummy onclick="acs_ListCheckAll(''hierarchy_project_id'',this.checked)">','$select_checkbox', 'expr $bulk_actions_p');


