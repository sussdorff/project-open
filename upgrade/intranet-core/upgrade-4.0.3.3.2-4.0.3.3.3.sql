-- upgrade-4.0.3.3.2-4.0.3.3.3.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.3.2-4.0.3.3.3.sql','');

create or replace function inline_0 () returns integer as $BODY$ 
    DECLARE
	v_plugin_id		integer;
    BEGIN
   
	select  plugin_id
        into    v_plugin_id
        from    im_component_plugins pl
        where   plugin_name = 'Project Hierarchy';

    	IF v_plugin_id is null THEN 
		RETURN 0; 
	ELSE   	
	   	update 	im_component_plugins 
		set 	component_tcl = 'im_project_hierarchy_component -project_id $project_id -return_url $return_url -subproject_status_id $subproject_status_id'
		where 	plugin_id = v_plugin_id;
		RETURN 1;
	END IF;
   END; $BODY$ language 'plpgsql';

select inline_0();
drop function inline_0();

