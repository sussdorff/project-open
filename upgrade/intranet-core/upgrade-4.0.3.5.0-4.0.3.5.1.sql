-- upgrade-4.0.3.5.0-4.0.3.5.1.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.5.0-4.0.3.5.1.sql','');


create or replace function inline_0 ()
returns integer as $body$
declare
	v_count  integer;
begin
	-- Drop the old unique constraints
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_projects' and lower(column_name) = 'company_contact_id';
	IF v_count > 0 THEN 
		return 1;
	END IF;

	alter table im_projects
	add column company_contact_id integer
	constraint im_project_company_contact_fk
	references users;

	return 0;
end;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();


