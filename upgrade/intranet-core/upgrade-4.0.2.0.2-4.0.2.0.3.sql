-- upgrade--4.0.2.0.2-4.0.2.0.3.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.2.0.2-4.0.2.0.3.sql','');


create or replace function inline_0 ()
returns integer as $body$
declare
	v_count		 integer;
begin
	select count(*) into v_count from acs_object_type_tables
	where object_type = 'user' and lower(table_name) = 'user_preferences';
	IF v_count = 0 THEN
		insert into acs_object_type_tables VALUES ('user', 'user_preferences', 'user_id');
	END IF;

	select count(*) into v_count from acs_object_type_tables
	where object_type = 'user' and lower(table_name) = 'persons';
	IF v_count = 0 THEN
		insert into acs_object_type_tables VALUES ('user', 'persons', 'person_id');
	END IF;

	select count(*) into v_count from acs_object_type_tables
	where object_type = 'user' and lower(table_name) = 'users_contact';
	IF v_count = 0 THEN
		insert into acs_object_type_tables VALUES ('user', 'users_contact', 'user_id');
	END IF;

	select count(*) into v_count from acs_object_type_tables
	where object_type = 'user' and lower(table_name) = 'parties';
	IF v_count = 0 THEN
		insert into acs_object_type_tables VALUES ('user', 'parties', 'party_id');
	END IF;

	select count(*) into v_count from acs_object_type_tables
	where object_type = 'user' and lower(table_name) = 'im_employees';
	IF v_count = 0 THEN
		insert into acs_object_type_tables VALUES ('user', 'im_employees', 'employee_id');
	END IF;

	select count(*) into v_count from acs_object_type_tables
	where object_type = 'user' and lower(table_name) = 'users';
	IF v_count = 0 THEN
		insert into acs_object_type_tables VALUES ('user', 'users', 'user_id');
	END IF;

	return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


