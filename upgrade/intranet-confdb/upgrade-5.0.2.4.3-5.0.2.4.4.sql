-- upgrade-5.0.2.4.3-5.0.2.4.4.sql

SELECT acs_log__debug('/packages/intranet-confdb/sql/postgresql/upgrade/upgrade-5.0.2.4.3-5.0.2.4.4.sql','');

-- Allow also rels from users and other objects to ConfItems
update acs_rel_types 
set object_type_one = 'acs_object' 
where rel_type = 'im_conf_item_project_rel';

