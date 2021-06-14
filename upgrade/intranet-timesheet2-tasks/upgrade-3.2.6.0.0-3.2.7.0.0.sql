-- upgrade-3.2.6.0.0-3.2.7.0.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-3.2.6.0.0-3.2.7.0.0.sql','');


-- Replaced by im_biz_object_member relationship "pecentage" column


create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = ''im_timesheet_task_allocations'';
        IF v_count = 0 THEN return 0; END IF;

	drop table im_timesheet_task_allocations;

        return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();




-- Delete the "project_nr" column from the Tasks list
delete from im_view_columns where column_id= 91100;
update im_view_columns set
	column_name = '"Name"',
	column_render_tcl = '"<a href=/intranet-timesheet2-tasks/new?[export_url_vars project_id task_id return_url]>$task_name</a>"'
where
	column_id = 91101;



--
-- short view in project homepage
--
delete from im_view_columns where view_id = 911;
--
--
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91101,911,NULL,'"Task Name"',
'"<a href=/intranet-timesheet2-tasks/new?[export_url_vars project_id task_id return_url]>
$task_name</a>"','','',1,'');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91103,911,NULL,'Material',
'"<a href=/intranet-material/new?[export_url_vars material_id return_url]>$material_nr</a>"',
'','',3,'');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91104,911,NULL,'Plan',
'$planned_units','','',4,'');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91106,911,NULL,'Bill',
'$billable_units','','',6,'');
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91108,911,NULL,'Log',
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

