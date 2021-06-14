-- upgrade-3.2.2.0.0-3.2.3.0.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-3.2.2.0.0-3.2.3.0.0.sql','');

-- Fix Biz-Obj URLs

delete from im_biz_object_urls
where object_type = 'im_timesheet_task';

insert into im_biz_object_urls (object_type, url_type, url) values (
'im_timesheet_task','view','/intranet-timesheet2-tasks/new?task_id=');
insert into im_biz_object_urls (object_type, url_type, url) values (
'im_timesheet_task','edit','/intranet-timesheet2-tasks/new?form_mode=edit&task_id=');

