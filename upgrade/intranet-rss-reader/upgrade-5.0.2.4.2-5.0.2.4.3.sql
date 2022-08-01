-- upgrade-5.0.2.4.2-5.0.2.4.3.sql
SELECT acs_log__debug('/packages/intranet-riskmanagement/sql/postgresql/upgrade/upgrade-5.0.2.4.2-5.0.2.4.3.sql','');







create or replace function inline_0 () 
returns integer as $body$
DECLARE
	v_count			integer;
BEGIN
	-- Check if colum exists in the database
	select	count(*) into v_count from acs_object_type_tables
	where	object_type = 'im_risk' and table_name = 'acs_objects';
	IF v_count > 0  THEN return 1; END IF; 

	insert into acs_object_type_tables (object_type,table_name,id_column)
	values ('im_risk', 'acs_objects', 'object_id');

	return 0;
END;$body$ language 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();

