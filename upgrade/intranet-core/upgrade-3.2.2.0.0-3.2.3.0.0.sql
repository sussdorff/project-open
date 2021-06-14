-- upgrade-3.2.3.0.0-3.2.3.0.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.2.2.0.0-3.2.3.0.0.sql','');


\i upgrade-3.0.0.0.first.sql


create or replace function im_country_from_code (varchar)
returns varchar as '
DECLARE
	p_cc		alias for $1;
	v_country	varchar;
BEGIN
	select country_name into v_country
	from country_codes where iso = p_cc;
	return v_country;
END;' language 'plpgsql';


-- Make sure the categories counter is high enough
-- The space below 1000000 is reserved for constants now.
create or replace function inline_0 ()
returns integer as '
declare
	v_max		integer;
begin
	select nextval(''im_categories_seq'') into v_max;
	IF v_max < 10000000 THEN
		PERFORM pg_catalog.setval(''im_categories_seq'', 10000000, true);
	END IF;
	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



-- -------------------------------------------------------------
-- Add field company_project_id if it doesn't exist already
-- (project-translation)

create or replace function inline_0 ()
returns integer as '
declare
	v_attrib_name		varchar;
	v_attrib_pretty		varchar;
	v_table			varchar;
	v_object		varchar;

	v_acs_attrib_id	integer;
	v_attrib_id		integer;
	v_count			integer;
begin
	v_attrib_name := ''company_project_nr'';
	v_attrib_pretty := ''Customer Project Nr'';
	v_object := ''im_project'';
	v_table := ''im_projects'';

	select count(*) into v_count from acs_attributes
	where attribute_name = v_attrib_name;
	IF 0 != v_count THEN return 0; END IF;

	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_project'' and table_name = ''im_projects'';
	IF v_count = 0 THEN
		insert into acs_object_type_tables (object_type, table_name, id_column)
		values (''im_project'', ''im_projects'', ''project_id'');
	END IF;

	select  count(*) into v_count from user_tab_columns
	where lower(table_name) = ''im_projects'' and lower(column_name) = ''company_project_nr'';
	IF v_count = 0 THEN
		alter table im_projects add company_project_nr varchar(50);
	END IF;

	v_acs_attrib_id := acs_attribute__create_attribute (
		v_object,
		v_attrib_name,
		''string'',
		v_attrib_pretty,
		v_attrib_pretty,
		v_table,
		NULL, NULL, ''0'', ''1'',
		NULL, NULL, NULL
	);
	v_attrib_id := acs_object__new (
		null,
		''im_dynfield_attribute'',
		now(),
		null, null, null
	);
	insert into im_dynfield_attributes (
		attribute_id, acs_attribute_id, widget_name, deprecated_p
	) values (
		v_attrib_id, v_acs_attrib_id, ''textbox_medium'', ''f''
	);
	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


