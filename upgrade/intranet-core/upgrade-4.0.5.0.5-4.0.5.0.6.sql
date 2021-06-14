-- upgrade-4.0.5.0.5-4.0.5.0.6.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.5.0.5-4.0.5.0.6.sql','');


delete from im_biz_object_urls where object_type = 'group';
insert into im_biz_object_urls (object_type, url_type, url) values (
'group','view','/admin/groups/one?group_id=');
insert into im_biz_object_urls (object_type, url_type, url) values (
'group','edit','/admin/groups/one?group_id=');


delete from im_biz_object_urls where object_type = 'im_profile';
insert into im_biz_object_urls (object_type, url_type, url) values (
'im_profile','view','/admin/groups/one?group_id=');
insert into im_biz_object_urls (object_type, url_type, url) values (
'im_profile','edit','/admin/groups/one?group_id=');

