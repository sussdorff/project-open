SELECT acs_log__debug('/packages/intranet-dynfield/sql/postgresql/upgrade/upgrade-4.1.0.0.0-4.1.0.0.1.sql','');



------------------------------------------------------
-- help_url 
------------------------------------------------------

create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select	count(*) into v_count
	from	user_tab_columns 
	where	lower(table_name) = ''im_dynfield_type_attribute_map'' and 
		lower(column_name) = ''help_url'';
	IF 0 != v_count THEN return 0; END IF;

	alter table im_dynfield_type_attribute_map
	add column help_url text;

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

comment on column im_dynfield_type_attribute_map.help_url is 'This is the help_url for this attribute. Though usually it is the same for all object_type_ids (and this is how it is saved with im_dynfield::attribute::add) it is possible to make it differ depending on the TYPE (category_id) of the object';

