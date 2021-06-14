-- upgrade-3.4.0.7.5-3.4.0.7.6.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.7.5-3.4.0.7.6.sql','');

-- Fix the "table" attribute of the "url" attribute of party.

create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin

	select count(*) into v_count from acs_object_type_tables where object_type = ''party'' and table_name = ''parties'';
	IF v_count != 0 THEN
		update acs_attributes set table_name = ''parties'' where object_type = ''party'' and attribute_name = ''url'';
	END IF;
        RETURN 0;

end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


-- Returns a TCL list of company_id suitable to stuff into a
-- TCL hash array of all companies associated to a specific user.
create or replace function im_company_list_for_user_html (integer) returns varchar as '
DECLARE
	p_user_id	alias for $1;

	v_html		varchar;
	row		RECORD;
BEGIN
	v_html := '''';
	FOR row IN
		select	c.company_id
		from	im_companies c,
			acs_rels r
		where	r.object_id_one = c.company_id and
			r.object_id_two = p_user_id
		order by
			lower(c.company_name)
	LOOP
		IF '''' != v_html THEN v_html := v_html || '' ''; END IF;
		v_html := v_html || row.company_id;
	END LOOP;

	return v_html;
end;' language 'plpgsql';

