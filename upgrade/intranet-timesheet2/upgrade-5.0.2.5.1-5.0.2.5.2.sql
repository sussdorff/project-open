-- upgrade-5.0.2.5.1-5.0.2.5.2.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-5.0.2.5.1-5.0.2.5.2.sql','');


delete from im_biz_object_urls where object_type = 'im_user_absence';

insert into im_biz_object_urls (object_type, url_type, url) values (
'im_user_absence','view','/intranet-timesheet2/absences/new?form_mode=display&absence_id=');
insert into im_biz_object_urls (object_type, url_type, url) values (
'im_user_absence','edit','/intranet-timesheet2/absences/new?absence_id=');

