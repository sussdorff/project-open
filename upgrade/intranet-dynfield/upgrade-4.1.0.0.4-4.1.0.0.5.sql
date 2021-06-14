-- upgrade-4.1.0.0.4-4.1.0.0.5.sql
SELECT acs_log__debug('/packages/intranet-dynfield/sql/postgresql/upgrade/upgrade-4.1.0.0.4-4.1.0.0.5.sql','');


create or replace function inline_0 () 
returns integer as $body$
DECLARE
	v_count		    integer;
	row		    RECORD;
BEGIN
	select	count(*) into v_count
	from	user_tab_columns
	where	lower(table_name) = 'acs_object_types' and
		lower(column_name) = 'status_category_type';

	IF v_count > 0 THEN return 1; END IF;

	alter table acs_object_types add column status_category_type varchar(50);

	RETURN 0;
END;
$body$ language 'plpgsql';
select inline_0();
drop function inline_0();




create or replace function inline_0 () 
returns integer as $body$
DECLARE
	v_count		    integer;
	row		    RECORD;
BEGIN
	select	count(*) into v_count
	from	user_tab_columns
	where	lower(table_name) = 'acs_object_types' and
		lower(column_name) = 'type_category_type';

	IF v_count > 0 THEN return 1; END IF;

	alter table acs_object_types add column type_category_type varchar(50);

	RETURN 0;
END;
$body$ language 'plpgsql';
select inline_0();
drop function inline_0();

