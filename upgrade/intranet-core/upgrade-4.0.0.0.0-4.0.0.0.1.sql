-- upgrade-4.0.0.0.0-4.0.0.0.1.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.0.0.0-4.0.0.0.1.sql','');

create or replace function im_name_from_id(double precision)
returns varchar as '
DECLARE
	v_result	alias for $1;
BEGIN
	return v_result::varchar;
END;' language 'plpgsql';



-- Fixed issue deleting authorities by
-- deleting parameters now
--
create or replace function authority__del (integer)
returns integer as '
declare
  p_authority_id            alias for $1;
begin

  delete from auth_driver_params
  where authority_id = p_authority_id;

  perform acs_object__delete(p_authority_id);

  return 0; 
end;' language 'plpgsql';





-- Returns a space separated list of the project_nr of the parents
CREATE or REPLACE FUNCTION im_project_nr_parent_list(integer, varchar, integer)
RETURNS varchar as $body$
DECLARE
	p_project_id		alias for $1;
	p_spacer		alias for $2;
	p_level			alias for $3;

	v_result		varchar;
	v_project_nr		varchar;
	v_parent_id		integer;
BEGIN
	-- End of recursion.
	IF p_project_id is NULL THEN RETURN ''; END IF;

	-- Error checking to avoid infinite loops within the DB...
	IF p_level > 10 THEN RETURN '- infinite loop with project_id='||p_project_id; END IF;

	-- Get the NR of the current project plus the parent_id
	select	p.project_nr, p.parent_id
	into	v_project_nr, v_parent_id
	from	im_projects p 
	where	p.project_id = p_project_id;

	-- Recurse for the parent projects
	v_result = im_project_nr_parent_list(v_parent_id, p_spacer, p_level+1);
	IF v_result != '' THEN v_result := v_result || p_spacer; END IF;
	v_result := v_result || v_project_nr;

	RETURN v_result;
END; $body$ LANGUAGE 'plpgsql';


-- Shortcut function with only one argument
CREATE or REPLACE FUNCTION im_project_nr_parent_list(integer)
RETURNS varchar as $body$
DECLARE
	p_project_id		alias for $1;
BEGIN
	RETURN im_project_nr_parent_list(p_project_id, ' ', 0);
END; $body$ LANGUAGE 'plpgsql';

