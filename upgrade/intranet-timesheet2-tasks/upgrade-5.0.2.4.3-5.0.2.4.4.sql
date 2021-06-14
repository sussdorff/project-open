-- upgrade-5.0.2.4.3-5.0.2.4.4.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-5.0.2.4.3-5.0.2.4.4.sql','');



alter table im_timesheet_task_dependencies 
alter column difference set default 0.0;


create or replace function inline_0 ()
returns integer as $body$
DECLARE
        v_count                 integer;
BEGIN
        -- Check if colum exists in the database
        select  count(*) into v_count from user_tab_columns
        where   lower(table_name) = 'im_timesheet_task_dependencies' and
                lower(column_name) = 'difference_format_id';
        IF v_count > 0  THEN return 1; END IF;

        alter table im_timesheet_task_dependencies 
        add column difference_format_id integer
        constraint im_timesheet_task_dep_diff_format_fk
        references im_categories;

        return 0;
END;$body$ language 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();




-------------------------------
-- 9800-9899	Intranet Gantt Task Dependency Lag Format
--
-- LagFormat can be: 3=m, 4=em, 5=h, 6=eh, 7=d, 8=ed, 9=w, 10=ew, 
-- 11=mo, 12=emo, 19=%, 20=e%, 35=m?, 36=em?, 37=h?, 38=eh?, 39=d?, 
-- 40=ed?, 41=w?, 42=ew?, 43=mo?, 44=emo?, 51=%? and 52=e%?
--
SELECT im_category_new(9803,'Month', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9804,'e-Month', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9805,'Hour', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9806,'e-Hour', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9807,'Day', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9808,'e-Day', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9809,'Week', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9810,'e-Week', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9811,'mo', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9812,'emo', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9819,'Percent', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9820,'e-Percent', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9835,'m?', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9836,'em?', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9837,'h?', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9838,'eh?', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9839,'d?', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9840,'ed?', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9841,'w?', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9842,'ew?', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9843,'mo?', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9844,'emo?', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9851,'Percent?', 'Intranet Gantt Task Dependency Lag Format');
SELECT im_category_new(9852,'e-Percent?', 'Intranet Gantt Task Dependency Lag Format');



update im_timesheet_task_dependencies
set dependency_type_id = 9662
where dependency_type_id not in (9660, 9662, 9664, 9666);


