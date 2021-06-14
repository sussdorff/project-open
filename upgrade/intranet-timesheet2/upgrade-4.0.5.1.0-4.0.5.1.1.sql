-- upgrade-4.0.5.1.0-4.0.5.1.1.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.0.5.1.0-4.0.5.1.1.sql','');


-- Rename add_hours_for_direct_reports into add_hours_direct_reports
--
select acs_privilege__create_privilege('add_hours_direct_reports','Add hours for direct reports','Add hours for direct reports');

CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS $$
DECLARE
        v_count                 integer;
BEGIN
	SELECT	count(*) into v_count FROM acs_privilege_hierarchy
	WHERE 	privilege = 'add_hours_direct_reports';
	IF v_count > 0 THEN 
	   	-- There is already a privilege
		delete from acs_privilege_hierarchy where privilege = 'add_hours_for_direct_reports';
	ELSE
		update acs_privilege_hierarchy
		set privilege = 'add_hours_direct_reports'
		where privilege = 'add_hours_for_direct_reports';
	END IF;


	SELECT	count(*) into v_count FROM acs_privilege_hierarchy
	WHERE 	child_privilege = 'add_hours_direct_reports';
	IF v_count > 0 THEN 
	   	-- There is already a child_privilege
		delete from acs_privilege_hierarchy where child_privilege = 'add_hours_for_direct_reports';
	ELSE
		update acs_privilege_hierarchy
		set child_privilege = 'add_hours_direct_reports'
		where child_privilege = 'add_hours_for_direct_reports';
	END IF;

        return 0;
END;$$ LANGUAGE 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();





CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS $$
DECLARE
        v_count                 integer;
BEGIN
	SELECT	count(*) into v_count FROM acs_privilege_hierarchy_index
	WHERE 	privilege = 'add_hours_direct_reports';
	IF v_count > 0 THEN 
	   	-- There is already a privilege
		delete from acs_privilege_hierarchy_index where privilege = 'add_hours_for_direct_reports';
	ELSE
		update acs_privilege_hierarchy_index
		set privilege = 'add_hours_direct_reports'
		where privilege = 'add_hours_for_direct_reports';
	END IF;


	SELECT	count(*) into v_count FROM acs_privilege_hierarchy_index
	WHERE 	child_privilege = 'add_hours_direct_reports';
	IF v_count > 0 THEN 
	   	-- There is already a child_privilege
		delete from acs_privilege_hierarchy_index where child_privilege = 'add_hours_for_direct_reports';
	ELSE
		update acs_privilege_hierarchy_index
		set child_privilege = 'add_hours_direct_reports'
		where child_privilege = 'add_hours_for_direct_reports';
	END IF;

        return 0;
END;$$ LANGUAGE 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();







CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS $$
DECLARE
        v_count                 integer;
BEGIN
	SELECT	count(*) into v_count FROM acs_privilege_descendant_map
	WHERE 	privilege = 'add_hours_direct_reports';
	IF v_count > 0 THEN 
	   	-- There is already a privilege
		delete from acs_privilege_descendant_map where privilege = 'add_hours_for_direct_reports';
	ELSE
		update acs_privilege_descendant_map
		set privilege = 'add_hours_direct_reports'
		where privilege = 'add_hours_for_direct_reports';
	END IF;


	SELECT	count(*) into v_count FROM acs_privilege_descendant_map
	WHERE 	descendant = 'add_hours_direct_reports';
	IF v_count > 0 THEN 
	   	-- There is already a descendant
		delete from acs_privilege_descendant_map where descendant = 'add_hours_for_direct_reports';
	ELSE
		update acs_privilege_descendant_map
		set descendant = 'add_hours_direct_reports'
		where descendant = 'add_hours_for_direct_reports';
	END IF;

        return 0;
END;$$ LANGUAGE 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();


update acs_permissions
set privilege = 'add_hours_direct_reports'
where privilege = 'add_hours_for_direct_reports';


update acs_permissions
set privilege = 'add_hours_for_direct_reports'
where privilege = 'add_hours_for_subordinates';


-- Delete old privilege add_hours_for_subordinates
--
delete from acs_privilege_hierarchy
where child_privilege = 'add_hours_for_subordinates';

delete from acs_permissions
where privilege = 'add_hours_for_subordinates';

delete from acs_permissions where privilege = 'add_hours_for_subordinates';
select acs_privilege__drop_privilege('add_hours_for_subordinates');




-- Add privilege to add absences for direct_reports
select acs_privilege__create_privilege('add_absences_direct_reports','Add absences for direct reports','Add absences for direct reports');
select acs_privilege__add_child('create', 'add_absences_direct_reports');
select im_priv_create('add_absences_direct_reports', 'HR Managers');
select im_priv_create('add_absences_direct_reports', 'Senior Managers');


-- Absences_for_user
update lang_messages set message = 'Absences for %user_name%'
where package_key = 'intranet-timesheet2' and locale = 'en_US' and message_key = 'Absences_for_user';
update lang_messages set message = 'Absenzen f&uuml;r %user_name%'
where package_key = 'intranet-timesheet2' and locale = 'de_DE' and message_key = 'Absences_for_user';

-- for_username
update lang_messages set message = 'for %user_from_search_name%'
where package_key = 'intranet-timesheet2' and locale = 'en_US' and message_key = 'for_username';
update lang_messages set message = 'f&uuml;r %user_from_search_name%'
where package_key = 'intranet-timesheet2' and locale = 'de_DE' and message_key = 'for_username';

-- ------------------------------------------------------
--------------------------------------------------------------
-- Remaining Vacation View
delete from im_view_columns where view_id = 291;
delete from im_views where view_id = 291;
delete from im_view_columns where view_id = 1013;
delete from im_views where view_id = 1013;


insert into im_views (view_id, view_name, view_label) 
values (291, 'remaining_vacation_list', 'Remaining Vacation');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order, variable_name,order_by_clause) 
values (29100,291,'Owner','"<a href=''/intranet-timesheet2/absences/index?user_selection=$employee_id&timescale=all&absence_type_id=$absence_type_id''>$owner_name</a>"',0,'owner_name','owner_name');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order,variable_name,order_by_clause) 
values (29110,291,'Department Name','"$department_name"',10,'department_name','department_name');

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

