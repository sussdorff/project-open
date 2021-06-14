-- upgrade-3.2.3.0.0-3.2.4.0.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.2.3.0.0-3.2.4.0.0.sql','');


\i upgrade-3.0.0.0.first.sql


------------------------------------------------------
-- del_module didnt delete GUI user mapping
--
create or replace function im_component_plugin__del_module (varchar) returns integer as '
DECLARE
        p_module_name   alias for $1;
        row             RECORD;
BEGIN
        for row in
            select plugin_id
            from im_component_plugins
            where package_name = p_module_name
        loop
            delete from im_component_plugin_user_map
            where plugin_id = row.plugin_id;

            PERFORM im_component_plugin__delete(row.plugin_id);
        end loop;

        return 0;
end;' language 'plpgsql';



-------------------------------------------------------------
-- Helper function/view to return all sub-categories of a main category
-------------------------------------------------------------

create or replace function im_sub_categories (
	integer
) returns setof integer as '
declare
	p_cat			alias for $1;
	v_cat			integer;
	row			RECORD;
BEGIN
	FOR row IN
		select  child_id
		from    im_category_hierarchy
		where   parent_id = p_cat
	    UNION
		select  p_cat
	LOOP
	    RETURN NEXT row.child_id;
	END LOOP;

	RETURN;
end;' language 'plpgsql';

