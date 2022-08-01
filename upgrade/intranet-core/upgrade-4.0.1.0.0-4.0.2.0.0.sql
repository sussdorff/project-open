-- upgrade-4.0.0.9.9-4.0.1.0.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.1.0.0-4.0.2.0.0.sql','');




-------------------------------------------------------------
-- Fix extension tables for user

delete from acs_object_type_tables where object_type = 'user';

insert into acs_object_type_tables (object_type,table_name,id_column)
values ('user', 'persons', 'person_id');

insert into acs_object_type_tables (object_type,table_name,id_column)
values ('user','users_contact','user_id');

insert into acs_object_type_tables (object_type,table_name,id_column)
values ('user','parties','party_id');

insert into acs_object_type_tables (object_type,table_name,id_column)
values ('user','im_employees','employee_id');

insert into acs_object_type_tables (object_type,table_name,id_column)
values ('user', 'users', 'user_id');








--
delete from im_view_columns where column_id >= 2600 and column_id < 2699;
delete from im_views where view_id = 26;
--
insert into im_views (view_id, view_name, visible_for, view_type_id)
values (26, 'personal_todo_list', 'view_projects', 1400);

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2600,26,NULL,'Task',
'"<a HREF=$task_url$task_id>$task_name</A>"','','',0,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2610,26,NULL,'Type',
'$task_type','','',10,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2620,26,NULL,'End',
'<nobr>$end_date_pretty</nobr>','','',20,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2630,26,NULL,'Prio',
'$priority</nobr>','','',30,'');





-- Localization
SELECT	im_component_plugin__new (
	null,				-- plugin_id
	'acs_object',			-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id

	'User Localization',		-- plugin_name
	'intranet-core',		-- package_name
	'left',				-- location
	'/intranet/users/view',		-- page_url
	null,				-- view_name
	55,				-- sort_order
	'im_user_localization_component $user_id $return_url'	-- component_tcl
);


