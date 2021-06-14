-- upgrade-3.4.0.3.0-3.4.0.3.1.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.3.0-3.4.0.3.1.sql','');


CREATE OR REPLACE FUNCTION im_category__new (
        integer, varchar, varchar, varchar
) RETURNS integer as '
DECLARE
        p_category_id           alias for $1;
        p_category              alias for $2;
        p_category_type         alias for $3;
        p_description           alias for $4;
BEGIN
        RETURN im_category_new(p_category_id, p_category, p_category_type, p_description);
end;' language 'plpgsql';

-- compatibility for WF calls
CREATE OR REPLACE FUNCTION im_biz_object__set_status_id (integer, varchar, integer) RETURNS integer AS '
DECLARE
	p_object_id		alias for $1;
	p_dummy			alias for $2;
	p_status_id		alias for $3;
BEGIN
	return im_biz_object__set_status_id (p_object_id, p_status_id::integer);
END;' language 'plpgsql';


-- Milestone project type.
SELECT im_category_new (2504, 'Milestone', 'Intranet Project Type');
update im_categories set enabled_p = 'f' 
where	category = 'Milestone' and
	category_type = 'Intranet Project Type';





-- Fix DynField issue with database "float"
CREATE OR REPLACE Function inline_0()
RETURNS character AS '
DECLARE
	v_count		integer;
BEGIN
	select count(*)	into v_count from acs_datatypes where datatype = ''float'';
	IF v_count > 0 THEN return 1; END IF;

	insert into acs_datatypes (datatype) values (''float'');
	return 0;
END;' LANGUAGE 'plpgsql';
select inline_0();
drop function inline_0();


