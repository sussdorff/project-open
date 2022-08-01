-- upgrade-5.0.2.3.4-5.0.2.3.5.sql

SELECT acs_log__debug('/packages/intranet-search-pg/sql/postgresql/upgrade/upgrade-5.0.2.3.4-5.0.2.3.5.sql','');

create or replace function im_search_update (integer, varchar, integer, varchar)
returns integer as $$
declare
	p_object_id	alias for $1;
	p_object_type	alias for $2;
	p_biz_object_id	alias for $3;
	p_text		alias for $4;

	v_object_type_id	integer;
	v_exists_p		integer;
	v_text			varchar;
begin
	select	object_type_id into v_object_type_id
	from	im_search_object_types
	where	object_type = p_object_type;

	-- Add the name for the business object to the search string
	v_text := acs_object__name(p_biz_object_id) || ' ' || p_text;

	select	count(*) into v_exists_p
	from	im_search_objects
	where	object_id = p_object_id and object_type_id = v_object_type_id;

	if v_exists_p = 1 then
		update im_search_objects set
			object_type_id	= v_object_type_id,
			biz_object_id	= p_biz_object_id,
			fti		= to_tsvector('default', norm_text(v_text))
		where	object_id	= p_object_id
			and object_type_id = v_object_type_id;
	else
		select	count(*) into v_exists_p
		from	acs_objects
		where	object_id = p_biz_object_id;
	
		if v_exists_p = 1 then 
			insert into im_search_objects (
				object_id,
				object_type_id,
				biz_object_id,
				fti
			) values (
				p_object_id,
				v_object_type_id,
				p_biz_object_id,
				to_tsvector('default', norm_text(v_text))
			);
		end if;
	end if;

	return 0;
end;$$ language 'plpgsql';
