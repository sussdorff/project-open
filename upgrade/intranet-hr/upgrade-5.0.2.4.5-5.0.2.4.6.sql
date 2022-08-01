-- upgrade-5.0.2.4.5-5.0.2.4.6.sql
SELECT acs_log__debug('/packages/intranet-hr/sql/postgresql/upgrade/upgrade-5.0.2.4.5-5.0.2.4.6.sql','');





-- REST Data-Source for the report
SELECT im_report_new (
	'HR - Vacation Balance',					-- report_name
	'hr_vacation_balance',						-- report_code
	'intranet-hr',							-- package_key
	220,								-- report_sort_order
	(select menu_id from im_menus where label = 'reporting-other'),	-- parent_menu_id
	''
);


update im_reports set 
report_description = 'Vacation balance for all employees.',
report_sql = '
select 
       ''<a href=/intranet/users/view?user_id=''||user_id||'' target=_>''||user_name||''</a>'' as user,
       vacation_balance_from_last_year,
       vacation_days_per_year,
       vacation_days_taken,
       vacation_balance_from_last_year + vacation_days_per_year - vacation_days_taken as vacation_left_this_year
from (
       select u.user_id,
              im_name_from_user_id(u.user_id) as user_name,
              e.vacation_days_per_year,
              coalesce(e.vacation_balance,0.0) as vacation_balance_from_last_year,
              coalesce((select sum(duration_days)
                      from    im_user_absences a
                      where   a.owner_id = e.employee_id and
                              a.start_date < date_trunc(''year'', now())::date +365 and
                              a.end_date >= date_trunc(''year'', now())::date and
                              a.absence_type_id in (select * from im_sub_categories(5000)) and
                              a.absence_status_id not in (16002, 16006)
               ),0.0) as vacation_days_taken
        from   cc_users u,
               im_employees e
        where  u.user_id = e.employee_id and
               u.member_state = ''approved''
        ) t
order by user_name'
where report_code = 'hr_vacation_balance';

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'hr_vacation_balance'),
	(select group_id from groups where group_name = 'Accounting'),
	'read'
);

-- HR Managers profile might have been deleted...
SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'hr_vacation_balance'),
	(coalesce(
		(select group_id from groups where group_name = 'HR Managers'),
		(select group_id from groups where group_name = 'Accounting')

	)),
	'read'
);
