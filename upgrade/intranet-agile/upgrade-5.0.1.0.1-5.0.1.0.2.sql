-- upgrade-5.0.1.0.1-5.0.1.0.2.sql
SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-5.0.1.0.1-5.0.1.0.2.sql','');

delete from im_view_columns where column_id = 26090;

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order)
values (26090,260,
        '<input type=checkbox onclick="acs_ListCheckAll(''action'',this.checked)">',
        '"<input type=checkbox name=task_id value=$task_id id=action,$task_id>"',
-10);

