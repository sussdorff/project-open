-- /packages/intranet-core/sql/postgres/cleanup-bug-tracker.sql
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




ALTER TABLE acs_object_context_index
DROP CONSTRAINT acs_obj_context_idx_obj_id_fk,
ADD CONSTRAINT acs_obj_context_idx_obj_id_fk
   FOREIGN KEY (object_id)
   REFERENCES acs_objects(object_id)
   ON DELETE CASCADE;

ALTER TABLE acs_object_context_index
DROP CONSTRAINT acs_obj_context_idx_anc_id_fk,
ADD CONSTRAINT acs_obj_context_idx_anc_id_fk
   FOREIGN KEY (ancestor_id)
   REFERENCES acs_objects(object_id)
   ON DELETE CASCADE;





select im_menu__del_module('intranet-bug-tracker');
select im_component_plugin__del_module('intranet-bug-tracker');


create or replace function inline_0 ()
returns integer as $body$
DECLARE
	v_count		integer;
BEGIN
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_timesheet_tasks' and lower(column_name) = 'bt_bug_id';
	IF v_count > 0 THEN
		alter table im_timesheet_tasks drop column bt_bug_id cascade;
		-- NOTICE:  drop cascades to view im_timesheet_tasks_view
	END IF;

	RETURN 0;
END;$body$ language 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();



-- Delete im_timesheet_tasks.bt_bug_id.
-- In order to delete the attribute, we need to 
-- recreate dependent views:
--
drop view if exists im_timesheet_tasks_view;
create or replace view im_timesheet_tasks_view as
select  t.*,
        p.parent_id as project_id,
        p.project_name as task_name,
        p.project_nr as task_nr,
        p.percent_completed,
        p.project_type_id as task_type_id,
        p.project_status_id as task_status_id,
        p.start_date,
        p.end_date,
        p.reported_hours_cache,
        p.reported_days_cache,
        p.reported_hours_cache as reported_units_cache
from
        im_projects p,
        im_timesheet_tasks t
where
        t.task_id = p.project_id;


-- Remove BT Container Project Types
-- Set project_type to "Other" from "Bug Tracker Container"
-- or "Bug Tracker Task"
update im_projects set project_type_id = 85 where project_type_id in (4300, 4305);
update im_invoice_items set item_type_id = 85 where item_type_id in (4300, 4305);
delete from im_category_hierarchy where parent_id in (4300, 4305) or child_id in (4300, 4305);
delete from im_dynfield_type_attribute_map where object_type_id in (4300, 4305);
delete from im_categories where category_id in (4300, 4305);



-- Fix dynfield widget delete function
create or replace function im_dynfield_widget__delete (integer)
returns integer as $body$
DECLARE
        p_widget_id             alias for $1;
BEGIN
        -- Erase the im_dynfield_widgets item associated with the id
        delete from im_dynfield_widgets
        where widget_id = p_widget_id;

        -- Erase all the privileges
        delete from acs_permissions
        where object_id = p_widget_id;

        PERFORM acs_object__delete(p_widget_id);
        return 0;
end;$body$ language 'plpgsql';


------------------------------------------------------
-- Delete bug_tracker DynFields on ]po[ objects
--
delete from im_dynfield_layout
where attribute_id in (
	select	attribute_id
	from	im_dynfield_attributes
	where widget_name in ('bt_project', 'bt_component', 'bt_components', 'bt_version')
);
     
delete from im_dynfield_attributes 
where widget_name in ('bt_project', 'bt_component', 'bt_components', 'bt_version');

select im_dynfield_widget__delete (
       (select widget_id from im_dynfield_widgets where widget_name = 'bt_project')
);
select im_dynfield_widget__delete (
       (select widget_id from im_dynfield_widgets where widget_name = 'bt_component')
);
select im_dynfield_widget__delete (
       (select widget_id from im_dynfield_widgets where widget_name = 'bt_components')
);
select im_dynfield_widget__delete (
       (select widget_id from im_dynfield_widgets where widget_name = 'bt_version')
);





create or replace function inline_0 ()
returns integer as $body$
DECLARE
	v_count		integer;
BEGIN
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_timesheet_tasks' and lower(column_name) = 'bt_component_id';
	IF v_count > 0 THEN
		alter table im_timesheet_tasks drop column bt_component_id cascade;
	END IF;

	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_projects' and lower(column_name) = 'bt_project_id';
	IF v_count > 0 THEN
		alter table im_projects drop column bt_project_id cascade;
	END IF;

	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_projects' and lower(column_name) = 'bt_found_in_version_id';
	IF v_count > 0 THEN
		alter table im_projects drop column bt_found_in_version_id cascade;
	END IF;

	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_projects' and lower(column_name) = 'bt_fix_for_version_id';
	IF v_count > 0 THEN
		alter table im_projects drop column bt_fix_for_version_id;
	END IF;

	RETURN 0;
END;$body$ language 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();


alter table im_projects drop column if exists bt_component_id;






-------------------------------------------------------------
-- Fixed support for postgresql 9.x
-- @author Victor Guerra (vguerra@gmail.com)

create or replace function acs_objects_context_id_up_tr () returns trigger as '
declare
        pair    record;
        outer_record record;
        inner_record record;
        security_context_root integer;
begin
  if new.object_id = old.object_id
     and ((new.context_id = old.context_id)
	  or (new.context_id is null and old.context_id is null))
     and new.security_inherit_p = old.security_inherit_p then
    return new;
  end if;

  -- Remove my old ancestors from my descendants.
  for outer_record in select object_id from acs_object_context_index where 
               ancestor_id = old.object_id and object_id <> old.object_id loop
    for inner_record in select ancestor_id from acs_object_context_index where
                 object_id = old.object_id and ancestor_id <> old.object_id loop
      delete from acs_object_context_index
      where object_id = outer_record.object_id
        and ancestor_id = inner_record.ancestor_id;
    end loop;
  end loop;

  -- Kill all my old ancestors.
  delete from acs_object_context_index
  where object_id = old.object_id;

  insert into acs_object_context_index
   (object_id, ancestor_id, n_generations)
  values
   (new.object_id, new.object_id, 0);

  if new.context_id is not null and new.security_inherit_p = ''t'' then
     -- Now insert my new ancestors for my descendants.
    for pair in select *
		 from acs_object_context_index
		 where ancestor_id = new.object_id 
    LOOP
      insert into acs_object_context_index
       (object_id, ancestor_id, n_generations)
      select
       pair.object_id, ancestor_id,
       n_generations + pair.n_generations + 1 as n_generations
      from acs_object_context_index
      where object_id = new.context_id;
    end loop;
  else
    security_context_root = acs__magic_object_id(''security_context_root'');
    if new.object_id != security_context_root then
    -- We need to make sure that new.OBJECT_ID and all of its
    -- children have security_context_root as an ancestor.
    for pair in  select *
		 from acs_object_context_index
		 where ancestor_id = new.object_id 
      LOOP
        insert into acs_object_context_index
         (object_id, ancestor_id, n_generations)
        values
         (pair.object_id, security_context_root, pair.n_generations + 1);
      end loop;
    end if;
  end if;

  return new;

end;' language 'plpgsql';



-------------------------------------------------------------
-- Remove any traces of bug-tracker from the data-model
--

ALTER TABLE ONLY public.im_timesheet_tasks DROP CONSTRAINT if exists im_times_tasks_bt_bug_fk;
ALTER TABLE ONLY public.im_projects DROP CONSTRAINT if exists im_project_bt_project_fk;
ALTER TABLE ONLY public.im_projects DROP CONSTRAINT if exists im_project_bt_found_ver_fk;
ALTER TABLE ONLY public.im_projects DROP CONSTRAINT if exists im_project_bt_fix_for_ver_fk;
ALTER TABLE ONLY public.bt_versions DROP CONSTRAINT if exists bt_versions_projects_fk;
ALTER TABLE ONLY public.bt_versions DROP CONSTRAINT if exists bt_versions_maintainer_fk;
ALTER TABLE ONLY public.bt_user_prefs DROP CONSTRAINT if exists bt_user_prefs_user_id_fk;
ALTER TABLE ONLY public.bt_user_prefs DROP CONSTRAINT if exists bt_user_prefs_project_fk;
ALTER TABLE ONLY public.bt_user_prefs DROP CONSTRAINT if exists bt_user_prefs_current_version_fk;
ALTER TABLE ONLY public.bt_projects DROP CONSTRAINT if exists bt_projects_maintainer_fk;
ALTER TABLE ONLY public.bt_projects DROP CONSTRAINT if exists bt_projects_keyword_fk;
ALTER TABLE ONLY public.bt_projects DROP CONSTRAINT if exists bt_projects_folder_fk;
ALTER TABLE ONLY public.bt_projects DROP CONSTRAINT if exists bt_projects_apm_packages_fk;
ALTER TABLE ONLY public.bt_patches DROP CONSTRAINT if exists bt_patchs_apply_to_version_fk;
ALTER TABLE ONLY public.bt_patches DROP CONSTRAINT if exists bt_patchs_applied_to_version_fk;
ALTER TABLE ONLY public.bt_patches DROP CONSTRAINT if exists bt_patches_vid_fk;
ALTER TABLE ONLY public.bt_patches DROP CONSTRAINT if exists bt_patches_projects_fk;
ALTER TABLE ONLY public.bt_patches DROP CONSTRAINT if exists bt_patches_pid_fk;
ALTER TABLE ONLY public.bt_patches DROP CONSTRAINT if exists bt_patches_components_fk;
ALTER TABLE ONLY public.bt_patch_bug_map DROP CONSTRAINT if exists bt_patch_bug_map_pid_fk;
ALTER TABLE ONLY public.bt_patch_bug_map DROP CONSTRAINT if exists bt_patch_bug_map_bid_fk;
ALTER TABLE ONLY public.bt_patch_actions DROP CONSTRAINT if exists bt_patch_actions_patch_fk;
ALTER TABLE ONLY public.bt_patch_actions DROP CONSTRAINT if exists bt_patch_actions_actor_fk;
ALTER TABLE ONLY public.bt_default_keywords DROP CONSTRAINT if exists bt_default_keywords_project_fk;
ALTER TABLE ONLY public.bt_default_keywords DROP CONSTRAINT if exists bt_default_keyw_parent_keyw_fk;
ALTER TABLE ONLY public.bt_default_keywords DROP CONSTRAINT if exists bt_default_keyw_keyword_fk;
ALTER TABLE ONLY public.bt_components DROP CONSTRAINT if exists bt_components_projects_fk;
ALTER TABLE ONLY public.bt_components DROP CONSTRAINT if exists bt_components_maintainer_fk;
ALTER TABLE ONLY public.bt_bug_revisions DROP CONSTRAINT if exists bt_bug_rev_found_in_version_fk;
ALTER TABLE ONLY public.bt_bug_revisions DROP CONSTRAINT if exists bt_bug_rev_fixed_in_version_fk;
ALTER TABLE ONLY public.bt_bug_revisions DROP CONSTRAINT if exists bt_bug_rev_fix_for_version_fk;
ALTER TABLE ONLY public.bt_bug_revisions DROP CONSTRAINT if exists bt_bug_rev_components_fk;
ALTER TABLE ONLY public.bt_bug_revisions DROP CONSTRAINT if exists bt_bug_rev_bug_id_fk;
ALTER TABLE ONLY public.bt_bugs DROP CONSTRAINT if exists bt_bug_bt_bug_fk;




DROP FUNCTION if exists bt_version__set_active(integer);
DROP FUNCTION if exists bt_project__new(integer);
DROP FUNCTION if exists bt_project__keywords_delete(integer, boolean);
DROP FUNCTION if exists bt_project__delete(integer);
DROP FUNCTION if exists bt_patch__new(
     integer, integer, integer, text, text, text, 
     text, integer, integer, character varying);
DROP FUNCTION if exists bt_patch__name(integer);
DROP FUNCTION if exists bt_patch__delete(integer);
DROP FUNCTION if exists bt_bug_revision__new(
     integer, integer, integer, integer, integer, 
     integer, character varying, character varying, 
     character varying, timestamp with time zone, 
     integer, character varying, integer);
DROP FUNCTION if exists bt_bug_revision__new(
     integer, integer, integer, integer, integer, 
     integer, character varying, character varying, 
     character varying, timestamp with time zone, 
     integer, character varying);
DROP FUNCTION if exists bt_bug__new(
     integer, integer, integer, integer, integer, 
     character varying, character varying, text, 
     character varying, timestamp with time zone, 
     integer, character varying, integer, 
     character varying, character varying, integer);
DROP FUNCTION if exists bt_bug__new(
     integer, integer, integer, integer, integer, 
     character varying, character varying, text, 
     character varying, timestamp with time zone, 
     integer, character varying, integer, 
     character varying, character varying);
DROP FUNCTION if exists bt_bug__delete(integer);

DROP RULE btbug_revisions_r ON public.btbug_revisionsi;
DROP FUNCTION if exists btbug_revisions_f(p_new btbug_revisionsi);


DROP INDEX if exists bt_patch_bug_map_patch_id_idx;
DROP INDEX if exists bt_patch_bug_map_bug_id_idx;
DROP INDEX if exists bt_default_keyw_parent_id_idx;
DROP INDEX if exists bt_default_keyw_keyword_id_idx;
DROP INDEX if exists bt_bugs_proj_id_fix_for_idx;
DROP INDEX if exists bt_bugs_proj_id_crea_date_idx;
DROP INDEX if exists bt_bugs_proj_id_bug_number_idx;
DROP INDEX if exists bt_bugs_fix_for_version_idx;
DROP INDEX if exists bt_bugs_creation_date_idx;
DROP INDEX if exists bt_bugs_bug_number_idx;

DROP TABLE if exists bt_versions;
DROP TABLE if exists bt_user_prefs;
DROP TABLE if exists bt_projects;
DROP TABLE if exists bt_patches;
DROP TABLE if exists bt_patch_bug_map;
DROP TABLE if exists bt_patch_actions;
DROP TABLE if exists bt_default_keywords;
DROP TABLE if exists bt_components;
DROP TABLE if exists bt_bugs;
DROP TABLE if exists bt_bug_revisions;

DROP VIEW if exists btbug_revisionsx;
DROP VIEW if exists btbug_revisionsi;
DROP TABLE if exists btbug_revisions;


delete from acs_object_type_tables 
where object_type in ('bt_bug', 'bt_bug_revision', 'bt_patch');


delete from acs_object_context_index
where object_id in (select object_id from acs_objects where object_type in ('bt_bug', 'bt_bug_revision', 'bt_patch'));
delete from acs_object_context_index
where ancestor_id in (select object_id from acs_objects where object_type in ('bt_bug', 'bt_bug_revision', 'bt_patch'));

update acs_objects set context_id = null
where context_id in (select object_id from acs_objects where object_type in ('bt_bug', 'bt_bug_revision', 'bt_patch'));

delete from cr_item_keyword_map
where item_id in (select object_id from acs_objects where object_type in ('bt_bug', 'bt_bug_revision', 'bt_patch'));

delete from workflow_cases
where object_id in (select object_id from acs_objects where object_type in ('bt_bug', 'bt_bug_revision', 'bt_patch'));

update cr_items set live_revision = null, latest_revision = null
where  	(live_revision is not null OR latest_revision is not null) and
	item_id in (select object_id from acs_objects where object_type in ('bt_bug', 'bt_bug_revision', 'bt_patch'));

delete from acs_permissions where object_id in (
	select object_id from acs_objects where object_type in ('bt_bug', 'bt_bug_revision', 'bt_patch')
);

-- Remove dependencies on im_fs_folders and it's auxillary tables
delete from im_fs_folder_perms where folder_id in (
	select folder_id from im_fs_folders where object_id in (
       		select object_id from acs_objects where object_type in ('bt_bug', 'bt_bug_revision', 'bt_patch')
	)
);
delete from im_fs_folder_status where folder_id in (
	select folder_id from im_fs_folders where object_id in (
       		select object_id from acs_objects where object_type in ('bt_bug', 'bt_bug_revision', 'bt_patch')
	)
);
delete from im_fs_folders where object_id in (
	select object_id from acs_objects where object_type in ('bt_bug', 'bt_bug_revision', 'bt_patch')
);

update acs_objects set context_id = null where context_id in (
	select object_id from acs_objects where object_type in ('bt_bug', 'bt_bug_revision', 'bt_patch')
);


delete from workflow_case_log where entry_id in (
	select object_id from acs_objects where object_type in ('bt_bug', 'bt_bug_revision', 'bt_patch')
);


-- select content_revision__delete(revision_id)
-- from cr_revisions 
-- where revision_id in (select object_id from acs_objects where object_type in ('workflow_case_log_entry'));

update acs_objects set context_id = null
where object_type = 'workflow_case_log_entry';

select content_item__del(item_id) from cr_items
where item_id in (select object_id from acs_objects where object_type in ('workflow_case_log_entry'));

select content_item__del(item_id) from cr_items
where item_id in (select object_id from acs_objects where object_type in ('bt_bug', 'bt_bug_revision', 'bt_patch'));



-- fraber 170210: There were issues with content_revisions still referenced by workflow_case_log_rev
delete from workflow_case_log_rev;



delete from acs_objects where object_type = 'workflow_case_log_entry';
delete from acs_objects where object_type in ('bt_bug', 'bt_bug_revision', 'bt_patch');


delete from im_rest_object_types where object_type in ('bt_bug', 'bt_bug_revision', 'bt_patch');
SELECT content_type__drop_type('bt_bug_revision', 't', 't');


update acs_objects set context_id = null
where context_id in (select package_id from apm_packages where package_key = 'bug-tracker');
select apm_package__delete(
       (select package_id from apm_packages where package_key = 'bug-tracker')
);



delete from acs_function_args 
where function = 'BT_BUG__NEW';


delete from acs_object_types where object_type = 'bt_patch';
-- ToDo: remove bt_patch


