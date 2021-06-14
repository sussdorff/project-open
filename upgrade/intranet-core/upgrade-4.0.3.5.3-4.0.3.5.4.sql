-- upgrade-4.0.3.5.3-4.0.3.5.4.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.5.3-4.0.3.5.4.sql','');


-- Fix the "User" column in the main users view
update im_view_columns 
set column_render_tcl = '"<a href=/intranet/users/view?user_id=$person_id>$name</a>"'
where column_id = 200;



