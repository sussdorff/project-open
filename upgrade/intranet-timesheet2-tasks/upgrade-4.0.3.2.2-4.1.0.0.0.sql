-- upgrade-4.0.3.2.2-4.1.0.0.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.0.3.2.2-4.1.0.0.0.sql','');

create or replace function inline_0 ()
returns integer as $BODY$
declare
        v_dynfield_id           integer;
begin

        -- function im_dynfield_attribute_new returns
        --      id of new dynfield when creation was successful
        --      '1' when dynfield already existed

        SELECT im_dynfield_attribute_new (
                'im_timesheet_task',                    -- p_object_type
                'milestone_p',                          -- p_column_name
                'Milestone',                            -- p_pretty_name
                'checkbox',                             -- p_widget_name
                'boolean',                              -- p_datatype
                'f',                                    -- p_required_p
                 0,                                     -- p_pos_y
                'f',                                    -- p_also_hard_coded_p
                'im_projects'                           -- p_table_name
        ) into v_dynfield_id ;

	-- set Attribute-Type-Map 
	begin
		insert into im_dynfield_type_attribute_map (attribute_id, object_type_id, display_mode, required_p) values (v_dynfield_id, 100, 'edit', 'f');
        exception when others then
	        RAISE WARNING 'Error setting Attribute-Type-Map for Dynfield ''timesheet_task::milestone_p''';
        end;	

        return 1;

end;$BODY$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

