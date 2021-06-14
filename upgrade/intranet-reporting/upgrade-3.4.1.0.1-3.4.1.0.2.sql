-- upgrade-3.4.1.0.1-3.4.1.0.2.sql

SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-3.4.1.0.1-3.4.1.0.2.sql','');

-- --------------------------------------------
-- New report "Show all project Tasks"
-- --------------------------------------------

create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;

        -- Menu IDs
        v_menu                  integer;
        v_main_menu             integer;
	
        -- Groups
        v_employees             integer;
        v_accounting            integer;
        v_senman                integer;
        v_customers             integer;
        v_freelancers           integer;
        v_proman                integer;
        v_admins                integer;
begin
        select count(*) into v_count from im_views where view_id = 930;
        IF v_count > 0 THEN return 1; END IF;

	insert into im_views (view_id, view_name, visible_for) values (930, ''im_timesheet_task_list_report'', ''view_projects'');

	select into v_count column_id from im_view_columns order by column_id desc limit 1;

	insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
	extra_select, extra_where, sort_order, visible_for) values (v_count+1,930,NULL,''"Task Name"'',
	''"<nobr>$indent_html$gif_html<a href=/intranet-timesheet2-tasks/new?[export_url_vars project_id task_id return_url]>
	$task_name</a></nobr>"'','''','''',2,'''');

        insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
        extra_select, extra_where, sort_order, visible_for) values (v_count+2,930,NULL,''Material'',
        ''"<a href=/intranet-material/new?[export_url_vars material_id return_url]>$material_nr</a>"'',
        '''','''',4,'''');

        insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
        extra_select, extra_where, sort_order, visible_for) values (v_count+3,930,NULL,''"CC"'',
        ''"<a href=/intranet-cost/cost-centers/new?[export_url_vars cost_center_id return_url]>$cost_center_code</a>"'',
        '''','''',6,'''');

        insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
        extra_select, extra_where, sort_order, visible_for) values (v_count+4,930,NULL,''"Start"'',
        ''"<nobr>[lc_time_fmt [string range $start_date 0 9] %x]</nobr>"'','''','''',7,'''');

        insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
        extra_select, extra_where, sort_order, visible_for) values (v_count+5,930,NULL,''"End"'',
        ''"[if {[string equal t $red_p]} { set t "<nobr><font color=red>[lc_time_fmt [string range $end_date 0 9] %x]</font></nobr>" } else { set t "<nobr>[string range $end_date 0 9]</nobr>" }]"'',''(child.end_date < now() and coalesce(child.percent_completed,0) < 100) as red_p'','''',8,'''');

        insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
        extra_select, extra_where, sort_order, visible_for) values (v_count+6,930,NULL,''Plan'',
        ''"$planned_units"'','''','''',10,'''');

        insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
        extra_select, extra_where, sort_order, visible_for) values (v_count+7,930,NULL,''Bill'',
        ''"$billable_units"'','''','''',12,'''');

        insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
        extra_select, extra_where, sort_order, visible_for) values (v_count+8,930,NULL,''Log'',
        ''"<p align=right><a href=[export_vars -base $timesheet_report_url { task_id { project_id $project_id } return_url}]>
        $reported_units_cache</a></p>"'','''','''',14,'''');

        insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
        extra_select, extra_where, sort_order, visible_for) values (v_count+9,930,NULL,''UoM'',
        ''$uom'','''','''',16,'''');

        -- insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
        -- extra_select, extra_where, sort_order, visible_for) values (v_count+10,930,NULL, ''Description'',
        -- ''[string_truncate -len 80 " $description"]'', '''','''',20,'''');

        insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
        extra_select, extra_where, sort_order, visible_for) values (v_count+11,930,NULL, ''Done'',
        ''"$percent_completed"'',
        '''','''',21,'''');

	---------------------------------------------------------
	-- Create Menu
	--

        select group_id into v_admins from groups where group_name = ''P/O Admins'';
        select group_id into v_senman from groups where group_name = ''Senior Managers'';
        select group_id into v_proman from groups where group_name = ''Project Managers'';
        select group_id into v_accounting from groups where group_name = ''Accounting'';
        select group_id into v_employees from groups where group_name = ''Employees'';
        select group_id into v_customers from groups where group_name = ''Customers'';
        select group_id into v_freelancers from groups where group_name = ''Freelancers'';

        select menu_id into v_main_menu from im_menus where label=''reporting-other'';

        v_menu := im_menu__new (
                null,                                   -- p_menu_id
                ''acs_object'',                         -- object_type
                now(),                                  -- creation_date
                null,                                   -- creation_user
                null,                                   -- creation_ip
                null,                                   -- context_id
                ''intranet-reporting'',                 -- package_name
                ''reporting-project-tasks'',             -- label
                ''Show all project tasks'',             -- name
                ''/intranet-reporting/project-tasks.tcl'',  -- url
                90,                                     -- sort_order
                v_main_menu,                            -- parent_menu_id
                null                                    -- p_visible_tcl
        );

        PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
        PERFORM acs_permission__grant_permission(v_menu, v_senman, ''read'');

	RETURN 0;
	
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

