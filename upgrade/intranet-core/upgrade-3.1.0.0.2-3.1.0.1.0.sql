-- upgrade-3.1.0.0.2-3.1.0.1.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.1.0.0.2-3.1.0.1.0.sql','');

\i upgrade-3.0.0.0.first.sql


-- Add a function to determine the type_id of a "im_biz_object"
-- It's a bit ugly to do this via SWITCH, but there aren't many
-- new "Biz Objects" to be added to the system...

create or replace function im_biz_object__type (integer)
returns integer as '
declare
        p_object_id       	alias for $1;
	v_object_type		varchar;
	v_biz_object_type_id	integer;
begin

	-- get the object type	
	select	object_type
	into	v_object_type
	from	acs_objects
	where	object_id = p_object_id;

	-- Initialize the return value
	v_biz_object_type_id = null;

	IF ''im_project'' = v_object_type THEN

		select	project_type_id
		into	v_biz_object_type_id
		from	im_projects
		where	project_id = p_object_id;
		
	ELSIF ''im_company'' = v_object_type THEN

		select	company_type_id
		into	v_biz_object_type_id
		from	im_companies
		where	company_id = p_object_id;

	END IF;

        return v_biz_object_type_id;

end;' language 'plpgsql';


