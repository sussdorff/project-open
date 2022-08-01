-- upgrade-5.0.2.4.2-5.0.2.4.3.sql

SELECT acs_log__debug('/packages/intranet-confdb/sql/postgresql/upgrade/upgrade-5.0.2.4.2-5.0.2.4.3.sql','');

-- Returns a space separated list of the conf_item_nr of the parents
CREATE or REPLACE FUNCTION im_conf_item_nr_parent_list(integer, varchar, integer)
RETURNS varchar as $body$
DECLARE
	p_conf_item_id		alias for $1;
	p_spacer		alias for $2;
	p_level			alias for $3;

	v_result		varchar;
	v_conf_item_nr		varchar;
	v_parent_id		integer;
BEGIN
	-- End of recursion.
	IF p_conf_item_id is NULL THEN RETURN ''; END IF;

	-- Error checking to avoid infinite loops within the DB...
	IF p_level > 20 THEN RETURN '- infinite loop with conf_item_id='||p_conf_item_id; END IF;

	-- Get the NR of the current project plus the parent_id
	select	conf_item_nr, conf_item_parent_id
	into	v_conf_item_nr, v_parent_id
	from	im_conf_items
	where	conf_item_id = p_conf_item_id;

	-- Recurse for the parent projects
	v_result = im_conf_item_nr_parent_list(v_parent_id, p_spacer, p_level+1);
	IF v_result != '' THEN v_result := v_result || p_spacer; END IF;
	v_result := v_result || v_conf_item_nr;

	RETURN v_result;
END; $body$ LANGUAGE 'plpgsql';


-- Shortcut function with only one argument
CREATE or REPLACE FUNCTION im_conf_item_nr_parent_list(integer)
RETURNS varchar as $body$
DECLARE
	p_conf_item_id		alias for $1;
BEGIN
	RETURN im_conf_item_nr_parent_list(p_conf_item_id, ' ', 0);
END; $body$ LANGUAGE 'plpgsql';

