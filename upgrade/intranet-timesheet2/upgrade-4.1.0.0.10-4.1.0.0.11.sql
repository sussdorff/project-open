SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.1.0.0.10-4.1.0.0.11.sql','');

-- -------------------------------------------------------
-- Add the correct datatypes
-- -------------------------------------------------------

update im_view_columns set datatype = 'float' where variable_name in ('planned_absence_days_this_year', 'taken_absence_days_this_year', 'remaining_absence_days_this_year', 'requested_absence_days_this_year','remaining_vacation_days','entitlement_days_this_year');
