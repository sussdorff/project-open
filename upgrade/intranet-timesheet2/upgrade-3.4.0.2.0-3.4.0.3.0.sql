-- upgrade-3.4.0.2.0-3.4.0.3.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-3.4.0.2.0-3.4.0.3.0.sql','');



-- Add an "internal_note" field to hours
-- to allow to distinguish ugly+real vs. clean+artificial comments
create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
        select count(*) into v_count from user_tab_columns
	where table_name = ''IM_HOURS'' and column_name = ''INTERNAL_NOTE'';
        if v_count > 0 then return 0; end if;

	alter table im_hours
	add internal_note text;

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




-- Add a localized short status to absences
update lang_messages 
set message = 'Absent (%absence_status_3letter_l10n%):' 
where package_key = 'intranet-timesheet2' and message_key = 'Absent_1' and locale like 'en_%';



-- add material_id to im_hours
create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
        select count(*) into v_count from user_tab_columns
	where table_name = ''IM_HOURS'' and column_name = ''MATERIAL_ID'';
        if v_count > 0 then return 0; end if;

	alter table im_hours 
	add material_id integer
	constraint im_hours_material_fk
	references im_materials;

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


-- ------------------------------------------------------------
-- Create add_hours_all privilege that allows the user to modify
-- other user's hours.
-- Consolidated from "edit_hours_all", so we're copying these perms.
-- ------------------------------------------------------------

-- New Privilege to allow accounting guys to change hours
select acs_privilege__create_privilege('add_hours_all','Edit Hours All','Edit Hours All');
select acs_privilege__add_child('admin', 'add_hours_all');

select im_priv_create('add_hours_all', 'Accounting');
select im_priv_create('add_hours_all', 'P/O Admins');
select im_priv_create('add_hours_all', 'Senior Managers');


-- copy privs from edit_hours_all to add_hours_all
create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
	row			record;
begin
	FOR row IN
		select	object_id,
			grantee_id
		from	acs_permissions
		where	privilege = ''edit_hours_all''
	LOOP
		PERFORM acs_permission__grant_permission(row.object_id, row.grantee_id, ''add_hours_all'');
	END LOOP;

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


-- Delete the old edit_hours_all privilege
--
delete from acs_permissions where privilege = 'edit_hours_all';
delete from acs_privilege_hierarchy where privilege = 'edit_hours_all';
delete from acs_privilege_hierarchy where child_privilege = 'edit_hours_all';
select acs_privilege__drop_privilege('edit_hours_all');

