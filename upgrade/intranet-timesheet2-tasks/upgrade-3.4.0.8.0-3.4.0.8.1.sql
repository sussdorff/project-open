-- upgrade-3.4.0.8.0-3.4.0.8.1.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-3.4.0.8.0-3.4.0.8.1.sql','');


delete from im_view_columns where column_id = 91006;

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91006,910,NULL,'"CC"',
'"<a href=/intranet-cost/cost-centers/new?[export_url_vars cost_center_id return_url]>$cost_center_code</a>"',
'','',6,'');




-- Fix issues with deleting Timesheet Tasks
--
-- Delete a single timesheet_task (if we know its ID...)
create or replace function im_timesheet_task__delete (integer)
returns integer as '
declare
	p_task_id alias for $1;		-- timesheet_task_id
begin
	-- Start deleting with im_gantt_projects
	delete from	im_gantt_projects
	where		project_id = p_task_id;

	-- Erase the timesheet_task
	delete from	im_timesheet_tasks
	where		task_id = p_task_id;

	-- Erase the object
	PERFORM im_project__delete(p_task_id);
	return 0;
end;' language 'plpgsql';



-- Enable check/uncheck all entries in the TimesheetTaskListComponent

delete from im_view_columns where column_id = 91022;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91022,910,NULL, 
'"<input type=checkbox name=_dummy onclick=acs_ListCheckAll(''tasks'',this.checked)>"',
'"<input type=checkbox name=task_id.$task_id id=tasks,$task_id>"', '', '', 22, '');

delete from im_view_columns where column_id = 91112;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91112,911,NULL, 
'"<input type=checkbox name=_dummy onclick=acs_ListCheckAll(''tasks'',this.checked)>"',
'"<input type=checkbox name=task_id.$task_id id=tasks,$task_id>"', '', '', 12, '');





-- start_date and end_date in im_timesheet_tasks is redundant.
-- the values are stored in im_projects.
create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = ''im_timesheet_tasks'' and lower(column_name) = ''start_date'';
	IF v_count > 0 THEN 
		alter table im_timesheet_tasks drop column start_date;
	END IF;

	select count(*) into v_count from user_tab_columns
	where lower(table_name) = ''im_timesheet_tasks'' and lower(column_name) = ''end_date'';
	IF v_count > 0 THEN 
		alter table im_timesheet_tasks drop column end_date;
	END IF;

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



create or replace function inline_0 ()
returns integer as $body$
declare
	v_count		integer;
begin
	select count(*) into v_count from pg_class
	where lower(relname) = 'im_timesheet_tasks_view';

	IF v_count > 0 THEN 
		-- drop view im_timesheet_tasks_view;
		DROP VIEW im_timesheet_tasks_view;
	END IF;

	RETURN 0;
end; $body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




create or replace view im_timesheet_tasks_view as
select	t.*,
	p.parent_id as project_id,
	p.project_name as task_name,
	p.project_nr as task_nr,
	p.percent_completed,
	p.project_type_id as task_type_id,
	p.project_status_id as task_status_id,
	p.start_date,
	p.end_date,
	p.reported_hours_cache,
	p.reported_days_cache,
	p.reported_hours_cache as reported_units_cache
from
	im_projects p,
	im_timesheet_tasks t
where
	t.task_id = p.project_id
;



-- -------------------------------------------------------------------
-- Timesheet TaskList
-- -------------------------------------------------------------------

--
-- Wide View in "Tasks" page, including Description
--
delete from im_view_columns where view_id = 910;
delete from im_views where view_id = 910;
--
insert into im_views (view_id, view_name, visible_for) values (910, 'im_timesheet_task_list', 'view_projects');
--
-- insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
-- extra_select, extra_where, sort_order, visible_for) values (91000,910,NULL,'"Task Code"',
-- '"<nobr>$indent_html<a href=/intranet-timesheet2-tasks/new?[export_url_vars project_id task_id return_url]>
-- $task_nr</a></nobr>"','','',0,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91002,910,NULL,'"Task Name"',
'"<nobr>$indent_html$gif_html<a href=/intranet-timesheet2-tasks/new?[export_url_vars project_id task_id return_url]>
$task_name</a></nobr>"','','',2,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91004,910,NULL,'Material',
'"<a href=/intranet-material/new?[export_url_vars material_id return_url]>$material_nr</a>"',
'','',4,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91006,910,NULL,'"CC"',
'"<a href=/intranet-cost/cost-centers/new?[export_url_vars cost_center_id return_url]>$cost_center_code</a>"',
'','',6,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91007,910,NULL,'"Start"',
'"<nobr>[string range $start_date 0 9]</nobr>"','','',7,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91008,910,NULL,'"End"',
'"[if {[string equal t $red_p]} { set t "<nobr><font color=red>[string range $end_date 0 9]</font></nobr>" } else { set t "<nobr>[string range $end_date 0 9]</nobr>" }]"','(child.end_date < now() and coalesce(child.percent_completed,0) < 100) as red_p','',8,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91010,910,NULL,'Plan',
'"<input type=textbox size=3 name=planned_units.$task_id value=$planned_units>"','','',10,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91012,910,NULL,'Bill',
'"<input type=textbox size=3 name=billable_units.$task_id value=$billable_units>"','','',12,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91014,910,NULL,'Log',
'"<p align=right><a href=[export_vars -base $timesheet_report_url { { project_id $project_id } return_url}]>
$reported_units_cache</a></p>"','','',14,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91016,910,NULL,'UoM',
'$uom','','',16,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91018,910,NULL,'Status',
'"[im_category_select {Intranet Project Status} task_status_id.$task_id $task_status_id]"','','',12,'');

-- insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
-- extra_select, extra_where, sort_order, visible_for) values (91020,910,NULL, 'Description', 
-- '[string_truncate -len 80 " $description"]', '','',20,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91021,910,NULL, 'Done',
'"<input type=textbox size=3 name=percent_completed.$task_id value=$percent_completed>"', 
'','',21,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91022,910,NULL, 
'"<input type=checkbox name=_dummy onclick=acs_ListCheckAll(''tasks'',this.checked)>"',
'"<input type=checkbox name=task_id.$task_id id=tasks,$task_id>"', '', '', 22, '');




--
-- short view in project homepage
--
delete from im_view_columns where view_id = 911;
delete from im_views where view_id = 911;
--
insert into im_views (view_id, view_name, visible_for) values (911, 
'im_timesheet_task_list_short', 'view_projects');
--
-- insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
-- extra_select, extra_where, sort_order, visible_for) values (91100,911,NULL,'"Project Nr"',
-- '"<a href=/intranet/projects/view?[export_url_vars project_id]>$project_nr</a>"',
-- '','',0,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91101,911,NULL,'"Task Name"',
'"<nobr>$indent_short_html$gif_html<a href=/intranet-timesheet2-tasks/new?[export_url_vars project_id task_id return_url]>
$task_name</a></nobr>"','','',1,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91102,911,NULL,'"Start"',
'"<nobr>[string range $start_date 2 9]</nobr>"','','',2,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91103,911,NULL,'"End"',
'"[if {[string equal t $red_p]} { set t "<nobr><font color=red>[string range $end_date 2 9]</font></nobr>" } else { set t "<nobr>[string range $end_date 2 9]</nobr>" }]"','(child.end_date < now() and coalesce(child.percent_completed,0) < 100) as red_p','',3,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91104,911,NULL,'Pln',
'$planned_units','','',4,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91106,911,NULL,'Bll',
'$billable_units','','',6,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91108,911,NULL,'Lg',
'"<a href=[export_vars -base $timesheet_report_url { task_id { project_id $project_id } return_url}]>
$reported_units_cache</a>"','','',8,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91109,911,NULL,'"%"',
'$percent_completed_rounded','','',9,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91110,911,NULL,'UoM',
'$uom','','',10,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91112,911,NULL, 
'"[im_gif del "Delete"]"', 
'"<input type=checkbox name=task_id.$task_id>"', '', '', 12, '');
