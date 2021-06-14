-- upgrade-3.4.0.5.4-3.4.0.6.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.5.4-3.4.0.6.0.sql','');


update im_profiles set profile_gif = 'computer_key' 
where profile_id in (select group_id from groups where group_name = 'Helpdesk');

update im_profiles set profile_gif = 'server' 
where profile_id in (select group_id from groups where group_name = 'ITSM Vertical');

update im_profiles set profile_gif = 'chart_bar' 
where profile_id in (select group_id from groups where group_name = 'Consulting Vertical');

update im_profiles set profile_gif = 'text_allcaps' 
where profile_id in (select group_id from groups where group_name = 'Translation Vertical');

update im_profiles set profile_gif = 'house' 
where profile_id in (select group_id from groups where group_name = 'Employees');

update im_profiles set profile_gif = 'key' 
where profile_id in (select group_id from groups where group_name = 'Senior Managers');



-------------------------------------------------------------
-- Fix parameters for cloning
-------------------------------------------------------------


update apm_parameters 
set parameter_name = 'CloneProjectFsFilesP'
where parameter_name = 'CloneProjectFsFiles';


update apm_parameters 
set parameter_name = 'CloneProjectFsFoldersP'
where parameter_name = 'CloneProjectFsFolders';


-------------------------------------------------------------
-- Updated version of grant_permission that deals with the
-- case that the grantee doesnt exist.
-------------------------------------------------------------

create or replace function acs_permission__grant_permission (integer, integer, varchar)
returns integer as '
declare
	grant_permission__object_id		alias for $1;
	grant_permission__grantee_id		alias for $2;
	grant_permission__privilege		alias for $3;
	exists_p				boolean;
begin
	lock table acs_permissions_lock;

	select count(*) > 0 into exists_p from acs_permissions
	where object_id = grant_permission__object_id and 
		grantee_id = grant_permission__grantee_id and
		privilege = grant_permission__privilege;

	IF grant_permission__grantee_id is not NULL AND not exists_p THEN
		insert into acs_permissions (
		       	object_id, grantee_id, privilege
		) values (
			grant_permission__object_id, 
			grant_permission__grantee_id, 
			grant_permission__privilege
		);
	END IF;

	return 0; 
end;' language 'plpgsql';

