-- upgrade-5.0.0.0.1-5.0.0.0.2.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-5.0.0.0.0-5.0.0.0.1.sql','');

update im_component_plugins set component_tcl = 'im_absence_calendar_component -owner_id [im_coalesce $user_id_from_search [auth::get_user_id]] -absence_status_id [im_user_absence_status_requested_or_active] -year [clock format [clock seconds] -format "%Y"]' where plugin_name = 'Absence Calendar';
update im_component_plugins set component_tcl = 'im_absence_cube_component -user_selection [im_coalesce $user_id_from_search [auth::get_user_id]]' where plugin_name = 'Absence Cube';
update im_component_plugins set component_tcl = 'im_absence_calendar_component -owner_id [im_coalesce $user_id_from_search $user_selection [auth::get_user_id]] -year [im_year_from_date $timescale_date]' where plugin_name = 'Calendar View of Absences';
update im_component_plugins set component_tcl = 'im_absence_list_component -user_selection [im_coalesce $user_selection [auth::get_user_id]] -absence_status_id $filter_status_id -absence_type_id $org_absence_type_id -timescale $timescale -timescale_date $timescale_date -order_by $order_by' where plugin_name = 'Absences List';
