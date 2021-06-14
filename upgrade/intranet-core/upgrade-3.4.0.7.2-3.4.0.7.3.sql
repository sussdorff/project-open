-- upgrade-3.4.0.7.2-3.4.0.7.3.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.7.2-3.4.0.7.3.sql','');



-- Re-create the person__new function.
-- There was an issue with one SaaS customer where this routines
-- wasn't compiled correctly by PG for some reason.
--
create or replace function person__new (integer,varchar,timestamptz,integer,varchar,varchar,varchar,varchar,varchar,integer)
returns integer as '
declare
  new__person_id              alias for $1;  -- default null  
  new__object_type            alias for $2;  -- default ''person''
  new__creation_date          alias for $3;  -- default now()
  new__creation_user          alias for $4;  -- default null
  new__creation_ip            alias for $5;  -- default null
  new__email                  alias for $6;  
  new__url                    alias for $7;  -- default null
  new__first_names            alias for $8; 
  new__last_name              alias for $9;  
  new__context_id             alias for $10; -- default null 
  v_person_id                 persons.person_id%TYPE;
begin
  v_person_id :=
   party__new(new__person_id, new__object_type,
             new__creation_date, new__creation_user, new__creation_ip,
             new__email, new__url, new__context_id);

  insert into persons
   (person_id, first_names, last_name)
  values
   (v_person_id, new__first_names, new__last_name);

  return v_person_id;
  
end;' language 'plpgsql';
 


-- http://fisheye.openacs.org/browse/OpenACS/openacs-4/packages/ref-countries/sql/common/ref-country-data.sql?r=1.1


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from country_codes where ISO = ''AN'';
	IF v_count = 0 THEN 
		insert into country_codes (iso,country_name) values (''AN'', ''Netherlands Antilles'');
	END IF;

	select count(*) into v_count from country_codes where ISO = ''NP'';
	IF v_count = 0 THEN 
		insert into country_codes (iso,country_name) values (''NP'', ''Nepal'');
	END IF;

	select count(*) into v_count from country_codes where ISO = ''MK'';
	IF v_count = 0 THEN 
		insert into country_codes (iso,country_name) values (''MK'', ''Macedonia, TFYRO'');
	END IF;

	select count(*) into v_count from country_codes where ISO = ''KP'';
	IF v_count = 0 THEN 
		insert into country_codes (iso,country_name) values (''KP'', ''Korea, Democratic Peoples Republic Of'');
	END IF;

	select count(*) into v_count from country_codes where ISO = ''KR'';
	IF v_count = 0 THEN 
		insert into country_codes (iso,country_name) values (''KR'', ''Korea, Republic Of'');
	END IF;

	select count(*) into v_count from country_codes where ISO = ''AM'';
	IF v_count = 0 THEN 
		insert into country_codes (iso,country_name) values (''AM'', ''Armenia'');
	END IF;

	select count(*) into v_count from country_codes where ISO = ''KY'';
	IF v_count = 0 THEN 
		insert into country_codes (iso,country_name) values (''KY'', ''Cayman Islands''); 
	END IF;

	select count(*) into v_count from country_codes where ISO = ''PA'';
	IF v_count = 0 THEN 
		insert into country_codes (iso,country_name) values (''PA'', ''Panama'');
	END IF;

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();
