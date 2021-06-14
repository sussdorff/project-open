-- /packages/intranet-core/sql/postgres/cleanup-file-storage.sql
--
-- Copyright (C) 1999-2016 various parties
--
-- This program is free software. You can redistribute it
-- and/or modify it under the terms of the GNU General
-- Public License as published by the Free Software Foundation;
-- either version 2 of the License, or (at your option)
-- any later version. This program is distributed in the
-- hope that it will be useful, but WITHOUT ANY WARRANTY;
-- without even the implied warranty of MERCHANTABILITY or
-- FITNESS FOR A PARTICULAR PURPOSE.
-- See the GNU General Public License for more details.
--
-- @author	frank.bergmann@project-open.com

-------------------------------------------------------------
-- Fix issues with file-storage package.
--


-- Drop association with function 'datasource' and their concrete implementation 'fs__datasource'
select acs_sc_impl_alias__delete(
           'FtsContentProvider',                -- impl_contract_name
           'file_storage_object',                 -- impl_name
           'datasource'                         -- impl_operation_name
);

-- Drop association with function 'url' and their concrete implementation 'fs__url'
select acs_sc_impl_alias__delete(
           'FtsContentProvider',		-- impl_contract_name
           'file_storage_object',               -- impl_name
           'url'				-- impl_operation_name
);

-- Drop the search contract implementation
select acs_sc_impl__delete(
           'FtsContentProvider',                -- impl_contract_name
           'file_storage_object'                -- impl_name (the content_type created above)
);


-- drop root content-repository folder
CREATE OR REPLACE FUNCTION inline_0() 
RETURNS integer AS $$
DECLARE
	rec_root_folder		record;
        template_id             integer;
BEGIN
    for rec_root_folder in 
        select package_id
	from fs_root_folders
    loop
        -- JS: The RI constraints will cause acs_objects__delete to fail
	-- JS: So I changed this to apm_package__delete
        PERFORM apm_package__delete(rec_root_folder.package_id);
    end loop;

    -- Unregister the content template
    template_id := content_type__get_template('file_storage_object','public');

    perform content_type__unregister_template ('file_storage_object', template_id, 'public');
    perform content_template__del(template_id);
    return 0;
END;$$ LANGUAGE plpgsql;
select inline_0();
drop function inline_0();

drop view if exists fs_objects;
drop view if exists fs_files;
drop view if exists fs_folders;
drop view if exists fs_urls_full;

drop trigger if exists fs_package_items_delete_trig on fs_root_folders;
drop function if exists fs_package_items_delete_trig();
drop trigger if exists fs_root_folder_delete_trig on fs_root_folders;
drop function if exists fs_root_folder_delete_trig();



-- Delete file_storage_object

update cr_items set live_revision = null 
where live_revision in (select object_id from acs_objects where object_type = 'file_storage_object');
update cr_items set latest_revision = null 
where latest_revision in (select object_id from acs_objects where object_type = 'file_storage_object');
delete from cr_items where content_type = 'file_storage_object';
delete from cr_type_template_map where content_type = 'file_storage_object';
delete from im_rest_object_types where object_type = 'file_storage_object';
delete from acs_objects where object_type = 'file_storage_object';

select content_type__drop_type (
       'file_storage_object',	 -- content_type
       'f',			 -- drop_children_p
       'f'			 -- drop_table_p
);

--
-- procedure inline_0/0
--
CREATE OR REPLACE FUNCTION inline_0(
) RETURNS integer AS $$
DECLARE
   row 				record;
BEGIN
    for row in select type_id
                from notification_types
                where short_name in ('fs_fs_notif')
    loop
        perform notification_type__delete(row.type_id);
    end loop;

    return null;
END;
$$ LANGUAGE plpgsql;
select inline_0();
drop function inline_0();


--
-- procedure inline_0/0
--
CREATE OR REPLACE FUNCTION inline_0() 
RETURNS integer AS $$
DECLARE
        impl_id integer;
        v_foo   integer;
BEGIN
        -- the notification type impl
        impl_id := acs_sc_impl__get_id (
                      'NotificationType',		-- impl_contract_name
                      'fs_fs_notif_type'	-- impl_name
        );

        perform acs_sc_binding__delete (
                    'NotificationType',
                    'fs_fs_notif_type'
        );

        v_foo := acs_sc_impl_alias__delete (
                    'NotificationType',		-- impl_contract_name	
                    'fs_fs_notif_type',		-- impl_name
                    'GetURL'				-- impl_operation_name
        );

        v_foo := acs_sc_impl_alias__delete (
                    'NotificationType',		-- impl_contract_name	
                    'fs_fs_notif_type',	-- impl_name
                    'ProcessReply'			-- impl_operation_name
        );

        perform acs_sc_impl__delete(
                    'NotificationType',                -- impl_contract_name
                    'fs_fs_notif_type'                 -- impl_name
        );

	select into v_foo type_id 
	  from notification_types
	 where sc_impl_id = impl_id
	  and short_name = 'fs_fs_notif';

	perform notification_type__delete (v_foo);

	delete from notification_types_intervals
	 where type_id = v_foo 
	   and interval_id in ( 
		select interval_id
		  from notification_intervals 
		 where name in ('instant','hourly','daily')
	);

	delete from notification_types_del_methods
	 where type_id = v_foo
	   and delivery_method_id in (
		select delivery_method_id
		  from notification_delivery_methods 
		 where short_name in ('email')
	);

	return (0);
END;
$$ LANGUAGE plpgsql;

select inline_0();
drop function inline_0();



-- Delete file-storage content folders



delete from acs_object_context_index
where	object_id in (select folder_id from cr_folders where package_id in (
		select package_id from apm_packages where package_key = 'file-storage'
	)) or
	ancestor_id in (select folder_id from cr_folders where package_id in (
		select package_id from apm_packages where package_key = 'file-storage'
	));

update acs_objects set context_id = null
where context_id in (
	select folder_id from cr_folders where package_id in (
		select package_id from apm_packages where package_key = 'file-storage'
	)
);

select	content_folder__delete(folder_id,'t')
from	cr_folders
where	package_id in (
		select	package_id
		from	apm_packages
		where	package_key = 'file-storage'     
	);



drop table if exists fs_root_folders cascade;
drop table if exists fs_rss_subscrs;

DROP VIEW if exists file_storage_objectx;
DROP VIEW if exists file_storage_objecti cascade;
-- DROP FUNCTION if exists file_storage_object_f(p_new file_storage_objecti);
-- DROP RULE if exists file_storage_object_r ON file_storage_objecti;

DROP FUNCTION if exists file_storage_object__name(integer);
DROP FUNCTION if exists file_storage__rename_file(integer, character varying);
DROP FUNCTION if exists file_storage__new_version(
     character varying, character varying, character varying, integer, integer, character varying);
DROP FUNCTION if exists file_storage__new_root_folder(integer, character varying, character varying, character varying);
DROP FUNCTION if exists file_storage__new_folder(character varying, character varying, integer, integer, character varying);
DROP FUNCTION if exists file_storage__new_file(character varying, integer, integer, character varying, boolean, integer, integer);
DROP FUNCTION if exists file_storage__new_file(character varying, integer, integer, character varying, boolean, integer);
DROP FUNCTION if exists file_storage__move_file(integer, integer, integer, character varying);
DROP FUNCTION if exists file_storage__get_title(integer);
DROP FUNCTION if exists file_storage__get_root_folder(integer);
DROP FUNCTION if exists file_storage__get_parent_id(integer);
DROP FUNCTION if exists file_storage__get_package_id(integer);
DROP FUNCTION if exists file_storage__get_folder_name(integer);
DROP FUNCTION if exists file_storage__get_content_type(integer);
DROP FUNCTION if exists file_storage__delete_version(integer, integer);
DROP FUNCTION if exists file_storage__delete_folder(integer, boolean);
DROP FUNCTION if exists file_storage__delete_folder(integer);
DROP FUNCTION if exists file_storage__delete_file(integer);
DROP FUNCTION if exists file_storage__copy_file(integer, integer, integer, character varying);

delete from acs_sc_impl_aliases where impl_name = 'file_storage_object';
delete from acs_sc_impl_aliases where impl_name = 'file-storage';

delete from acs_sc_impls where impl_name in ('file_storage_object', 'file-storage');


