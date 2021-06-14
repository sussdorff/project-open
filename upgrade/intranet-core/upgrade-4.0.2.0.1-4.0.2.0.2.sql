-- upgrade-4.0.2.0.1-4.0.2.0.2.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.2.0.1-4.0.2.0.2.sql','');

create or replace function im_category_path_to_category (integer, integer)
returns varchar as $body$
declare
	p_cat_id		alias for $1;
	p_loop			alias for $2;
	v_cat			varchar;
	v_path			varchar;
	v_longest_path		varchar;
	row			RECORD;
BEGIN
	-- Avoid infinite loops...
	IF p_loop > 5 THEN return ''; END IF;

	-- Add leading zeros until code has 8 digits.
	-- This way all category codes have the same length.
	v_cat := p_cat_id;
	WHILE length(v_cat) < 8 LOOP v_cat := '0'||v_cat; END LOOP;

	-- Look out for the parent with the longest path
	v_longest_path := '';
	FOR row IN
		-- Get all (enabled) parents
		select	ch.parent_id
		from	im_category_hierarchy ch,
			im_categories c
		where	ch.child_id = p_cat_id and
			ch.parent_id = c.category_id and
			ch.parent_id != p_cat_id and
			(c.enabled_p is null or c.enabled_p = 't')
	LOOP
		v_path = im_category_path_to_category(row.parent_id, p_loop+1);
		IF v_longest_path = '' THEN v_longest_path := v_path; END IF;
		IF length(v_path) > length(v_longest_path) THEN v_longest_path := v_path; END IF;
	END LOOP;

	RETURN v_longest_path || v_cat;
end;$body$ language 'plpgsql';




create or replace function im_category_parents (
	integer
) returns setof integer as $body$
declare
	p_cat			alias for $1;
	v_cat			integer;
	row			RECORD;
BEGIN
	FOR row IN
		select	c.category_id
		from	im_categories c,
			im_category_hierarchy h
		where	c.category_id = h.parent_id and
			h.child_id = p_cat and
			(c.enabled_p = 't' OR c.enabled_p is NULL)
	LOOP
		RETURN NEXT row.category_id;
	END LOOP;

	RETURN;
end;$body$ language 'plpgsql';

