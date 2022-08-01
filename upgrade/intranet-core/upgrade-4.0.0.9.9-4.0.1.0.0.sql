-- upgrade-4.0.0.9.9-4.0.1.0.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.0.9.9-4.0.1.0.0.sql','');


-- Disable obsolete "light green" skin
update im_categories
set enabled_p = 'f'
where category = 'lightgreen';




-- Project Base Data Component
SELECT im_component_plugin__new (null, 'acs_object', now(), null, null, null, 'Project Base Data', 'intranet-core', 'left', '/intranet/projects/view', null, 10, 'im_project_base_data_component -project_id $project_id -return_url $return_url');


-- Project Hierarchy Original Component
SELECT im_component_plugin__new (null, 'acs_object', now(), null, null, null, 'Project Hierarchy', 'intranet-core', 'right', '/intranet/projects/view', null, 50, 'im_project_hierarchy_component -project_id $project_id -return_url $return_url');





SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.1.0.8-3.4.1.0.9.sql','');



-- User Components

-- User Basic Info Component
SELECT im_component_plugin__new (null, 'acs_object', now(), null, null, null, 'User Basic Information', 'intranet-core', 'left', '/intranet/users/view', null, 0, 'im_user_basic_info_component $user_id $return_url');

-- User Contact Infor Component
SELECT im_component_plugin__new (null, 'acs_object', now(), null, null, null, 'User Contact Information', 'intranet-core', 'left', '/intranet/users/view', null, 0, 'im_user_contact_info_component $user_id $return_url');

-- User Skin Component
-- SELECT im_component_plugin__new (null, 'acs_object', now(), null, null, null, 'User Skin Information', 'intranet-core', 'left', '/intranet/users/view', null, 0, 'im_user_skin_info_component $user_id $return_url');

SELECT im_component_plugin__new (null, 'acs_object', now(), null, null, null, 'User Skin Information', 'intranet-core', 'left', '/intranet/users/view', null, 0, 'im_skin_select_html $user_id $return_url');

-- User Administration Component
SELECT im_component_plugin__new (null, 'acs_object', now(), null, null, null, 'User Admin Information', 'intranet-core', 'left', '/intranet/users/view', null, 0, 'im_user_admin_info_component $user_id $return_url');

-- User Localization Component
SELECT im_component_plugin__new (null, 'acs_object', now(), null, null, null, 'User Localization Information', 'intranet-core', 'left', '/intranet/users/view', null, 0, 'im_user_localization_component $user_id $return_url');

-- User Portrait Component
SELECT im_component_plugin__new (null, 'acs_object', now(), null, null, null, 'User Portrait', 'intranet-core', 'right', '/intranet/users/view', null, 0, 'im_portrait_component $user_id_from_search $return_url $read $write $admin');


-- Company Components

-- Company Info
SELECT im_component_plugin__new (null, 'acs_object', now(), null, null, null, 'Company Information', 'intranet-core', 'left', '/intranet/companies/view', null, 0, 'im_company_info_component $company_id $return_url');

-- Company Projects
SELECT im_component_plugin__new (null, 'acs_object', now(), null, null, null, 'Company Projects', 'intranet-core', 'right', '/intranet/companies/view', null, 0, 'im_company_projects_component $company_id $return_url');


-- Company Members
SELECT im_component_plugin__new (null, 'acs_object', now(), null, null, null, 'Company Employees', 'intranet-core', 'right', '/intranet/companies/view', null, 0, 'im_company_employees_component $company_id $return_url');

-- Company Contacts
SELECT im_component_plugin__new (null, 'acs_object', now(), null, null, null, 'Company Contacts', 'intranet-core', 'right', '/intranet/companies/view', null, 0, 'im_company_contacts_component $company_id $return_url');






create or replace function acs_object__name (integer)
returns varchar as '
declare
	name__object_id		alias for $1;
	object_name		varchar;
	v_object_id		integer;
	obj_type		record;
	obj			record;
begin
	for obj_type in 
		select o2.name_method
		from acs_object_types o1, acs_object_types o2
		where o1.object_type = (
			select	object_type
			from	acs_objects o
			where	o.object_id = name__object_id)
				and o1.tree_sortkey between o2.tree_sortkey and tree_right(o2.tree_sortkey)
		order by 
			o2.tree_sortkey desc
	loop
		if obj_type.name_method != '''' and obj_type.name_method is NOT null then
			-- Execute the first name_method we find (since we''re traversing
			-- up the type hierarchy from the object''s exact type) using
			-- Native Dynamic SQL, to ascertain the name of this object.
			for obj in 
				execute ''select '' || obj_type.name_method || ''('' || name__object_id || '')::varchar as object_name'' 
			loop
				object_name := obj.object_name;
				exit;
			end loop;
			exit;
		end if;
	end loop;
	return object_name;
end;' language 'plpgsql' stable strict;





-- ------------------------------------------------------------------                                                                            
-- Special dereferencing function for links                                                                                                      
-- ------------------------------------------------------------------                                                                            

create or replace function im_link_from_id (integer) returns varchar as '
DECLARE
        p_object_id     alias for $1;
        v_name          varchar;
        v_url           varchar;
BEGIN
        select  im_name_from_id (p_object_id)
        into    v_name;

        select url into v_url
        from im_biz_object_urls ibou, acs_objects ao
        where ibou.object_type = ao.object_type
        and ao.object_id = p_object_id;

        return ''<a href='' || v_url || p_object_id || ''>'' || v_name || ''</a>'';
end;' language 'plpgsql';



