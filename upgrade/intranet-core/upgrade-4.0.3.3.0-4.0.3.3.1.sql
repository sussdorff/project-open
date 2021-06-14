-- upgrade-4.0.3.3.0-4.0.3.3.1.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.3.0-4.0.3.3.1.sql','');



-- Delete the source_language_id DynField
create or replace function inline_0 ()
returns integer as $body$
declare
	v_column_exists_p integer;
	dynfield_id	  integer;
begin
	select count(*) into v_column_exists_p from user_tab_columns
	where lower(table_name) = 'im_projects' and lower(column_name) = 'source_language_id';
	IF v_column_exists_p = 0 THEN

		select	attribute_id into dynfield_id
		from	im_dynfield_attributes
		where	acs_attribute_id in (
		       		select	attribute_id
				from	acs_attributes
				where	object_type = 'im_project' and
					attribute_name = 'source_language_id'
			);
		RAISE NOTICE 'dynfield_id=%', dynfield_id;
		perform im_dynfield_attribute__del(dynfield_id);
	END IF;

	return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

