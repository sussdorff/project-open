-- upgrade-4.0.5.0.5-4.0.5.0.6.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.0.5.0.5-4.0.5.0.6.sql','');


-- Absences_for_user
update lang_messages set message = 'Absences for %user_name%'
where package_key = 'intranet-timesheet2' and locale = 'en_US' and message_key = 'Absences_for_user';
update lang_messages set message = 'Absenzen f&uuml;r %user_name%'
where package_key = 'intranet-timesheet2' and locale = 'de_DE' and message_key = 'Absences_for_user';

-- for_username
update lang_messages set message = 'for %user_from_search_name%'
where package_key = 'intranet-timesheet2' and locale = 'en_US' and message_key = 'for_username';
update lang_messages set message = 'f&uuml;r %user_from_search_name%'
where package_key = 'intranet-timesheet2' and locale = 'de_DE' and message_key = 'for_username';




-- -----------------------------------------------------
-- Rename privilege
-- -----------------------------------------------------
select acs_privilege__create_privilege('add_hours_for_direct_reports','Add hours for direct reports','');
select acs_privilege__add_child('admin', 'add_hours_for_direct_reports');

update acs_permissions
set privilege = 'add_hours_for_direct_reports'
where privilege = 'add_hours_for_subordinates';

delete from acs_privilege_hierarchy
where child_privilege = 'add_hours_for_subordinates';

delete from acs_permissions
where privilege = 'add_hours_for_subordinates';

