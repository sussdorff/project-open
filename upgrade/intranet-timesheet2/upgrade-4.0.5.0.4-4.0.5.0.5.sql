-- 
-- 
-- 
-- @author Malte Sussdorff (malte.sussdorff@cognovis.de)
-- @creation-date 2013-01-14
-- @cvs-id $Id$
--

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.0.5.0.4-4.0.5.0.5.sql','');

alter table im_user_absences drop constraint owner_and_start_date_unique;

-- ------------------------------------------------------
-- Components for timesheet approval
-- ------------------------------------------------------

-- Show the workflow component in project page
--
SELECT im_component_plugin__new (
        null,                           -- plugin_id
        'acs_object',                   -- object_type
        now(),                          -- creation_date
        null,                           -- creation_user
        null,                           -- creation_ip
        null,                           -- context_id
        'Absence Approval Component',      -- plugin_name
        'intranet-timesheet2',            -- package_name
        'left',                         -- location
        '/intranet/index',              -- page_url
        null,                           -- view_name
        1,                              -- sort_order
	'im_absence_approval_component -user_id $user_id'
);

--------------------------------------------------------------
-- Home Inbox View
delete from im_view_columns where view_id = 280;
delete from im_views where view_id = 280;

insert into im_views (view_id, view_name, visible_for) 
values (280, 'absence_approval_inbox', '');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (28000,280,'Workflow','"<a class=button href=$workflow_url>$next_action_l10n</a>"',0);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (28010,280,'Start Date','"$start_date_pretty"',10);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (28011,280,'End Date','"$end_date_pretty"',10);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (28020,280,'Object Name','"<a href=$object_url>$object_name</a>"',20);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (28030,280,'Status','"$status"',30);

-- ------------------------------------------------------
-- Components for absence info
-- ------------------------------------------------------

SELECT im_component_plugin__new (
        null,                           -- plugin_id
        'acs_object',                   -- object_type
        now(),                          -- creation_date
        null,                           -- creation_user
        null,                           -- creation_ip
        null,                           -- context_id
        'Absence Info Component',      -- plugin_name
        'intranet-timesheet2',            -- package_name
        'left',                         -- location
        '/intranet-timesheet2/absences/view',              -- page_url
        null,                           -- view_name
        1,                              -- sort_order
        'im_absence_info_component -absence_id $absence_id'
);

SELECT acs_permission__grant_permission(
        (select plugin_id from im_component_plugins where plugin_name = 'Absence Info Component' and package_name = 'intranet-timesheet2'),
        (select group_id from groups where group_name = 'Employees'),
        'read'
);

SELECT im_component_plugin__new (
        null,                           -- plugin_id
        'acs_object',                   -- object_type
        now(),                          -- creation_date
        null,                           -- creation_user
        null,                           -- creation_ip
        null,                           -- context_id
        'Absence Balance Component',      -- plugin_name
        'intranet-timesheet2',            -- package_name
        'right',                         -- location
        '/intranet-timesheet2/absences/view',              -- page_url
        null,                           -- view_name
        1,                              -- sort_order
        'im_absence_balance_component -user_id $owner_id'
);

SELECT acs_permission__grant_permission(
        (select plugin_id from im_component_plugins where plugin_name = 'Absence Balance Component' and package_name = 'intranet-timesheet2'),
        (select group_id from groups where group_name = 'Employees'),
        'read'
);

update im_component_plugins set page_url = '/intranet-timesheet2/absences/view' where page_url = '/intranet-timesheet2/absences/new';

SELECT im_component_plugin__new (
        null,                           -- plugin_id
        'acs_object',                   -- object_type
        now(),                          -- creation_date
        null,                           -- creation_user
        null,                           -- creation_ip
        null,                           -- context_id
        'Absence Balance Component Edit',      -- plugin_name
        'intranet-timesheet2',            -- package_name
        'right',                         -- location
        '/intranet-timesheet2/absences/new',              -- page_url
        null,                           -- view_name
        1,                              -- sort_order
        'im_absence_balance_component -user_id $owner_id'
);

SELECT acs_permission__grant_permission(
        (select plugin_id from im_component_plugins where plugin_name = 'Absence Balance Component Edit' and package_name = 'intranet-timesheet2'),
        (select group_id from groups where group_name = 'Employees'),
        'read'
);
--------------------------------------------------------------
-- Home Inbox View
delete from im_view_columns where view_id = 281;
delete from im_views where view_id = 281;

insert into im_views (view_id, view_name, visible_for) 
values (281, 'absence_info', '');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (28100,281,'Name','$owner_pretty',0);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (28110,281,'Start Date','"[lc_time_fmt $start_date "%q"]"',10);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (28112,281,'End Date','"[lc_time_fmt $end_date "%q"]"',12);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (28123,281,'Duration','$duration_days',23);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (28130,281,'Status','"[im_category_from_id $absence_status_id]"',30);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (28132,281,'Description','"$description"',32);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (28135,281,'Contact Info','"$contact_info"',35);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (28140,281,'Vacation Replacement','"$vacation_replacement"',40);

-- ------------------------------------------------------
--------------------------------------------------------------
-- Remaining Vacation View
delete from im_view_columns where view_id = 291;
delete from im_views where view_id = 291;
delete from im_view_columns where view_id = 1013;
delete from im_views where view_id = 1013;


insert into im_views (view_id, view_name, view_label) 
values (291, 'remaining_vacation_list', 'Remaining Vacation');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order, variable_name) 
values (29100,291,'Owner','"<a href=''/intranet-timesheet2/absences/index?user_selection=$employee_id&timescale=all&absence_type_id=$absence_type_id''>$owner_name</a>"',0,'owner_name');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order,variable_name) 
values (29110,291,'Department Name','"$department_name"',10,'department_name');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order,variable_name) 
values (29112,291,'Total Absence Days','$total_absence_days',12,'total_absence_days');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order,variable_name) 
values (29123,291,'Taken Absence Days this year','$taken_absence_days_this_year',23,'taken_absence_days_this_year');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order,variable_name) 
values (29130,291,'Remaining Absences This Year','$remaining_absence_days_this_year',30,'remaining_absence_days_this_year');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order,variable_name) 
values (29132,291,'Requested Absence Days This year','"$requested_absence_days_this_year"',32,'requested_absence_days_this_year');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order,variable_name) 
values (29135,291,'Entitlement Days this year','"$entitlement_days_this_year"',35,'entitlement_days_this_year');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order,variable_name) 
values (29140,291,'Entitlement Days Total','"$entitlement_days_total"',40,'entitlement_days_total');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order,variable_name) 
values (29144,291,'Remaining Vacation Days','"$remaining_vacation_days"',44,'remaining_vacation_days');
