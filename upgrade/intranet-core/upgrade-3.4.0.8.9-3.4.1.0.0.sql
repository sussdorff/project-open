-- upgrade-3.4.0.8.9-3.4.1.0.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.8.9-3.4.1.0.0.sql','');


-- Add a l10n message
SELECT im_lang_add_message('en_US','intranet-core','Category_Type','Category Type');



-- Introduce default_tax field
create or replace function inline_0 ()
returns integer as '
DECLARE
	v_count		integer;
BEGIN
	select count(*) into v_count from user_tab_columns
	where  lower(table_name) = ''im_companies'' and lower(column_name) = ''default_tax'';
	IF v_count > 0 THEN return 0; END IF;

	alter table im_companies add default_tax numeric(12,1);
	alter table im_companies alter column default_tax set default 0;

	return 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();



-- Defines a function to calculate a tree_sortkey for categories


create or replace function im_category_path_to_category (integer)
returns varchar as $body$
BEGIN
	RETURN im_category_path_to_category($1,0);
END;
$body$ language 'plpgsql';


create or replace function im_category_path_to_category (integer, integer)
returns varchar as $body$
declare
	p_cat_id		alias for $1;
	p_loop			alias for $2;
	v_cat			varchar;
	v_path			varchar;
	v_parent_path		varchar;
	row			RECORD;
BEGIN
	-- Avoid infinite loops...
	IF p_loop > 10 THEN return 0; END IF;

	v_cat := p_cat_id;
	WHILE length(v_cat) < 8 LOOP v_cat := '0'||v_cat; END LOOP;

	v_path := v_cat;
	FOR row IN
		select	parent_id
		from	im_category_hierarchy
		where	child_id = p_cat_id
	LOOP
		v_path = im_category_path_to_category(row.parent_id, p_loop+1) || v_cat;
	END LOOP;

	RETURN v_path;
end;$body$ language 'plpgsql';

-- Test query
-- select im_category_path_to_category (83);

