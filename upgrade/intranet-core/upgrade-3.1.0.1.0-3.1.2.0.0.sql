-- upgrade-3.1.0.1.0-3.1.2.0.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.1.0.1.0-3.1.2.0.0.sql','');


\i upgrade-3.0.0.0.first.sql


-- Add a privilege to allow all users to edit projects
--
select acs_privilege__create_privilege('edit_projects_all','Edit All Projects','Edit All Projects');
select acs_privilege__add_child('admin', 'edit_projects_all');


-- -----------------------------------------------------
-- Add company_contact_id to im_projects 
-- if it doesnt exist yet

create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
        select	count(*) into v_count from user_tab_columns
        where	upper(table_name) = upper(''im_projects'') and upper(column_name) = upper(''company_contact_id'');
        if v_count > 0 then return 0; end if;

	alter table im_projects add company_contact_id integer;
	alter table im_projects add FOREIGN KEY (company_contact_id) references users;

    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();
