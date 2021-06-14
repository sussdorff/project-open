-- upgrade-4.0.1.0.3-4.0.1.0.4.sql
SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.0.1.0.3-4.0.1.0.4.sql','') from dual;


-- Remove im_timesheet_task dynfield attributes: project_status_id and project_type_id

CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS ' 
DECLARE 
	v_attribute_id integer;
	v_count	       integer;
BEGIN	
      SELECT ida.attribute_id INTO v_attribute_id FROM im_dynfield_attributes ida, acs_attributes aa 
      WHERE ida.acs_attribute_id = aa.attribute_id AND aa.object_type = ''im_timesheet_task'' AND aa.attribute_name = ''project_status_id'';
      
      PERFORM im_dynfield_attribute__del(v_attribute_id);


      SELECT ida.attribute_id INTO v_attribute_id FROM im_dynfield_attributes ida, acs_attributes aa 
      WHERE ida.acs_attribute_id = aa.attribute_id AND aa.object_type = ''im_timesheet_task'' AND aa.attribute_name = ''project_type_id'';

      PERFORM im_dynfield_attribute__del(v_attribute_id);

      RETURN 0;     
END;' language 'plpgsql';

SELECT inline_0();
DROP FUNCTION inline_0();


-- Add New im_timesheet_task dynfield attributes: task_status_id and task_type_id

--task_status_id
CREATE OR REPLACE FUNCTION inline_4 ()
RETURNS integer AS '
DECLARE 
	v_attribute_id integer;
	v_count	       integer;
	
BEGIN 
      PERFORM im_dynfield_widget__new (
       null,
       ''im_dynfield_widget'', 
       now(), 
       null,
       null, 
       null, 
       ''task_status'',
       ''Task Status'',
       ''Task Status'',
       10007,
       ''integer'',
       ''generic_tcl'',
       ''integer'',
       ''{custom {category_type "Intranet Gantt Task Status"}}'',
       ''im_name_from_id''
       );

      SELECT ida.attribute_id INTO v_attribute_id FROM im_dynfield_attributes ida, acs_attributes aa 
      WHERE ida.acs_attribute_id = aa.attribute_id AND aa.object_type = ''im_timesheet_task'' AND aa.attribute_name = ''task_status_id'';
     
      IF v_attribute_id > 0 THEN
      	 UPDATE acs_attributes SET pretty_name = ''Task Status'', pretty_plural = ''Task Status'', min_n_values = 1, sort_order = 4 
	 WHERE attribute_id = (SELECT acs_attribute_id FROM im_dynfield_attributes WHERE attribute_id = v_attribute_id);

      	 UPDATE im_dynfield_attributes SET widget_name = ''task_status'', also_hard_coded_p = ''f'' WHERE attribute_id = v_attribute_id;
      ELSE
        v_attribute_id := im_dynfield_attribute_new (
        ''im_timesheet_task'',
        ''task_status_id'',
        ''Task Status'',
        ''task_status'',
        ''integer'',
        ''t'',
        4,
        ''f'',
        ''im_timesheet_tasks''
        );

      -- Add column on table im_timesheet_tasks
      ALTER TABLE im_timesheet_tasks ADD COLUMN task_status_id integer;
      END IF;

      RETURN 0;
END;' language 'plpgsql';


SELECT inline_4 ();
DROP FUNCTION inline_4 ();

-- task_type_id
CREATE OR REPLACE FUNCTION inline_5 ()
RETURNS integer AS '
DECLARE 
	v_attribute_id integer;
	v_count	       integer;
		
BEGIN 
      PERFORM im_dynfield_widget__new (
       null,
      ''im_dynfield_widget'', 
       now(),
       null,
       null,
       null,
       ''task_type'',
       ''Task Type'',
       ''Task Types'',
       10007,
       ''integer'',
       ''generic_tcl'',
       ''integer'',
       ''{custom {category_type "Intranet Gantt Task Type"}}'',
       ''im_name_from_id''
       );

      SELECT ida.attribute_id INTO v_attribute_id FROM im_dynfield_attributes ida, acs_attributes aa 
      WHERE ida.acs_attribute_id = aa.attribute_id AND aa.object_type = ''im_timesheet_task'' AND aa.attribute_name = ''task_type_id'';
     
      IF v_attribute_id > 0 THEN
      	 UPDATE acs_attributes SET pretty_name = ''Task Type'', pretty_plural = ''Task Type'', min_n_values = 1, sort_order = 5
	 WHERE attribute_id = (SELECT acs_attribute_id FROM im_dynfield_attributes WHERE attribute_id = v_attribute_id);

      	 UPDATE im_dynfield_attributes SET widget_name = ''task_type'', also_hard_coded_p = ''f'' WHERE attribute_id = v_attribute_id;

      ELSE
        v_attribute_id := im_dynfield_attribute_new (
        ''im_timesheet_task'',
        ''task_type_id'',
        ''Task Type'',
        ''task_type'',
        ''integer'',
        ''f'',
        5,
        ''f'',
        ''im_timesheet_tasks''
        );
      -- Add column on table im_timesheet_tasks
      ALTER TABLE im_timesheet_tasks ADD COLUMN task_type_id integer;
      END IF;

      
      SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map 
      WHERE attribute_id = v_attribute_id AND (object_type_id = 100 OR object_type_id = 9500);

      -- Set default object_type_id for tasks as 9500 instead of 100
      IF v_count = 0 THEN
      	 INSERT INTO im_dynfield_type_attribute_map
	 	(attribute_id, object_type_id, display_mode, help_text, section_heading, default_value, required_p)
	 VALUES
		(v_attribute_id, 9500, ''none'', null, null, null, ''t'');
      ELSE
	 UPDATE im_dynfield_type_attribute_map SET object_type_id = 9500, display_mode = ''none'', required_p = ''t'' WHERE attribute_id = v_attribute_id AND object_type_id = 100;
      END IF;

      RETURN 0;
END;' language 'plpgsql';


SELECT inline_5 ();
DROP FUNCTION inline_5 ();


-- Task Status Category "Closed"
SELECT im_category_new (9601,'Closed','Intranet Gantt Task Status');

UPDATE im_timesheet_tasks SET task_type_id = 9500;

UPDATE im_timesheet_tasks SET task_status_id = 9600 where task_id in (select project_id from im_projects where project_status_id = 76);
UPDATE im_timesheet_tasks SET task_status_id = 9601 where task_id in (select project_id from im_projects where project_status_id = 81);

UPDATE im_menus SET url = '/intranet-timesheet2-tasks/index?view_name=im_timesheet_task_list&task_status_id=9600' WHERE package_name = 'intranet-timesheet2-tasks' AND label = 'project_timesheet_task' AND name = 'Tasks';    