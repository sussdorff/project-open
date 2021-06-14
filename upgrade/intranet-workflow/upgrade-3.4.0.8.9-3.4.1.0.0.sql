-- upgrade-3.4.0.8.9-3.4.1.0.0.sql

SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-3.4.0.8.9-3.4.1.0.0.sql','');


-- Add "class=button" to show the action character of the
-- "Action" link

delete from im_view_columns
where column_id = 26000;

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order)
values (26000,260,'Action','"<a class=button href=$action_url>$next_action_l10n</a>"',0);
