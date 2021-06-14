-- upgrade-3.4.0.8.9-3.4.1.0.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-3.4.0.8.9-3.4.1.0.0.sql','');


-- Adding a fake object_id "hour_id" with an default
-- to take the value automatically from a sequence.
--
create or replace function inline_0 ()
returns integer as $body$
declare
        v_count                 integer;
begin
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_hours' and lower(column_name) = 'hour_id';
        if v_count > 0 then return 1; end if;

	create sequence im_hours_seq;
	alter table im_hours add column hour_id integer
	default nextval('im_hours_seq');

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();








-- Create a fake object type, because im_hour does not
-- "reference" acs_objects.
select acs_object_type__create_type (
	'im_hour',			-- object_type
	'Timesheet Hour',		-- pretty_name
	'Timesheet Hour',		-- pretty_plural
	'acs_object',			-- supertype
	'im_hours',			-- table_name
	'hour_id',			-- id_column
	null,				-- package_name
	'f',				-- abstract_p
	null,				-- type_extension_table
	'im_hour__name'			-- name_method
);

update acs_object_types set
	status_type_table = null,
	status_column = null,
	type_column = null
where object_type = 'im_hour';

