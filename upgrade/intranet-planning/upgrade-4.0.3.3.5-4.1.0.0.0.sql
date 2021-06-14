-- upgrade-4.0.3.3.5-4.1.0.0.0.sql

SELECT acs_log__debug('/packages/intranet-planning/sql/postgresql/upgrade/upgrade-4.0.3.3.5-4.1.0.0.0.sql','');

CREATE OR REPLACE FUNCTION inline_1 ()
RETURNS INTEGER AS $BODY$
DECLARE
        v_plugin_id             INTEGER;
        v_employee_group_id     INTEGER;
BEGIN
 
        SELECT group_id INTO v_employee_group_id FROM groups WHERE group_name = 'Employees';
 
        SELECT  im_component_plugin__new (
        NULL,                           -- plugin_id
        'acs_object',                   -- object_type
        now(),                          -- creation_date
        NULL,                           -- creation_user
        NULL,                           -- creation_ip
        NULL,                           -- context_id
        'Planning Component (Table View)',  -- plugin_name
        'intranet-planning',                -- package_name
        'left',                        	-- location
        '/intranet/projects/view',      -- page_url
        NULL,                           -- view_name
        20,                             -- sort_order
        'im_planning_table_view_component -object_id $project_id'   -- component_tcl
        ) INTO v_plugin_id;
 
        -- Set title
        UPDATE im_component_plugins SET title_tcl = 'lang::message::lookup "" intranet-planning.Planning "Planning"' WHERE plugin_id = v_plugin_id;

        -- Disable by default 
        UPDATE im_component_plugins SET enabled_p = 'f' WHERE plugin_id = v_plugin_id;

         -- Permissions
        PERFORM im_grant_permission(v_plugin_id, v_employee_group_id, 'read');
 
        RETURN 0;
 
END;$BODY$ LANGUAGE 'plpgsql';
SELECT inline_1 ();
DROP FUNCTION inline_1();


CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS $BODY$

declare
        v_count                 integer;
begin

        select count(*) into v_count from user_tab_columns
        where lower(table_name) = 'im_planning_items' and lower(column_name) = 'item_currency';

        IF      0 = v_count
        THEN
                alter table im_planning_items add column item_currency character(3);
                return 0;
        END IF;
        return 1;

end;$BODY$ LANGUAGE 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();


-- View Planning Items
CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS $body$
DECLARE
        v_count                 INTEGER;
        v_next_column_id        INTEGER;
BEGIN
        BEGIN
                INSERT INTO im_views (view_id, view_name, visible_for, view_type_id) VALUES (990, 'planning_items_default', '', 1400);
        EXCEPTION
                WHEN others THEN
                RAISE NOTICE 'Skipped creating view, pls. check if view with view_id=300 does already exists';
                RETURN 0;
        END;
 
        SELECT MAX(column_id)+1 INTO v_next_column_id FROM im_view_columns;
 
        BEGIN
		-- item_id
                INSERT INTO im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
                extra_select, extra_where, sort_order, visible_for) VALUES (v_next_column_id,990,NULL,'item_id',
                '$item_id','','',10,'');

		--item_note  
                INSERT INTO im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
                extra_select, extra_where, sort_order, visible_for) VALUES (v_next_column_id+1,990,NULL,'item_note',
                '$item_note','','',20,'');

		-- project_name
                INSERT INTO im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
                extra_select, extra_where, sort_order, visible_for) VALUES (v_next_column_id+2,990,NULL,'project_name',
                '"<a href=/intranet/projects/view?project_id=$project_id>$project_name</a>"','','',30,'');

		-- item_date_formatted
                INSERT INTO im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
                extra_select, extra_where, sort_order, visible_for) VALUES (v_next_column_id+3,990,NULL,'item_date_formatted',
                '$item_date_formatted','','',40,'');
		
		-- item_value
                INSERT INTO im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
                extra_select, extra_where, sort_order, visible_for) VALUES (v_next_column_id+4,990,NULL,'item_value',
                '$item_value','','',50,'');

                -- item_currency		
                INSERT INTO im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
                extra_select, extra_where, sort_order, visible_for) VALUES (v_next_column_id+5,990,NULL,'item_currency',
                '$item_currency','','',60,'');

                -- item_status_name		
                INSERT INTO im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
                extra_select, extra_where, sort_order, visible_for) VALUES (v_next_column_id+6,990,NULL,'item_status',
                '$item_status','','',70,'');

        EXCEPTION
                WHEN others THEN
                RAISE NOTICE 'Unable to create view_columns';
                RETURN 0;
        END;
 
        RETURN 0;
 
END;$body$ LANGUAGE 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();

-- delete from im_view_columns where view_id = 990;
-- delete from im_views where view_id = 990;
