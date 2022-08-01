-- upgrade-4.0.0.0.0-4.0.1.0.0.sql

SELECT acs_log__debug('/packages/intranet-cvs-integration/sql/postgresql/upgrade/upgrade-4.0.0.0.0-4.0.1.0.0.sql','');


-----------------------------------------------------------------------
-- drop the "cvs_system" dynfield and add the "cvs_repository" field

create or replace function inline_0 ()
returns integer as $body$
declare
	v_attribute_id		 integer;
begin
	select	attribute_id into v_attribute_id
	from	im_dynfield_attributes
	where	acs_attribute_id in (
			select attribute_id
			from acs_attributes
			where object_type = 'im_conf_item' and attribute_name = 'cvs_system'
		);
	IF v_attribute_id is not null THEN
		select im_dynfield_attribute__del(v_attribute_id);
	END IF;

	return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



create or replace function inline_0 ()
returns integer as $body$
declare
	v_count		 integer;
begin
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_conf_items' and lower(column_name) = 'cvs_system';
	IF v_count = 0 THEN return 1; END IF;

	alter table im_conf_items drop column cvs_system;

	return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



-----------------------------------------------------------------------
-- Create the new attribute
create or replace function inline_0 ()
returns integer as $body$
declare
	v_count		 integer;
begin
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_conf_items' and lower(column_name) = 'cvs_repository';
	IF v_count > 0 THEN return 1; END IF;

	alter table im_conf_items add cvs_repository text;

	return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

SELECT im_dynfield_attribute_new ('im_conf_item', 'cvs_repository', 'CVS Repository', 'textbox_medium', 'string', 'f');


-----------------------------------------------------------------------
-- Set visibility for all cvs_* field to CVS repositories only

-- Delete any visibility of cvs_* fields
delete from im_dynfield_type_attribute_map
where attribute_id in (
	select	da.attribute_id
	from	im_dynfield_attributes da,
		acs_attributes aa
	where	da.acs_attribute_id = aa.attribute_id and
		aa.object_type = 'im_conf_item' and
		aa.attribute_name like 'cvs_%'
);

-- Selectively add the visibility "edit" to the ConfItem type "CVS Repository"
insert into im_dynfield_type_attribute_map (
	select	da.attribute_id,
		12400 as object_type_id,
		'edit' as display_mode
	from	im_dynfield_attributes da,
		acs_attributes aa
	where	da.acs_attribute_id = aa.attribute_id and
		aa.object_type = 'im_conf_item' and
		aa.attribute_name like 'cvs_%'
);

