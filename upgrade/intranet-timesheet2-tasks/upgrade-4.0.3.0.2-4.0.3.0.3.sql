-- upgrade-4.0.3.0.2-4.0.3.0.3.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.0.3.0.2-4.0.3.0.3.sql','');

-- Right Side Components

update im_component_plugins set page_url = '/intranet-timesheet2-tasks/view' where page_url = '/intranet-timesheet2-tasks/new';
update im_component_plugins set page_url = '/intranet-timesheet2-tasks/view' where page_url = '/intranet-cognovis/tasks/new';

-- Timesheet Task Members Component
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'Task Members',
       'intranet-core', 
       'right',
       '/intranet-timesheet2-tasks/view',
       null,
       20,
       'im_group_member_component $task_id $current_user_id $project_write $return_url "" "" 1');


-- Project Timesheet Tasks Information
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'Timesheet Task Project Information',
       'intranet-timesheet2-tasks',
       'right',
       '/intranet-timesheet2-tasks/view',
       null,
       '50',
       'im_timesheet_task_info_component $project_id $task_id $return_url');


-- Timesheet Task Resources
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'Task Resources',
       'intranet-timesheet2-tasks',
       'right',
       '/intranet-timesheet2-tasks/view',
       null, 
       '50', 'im_timesheet_task_members_component $project_id $task_id $return_url');


-- Timesheet Tasks Forum Component
SELECT im_component_plugin__new (
        null,                           -- plugin_id
	'acs_object',                   -- object_type
        now(),                          -- creation_date
	null,                           -- creation_user
        null,                           -- creation_ip
        null,                           -- context_id
        'Timesheet Task Forum',		-- plugin_name
        'intranet-forum',               -- package_name
        'right',                        -- location
        '/intranet-timesheet2-tasks/view', -- page_url
        null,                           -- view_name
        10,                             -- sort_order
	'im_forum_component -user_id $user_id -forum_object_id $task_id -current_page_url $return_url -return_url $return_url -forum_type "task" -export_var_list [list task_id forum_start_idx forum_order_by forum_how_many forum_view_name] -view_name [im_opt_val forum_view_name] -forum_order_by [im_opt_val forum_order_by] -start_idx [im_opt_val forum_start_idx] -restrict_to_mine_p "f" -restrict_to_new_topics 0',
	'im_forum_create_bar "<B><nobr>[_ intranet-forum.Forum_Items]</nobr></B>" $task_id $return_url');

-- Left Side Components

-- Timesheet Task Info Component 
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'Timesheet Task Info Component',
       'intranet-timesheet2-tasks',
       'left', 
       '/intranet-timesheet2-tasks/view', 
       null,
       1,
       'im_timesheet_task_info2_component $task_id $return_url');

-- Timesheet Tasks Dynfield Attributes
-- uom_id
CREATE OR REPLACE FUNCTION inline_6 ()
RETURNS integer AS '
DECLARE 
	v_attribute_id integer;
	v_count	       integer;
	
BEGIN 
      SELECT ida.attribute_id INTO v_attribute_id FROM im_dynfield_attributes ida, acs_attributes aa 
      WHERE ida.acs_attribute_id = aa.attribute_id AND aa.object_type = ''im_timesheet_task'' AND aa.attribute_name = ''uom_id'';
     
      IF v_attribute_id > 0 THEN
      	 UPDATE acs_attributes SET min_n_values = 0, sort_order = 6
	 WHERE attribute_id = (SELECT acs_attribute_id FROM im_dynfield_attributes WHERE attribute_id = v_attribute_id);

     	 UPDATE im_dynfield_attributes SET also_hard_coded_p = ''f'' WHERE attribute_id = v_attribute_id;
      ELSE
        v_attribute_id := im_dynfield_attribute_new (
 	''im_timesheet_task'',
	''uom_id'',
	''Unit of Measures'',
	''units_of_measure'',
	''integer'',
	''f'',
	6,
	''f'',
	''im_timesheet_tasks''
	);
      END IF;

      SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = 100;
      IF v_count = 0 THEN
      	 INSERT INTO im_dynfield_type_attribute_map
	 	(attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
	 VALUES
		(v_attribute_id, 100,''edit'',null,null,null,''t'');
      ELSE
	 UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''t'' WHERE attribute_id = v_attribute_id AND object_type_id = 100;
      END IF;


      RETURN 0;
END;' language 'plpgsql';


SELECT inline_6 ();
DROP FUNCTION inline_6 ();

-- cost_center
CREATE OR REPLACE FUNCTION inline_7 ()
RETURNS integer AS '
DECLARE 
	v_attribute_id integer;
	v_count	       integer;
	
BEGIN 
      SELECT ida.attribute_id INTO v_attribute_id FROM im_dynfield_attributes ida, acs_attributes aa 
      WHERE ida.acs_attribute_id = aa.attribute_id AND aa.object_type = ''im_timesheet_task'' AND aa.attribute_name = ''cost_center_id'';
     
      IF v_attribute_id > 0 THEN
      	 UPDATE acs_attributes SET min_n_values = 1, sort_order = 7
	 WHERE attribute_id = (SELECT acs_attribute_id FROM im_dynfield_attributes WHERE attribute_id = v_attribute_id);


     	 UPDATE im_dynfield_attributes SET also_hard_coded_p = ''f'' WHERE attribute_id = v_attribute_id;
      ELSE
        v_attribute_id := im_dynfield_attribute_new (
        ''im_timesheet_task'',
        ''cost_center_id'',
        ''Cost Center'',
        ''cost_centers'',
        ''integer'',
        ''t'',
        7,
        ''f'',
        ''im_timesheet_tasks''       
        );
      END IF;

      SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = 100;
      IF v_count = 0 THEN
      	 INSERT INTO im_dynfield_type_attribute_map
	 	(attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
	 VALUES
		(v_attribute_id, 100,''edit'',''#intranet-timesheet2-tasks.form_cost_center_help#'',null,null,''t'');
      ELSE
	 UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''t'' WHERE attribute_id = v_attribute_id AND object_type_id = 100;
      END IF;


      RETURN 0;
END;' language 'plpgsql';


SELECT inline_7 ();
DROP FUNCTION inline_7 ();


-- material_id
CREATE OR REPLACE FUNCTION inline_8 ()
RETURNS integer AS '
DECLARE 
	v_attribute_id integer;
	v_count	       integer;
BEGIN 
      SELECT ida.attribute_id INTO v_attribute_id FROM im_dynfield_attributes ida, acs_attributes aa 
      WHERE ida.acs_attribute_id = aa.attribute_id AND aa.object_type = ''im_timesheet_task'' AND aa.attribute_name = ''material_id'';
     
      IF v_attribute_id > 0 THEN
      	 UPDATE acs_attributes SET min_n_values = 0, sort_order = 8
	 WHERE attribute_id = (SELECT acs_attribute_id FROM im_dynfield_attributes WHERE attribute_id = v_attribute_id);

      	 UPDATE im_dynfield_attributes SET also_hard_coded_p = ''f'' WHERE attribute_id = v_attribute_id;
      ELSE 
        v_attribute_id := im_dynfield_attribute_new (
        ''im_timesheet_task'',
        ''material_id'',
        ''Material'',
        ''select_material_id'',
        ''integer'',
        ''f'',
        8,
        ''f'',
        ''im_timesheet_tasks''
        );
      END IF;

      SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = 100;
      IF v_count = 0 THEN
      	 INSERT INTO im_dynfield_type_attribute_map
	 	(attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
	 VALUES
		(v_attribute_id, 100,''edit'',''#intranet-timesheet2-tasks.form_material_help#'',null,null,''t'');
      ELSE
	 UPDATE im_dynfield_type_attribute_map SET display_mode = ''none'', required_p = ''t'' WHERE attribute_id = v_attribute_id AND object_type_id = 100;
      END IF;


      RETURN 0;
END;' language 'plpgsql';


SELECT inline_8 ();
DROP FUNCTION inline_8 ();


-- planned_units
CREATE OR REPLACE FUNCTION inline_9 ()
RETURNS integer AS '
DECLARE 
	v_attribute_id integer;
	v_count	       integer;
	
BEGIN 
      SELECT ida.attribute_id INTO v_attribute_id FROM im_dynfield_attributes ida, acs_attributes aa 
      WHERE ida.acs_attribute_id = aa.attribute_id AND aa.object_type = ''im_timesheet_task'' AND aa.attribute_name = ''planned_units'';
     
      IF v_attribute_id > 0 THEN
      	 UPDATE acs_attributes SET min_n_values = 0, sort_order = 9
	 WHERE attribute_id = (SELECT acs_attribute_id FROM im_dynfield_attributes WHERE attribute_id = v_attribute_id);

     	 UPDATE im_dynfield_attributes SET also_hard_coded_p = ''f'' WHERE attribute_id = v_attribute_id;
      ELSE
        v_attribute_id := im_dynfield_attribute_new (
        ''im_timesheet_task'',
        ''planned_units'',
        ''Planned Units'',
        ''numeric'',
        ''float'',
        ''f'',
        9,
        ''f'',
        ''im_timesheet_tasks''
        );
      END IF;

      SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = 100;
      IF v_count = 0 THEN
      	 INSERT INTO im_dynfield_type_attribute_map
	 	(attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
	 VALUES
		(v_attribute_id, 100,''edit'',''#intranet-timesheet2-tasks.form_planned_units_help#'',null,null,''f'');
      ELSE
	 UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = 100;
      END IF;

      RETURN 0;
END;' language 'plpgsql';


SELECT inline_9 ();
DROP FUNCTION inline_9 ();

-- billable_units
CREATE OR REPLACE FUNCTION inline_10 ()
RETURNS integer AS '
DECLARE 
	v_attribute_id integer;
	v_count	       integer;
		
BEGIN 
      SELECT ida.attribute_id INTO v_attribute_id FROM im_dynfield_attributes ida, acs_attributes aa 
      WHERE ida.acs_attribute_id = aa.attribute_id AND aa.object_type = ''im_timesheet_task'' AND aa.attribute_name = ''billable_units'';
     
      IF v_attribute_id > 0 THEN
      	 UPDATE acs_attributes SET min_n_values = 0, sort_order = 10
	 WHERE attribute_id = (SELECT acs_attribute_id FROM im_dynfield_attributes WHERE attribute_id = v_attribute_id);

      	 UPDATE im_dynfield_attributes SET also_hard_coded_p = ''f'' WHERE attribute_id = v_attribute_id;

      ELSE
        v_attribute_id := im_dynfield_attribute_new (
        ''im_timesheet_task'',
        ''billable_units'',
        ''Billable Units'',
        ''numeric'',
        ''float'',
        ''f'',
        10,
        ''f'',
        ''im_timesheet_tasks''
        );
      END IF;
      
      SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = 100;
      IF v_count = 0 THEN
      	 INSERT INTO im_dynfield_type_attribute_map
	 	(attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
	 VALUES
		(v_attribute_id, 100,''edit'',''#intranet-timesheet2-tasks.form_billable_units_help#'',null,null,''f'');
      ELSE
	 UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = 100;
      END IF;


      RETURN 0;
END;' language 'plpgsql';


SELECT inline_10 ();
DROP FUNCTION inline_10 ();

-- percent_completed
CREATE OR REPLACE FUNCTION inline_11 ()
RETURNS integer AS '
DECLARE 
	v_attribute_id integer;
	v_count	       integer;

BEGIN 
      SELECT ida.attribute_id INTO v_attribute_id FROM im_dynfield_attributes ida, acs_attributes aa 
      WHERE ida.acs_attribute_id = aa.attribute_id AND aa.object_type = ''im_timesheet_task'' AND aa.attribute_name = ''percent_completed'';
     
      IF v_attribute_id > 0 THEN
      	 UPDATE acs_attributes SET min_n_values = 0, sort_order = 11
	 WHERE attribute_id = (SELECT acs_attribute_id FROM im_dynfield_attributes WHERE attribute_id = v_attribute_id);

    	 UPDATE im_dynfield_attributes SET also_hard_coded_p = ''f'' WHERE attribute_id = v_attribute_id;
      ELSE
        v_attribute_id := im_dynfield_attribute_new (
        ''im_timesheet_task'',
        ''percent_completed'',
        ''Percent Completed'',
        ''numeric'',
        ''float'',
        ''f'',
        11,
        ''f'',
        ''im_projects''
        );
      END IF;

      SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = 100;
      IF v_count = 0 THEN
      	 INSERT INTO im_dynfield_type_attribute_map
	 	(attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
	 VALUES
		(v_attribute_id, 100,''edit'',''#intranet-timesheet2-tasks.form_percentage_completed_help#'',null,null,''f'');
      ELSE
	 UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = 100;
      END IF;


      RETURN 0;
END;' language 'plpgsql';


SELECT inline_11 ();
DROP FUNCTION inline_11 ();


-- start_date
CREATE OR REPLACE FUNCTION inline_12 ()
RETURNS integer AS '
DECLARE 
	v_attribute_id integer;
	v_count	       integer;

BEGIN 
      SELECT ida.attribute_id INTO v_attribute_id FROM im_dynfield_attributes ida, acs_attributes aa 
      WHERE ida.acs_attribute_id = aa.attribute_id AND aa.object_type = ''im_timesheet_task'' AND aa.attribute_name = ''start_date'';
     
      IF v_attribute_id > 0 THEN
      	 UPDATE acs_attributes SET min_n_values = 0, sort_order = 12
	 WHERE attribute_id = (SELECT acs_attribute_id FROM im_dynfield_attributes WHERE attribute_id = v_attribute_id);


      	 UPDATE im_dynfield_attributes SET also_hard_coded_p = ''f'' WHERE attribute_id = v_attribute_id;
      ELSE
        v_attribute_id := im_dynfield_attribute_new (
        ''im_timesheet_task'',
        ''start_date'',
        ''Start Date'',
        ''date'',
        ''date'',
        ''f'',
        12,
        ''f'',
        ''im_projects''
        );
      END IF;

      SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = 100;
      IF v_count = 0 THEN
      	 INSERT INTO im_dynfield_type_attribute_map
	 	(attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
	 VALUES
		(v_attribute_id, 100,''edit'',null,null,null,''t'');
      ELSE
	 UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''t'' WHERE attribute_id = v_attribute_id AND object_type_id = 100;
      END IF;


      RETURN 0;
END;' language 'plpgsql';


SELECT inline_12 ();
DROP FUNCTION inline_12 ();




-- end_date
CREATE OR REPLACE FUNCTION inline_13 ()
RETURNS integer AS '
DECLARE 
	v_attribute_id integer;
	v_count	       integer;

BEGIN 
      SELECT ida.attribute_id INTO v_attribute_id FROM im_dynfield_attributes ida, acs_attributes aa 
      WHERE ida.acs_attribute_id = aa.attribute_id AND aa.object_type = ''im_timesheet_task'' AND aa.attribute_name = ''end_date'';
     
      IF v_attribute_id > 0 THEN
      	 UPDATE acs_attributes SET min_n_values = 0, sort_order = 13 
	 WHERE attribute_id = (SELECT acs_attribute_id FROM im_dynfield_attributes WHERE attribute_id = v_attribute_id);

      	 UPDATE im_dynfield_attributes SET also_hard_coded_p = ''f'' WHERE attribute_id = v_attribute_id;
      ELSE
        v_attribute_id := im_dynfield_attribute_new (
        ''im_timesheet_task'',
        ''end_date'',
        ''End Date'',
        ''date'',
        ''date'',
        ''f'',
        13,
        ''f'',
        ''im_projects''
        );
      END IF;

      SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = 100;
      IF v_count = 0 THEN
      	 INSERT INTO im_dynfield_type_attribute_map
	 	(attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
	 VALUES
		(v_attribute_id, 100,''edit'',null,null,null,''t'');
      ELSE
	 UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''t'' WHERE attribute_id = v_attribute_id AND object_type_id = 100;
      END IF;


      RETURN 0;
END;' language 'plpgsql';


SELECT inline_13 ();
DROP FUNCTION inline_13 ();


-- description
CREATE OR REPLACE FUNCTION inline_15 ()
RETURNS integer AS '
DECLARE 
	v_attribute_id integer;
	v_count	       integer;

BEGIN 
      SELECT ida.attribute_id INTO v_attribute_id FROM im_dynfield_attributes ida, acs_attributes aa 
      WHERE ida.acs_attribute_id = aa.attribute_id AND aa.object_type = ''im_timesheet_task'' AND aa.attribute_name = ''description'';
     
      IF v_attribute_id IS NOT NULL THEN
      	 UPDATE acs_attributes SET min_n_values = 0, sort_order = 14 
	 WHERE attribute_id = (SELECT acs_attribute_id FROM im_dynfield_attributes WHERE attribute_id = v_attribute_id);

     	 UPDATE im_dynfield_attributes SET also_hard_coded_p = ''f'' WHERE attribute_id = v_attribute_id;
      ELSE
        v_attribute_id := im_dynfield_attribute_new (
        ''im_timesheet_task'',
        ''description'',
        ''Task Description'',
        ''richtext'',
        ''text'',
        ''f'',
        15,
        ''f'',
        ''im_projects''
       );
      END IF;

      SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = 100;
      IF v_count = 0 THEN
      	 INSERT INTO im_dynfield_type_attribute_map
	 	(attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
	 VALUES
		(v_attribute_id, 100,''edit'',null,null,null,''f'');
      ELSE
	 UPDATE im_dynfield_type_attribute_map SET display_mode = ''display'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = 100;
      END IF;


      RETURN 0;
END;' language 'plpgsql';


SELECT inline_15 ();
DROP FUNCTION inline_15 ();

update im_biz_object_urls set url='/intranet-timesheet2-tasks/view?task_id=' where url = '/intranet-timesheet2-tasks/new?task_id=';
update im_biz_object_urls set url='/intranet-timesheet2-tasks/new?task_id=' where url = '/intranet-timesheet2-tasks/new?form_mode=edit&task_id=';

update im_biz_object_urls set url='/intranet-timesheet2-tasks/view?task_id=' where url = '/intranet-cognovis/tasks/new?task_id=';
update im_biz_object_urls set url='/intranet-timesheet2-tasks/new?task_id=' where url = '/intranet-cognovis/tasks/view?form_mode=edit&task_id=';
