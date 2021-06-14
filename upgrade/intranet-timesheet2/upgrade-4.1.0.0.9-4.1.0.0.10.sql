SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.1.0.0.9-4.1.0.0.10.sql','');

-- -------------------------------------------------------
-- Enable vacation planning
-- -------------------------------------------------------

select im_category_new (16009, 'Planned', 'Intranet Absence Status');

update im_categories set aux_string2 = 'P' where category_id = 16009;

delete from im_view_columns where column_id = 29134;
insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order,variable_name) 
values (29134,291,'Planned Days this year','"$planned_absence_days_this_year"',34,'planned_absence_days_this_year');

update im_categories set visible_tcl = 'im_user_is_hr_p [ad_conn user_id]' where visible_tcl = '[im_user_is_hr_p $user_id]';