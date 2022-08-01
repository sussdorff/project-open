-- upgrade-5.0.2.3.4-5.0.2.3.5.sql

SELECT acs_log__debug('/packages/intranet-gantt-editor/sql/postgresql/upgrade/upgrade-5.0.2.3.4-5.0.2.3.5.sql', '');
SELECT acs_log__debug('/packages/intranet-gantt-editor/sql/postgresql/upgrade/upgrade-5.0.2.3.4-5.0.2.3.5.sql','');



-- Check for assignments of project members to other projects or for absences
--
SELECT im_report_new (
	'REST Project Member Assignments and Absences',			-- report_name
	'rest_project_member_assignments_absences',			-- report_code
	'intranet-gantt-editor',							-- package_key
	230,								-- report_sort_order
	(select menu_id from im_menus where label = 'reporting-rest'),	-- parent_menu_id
	''
);


update im_reports set 
       report_description = 'Lists absences and assignments to other projects of the members of a project',
       report_sql = '
		select	t.*,
			im_name_from_user_id(user_id) as user_name,
			acs_object__name(context_id) as context
		from	(
			select
				a.absence_id as object_id,
				''im_user_absence'' as object_type,
				a.owner_id as user_id,
				a.start_date,
				a.end_date,
				100 as percentage,
				a.absence_name as name,
				0 as context_id
			from	im_user_absences a
			where	a.owner_id in (
					select distinct
						object_id_two
					from	acs_rels,
						im_projects sub_p,
						im_projects main_p
					where	object_id_one = sub_p.project_id and
						sub_p.tree_sortkey between main_p.tree_sortkey and tree_right(main_p.tree_sortkey) and
						main_p.project_id = %main_project_id%
				) and
				a.end_date >= (select start_date from im_projects where project_id = %main_project_id%) and
				a.start_date <= (select end_date from im_projects where project_id = %main_project_id%)
		UNION
			select
				a.absence_id as object_id,
				''im_user_absence'' as object_type,
				gei.element_id as user_id,
				a.start_date,
				a.end_date,
				100 as percentage,
				a.absence_name as name,
				0 as context_id
			from	im_user_absences a,
				group_element_index gei
			where	a.group_id = gei.group_id and
				gei.element_id in (
					select distinct
						object_id_two
					from	acs_rels,
						im_projects sub_p,
						im_projects main_p
					where	object_id_one = sub_p.project_id and
						sub_p.tree_sortkey between main_p.tree_sortkey and tree_right(main_p.tree_sortkey) and
						main_p.project_id = %main_project_id%
				) and
				a.end_date >= (select start_date from im_projects where project_id = %main_project_id%) and
				a.start_date <= (select end_date from im_projects where project_id = %main_project_id%)
		UNION
			select	p.project_id as object_id,
				''im_project'' as object_type,
				pe.person_id as user_id,
				p.start_date,
				p.end_date,
				coalesce(bom.percentage, 0) as percentage,
				p.project_name as name,
				(select main_p.project_id from im_projects main_p 
				where main_p.tree_sortkey = tree_root_key(p.tree_sortkey)
				) as context_id
			from	persons pe,
				im_projects p,
				acs_rels r,
				im_biz_object_members bom
			where	r.rel_id = bom.rel_id and
				r.object_id_one = p.project_id and
				r.object_id_two = pe.person_id and
				pe.person_id in (
					select distinct
						object_id_two
					from	acs_rels,
						im_projects sub_p,
						im_projects main_p
					where	object_id_one = sub_p.project_id and
						sub_p.tree_sortkey between main_p.tree_sortkey and tree_right(main_p.tree_sortkey) and
						main_p.project_id = %main_project_id%
				) and p.project_id not in (
					select	sub_p.project_id
					from	im_projects sub_p,
						im_projects main_p
					where	sub_p.tree_sortkey between main_p.tree_sortkey and tree_right(main_p.tree_sortkey) and
						main_p.project_id = %main_project_id%
				) and
				p.end_date >= (select start_date from im_projects where project_id = %main_project_id%) and
				p.start_date <= (select end_date from im_projects where project_id = %main_project_id%)

			) t
		where	percentage > 0.0
		order by
			object_type,
			object_id,
			user_id
'       
where report_code = 'rest_project_member_assignments_absences';

-- Relatively permissive
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'rest_project_member_assignments_absences'),
	(select group_id from groups where group_name = 'Employees'),
	'read'
);

