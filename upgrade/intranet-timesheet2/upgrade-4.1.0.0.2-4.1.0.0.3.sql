SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.1.0.0.2-4.1.0.0.3.sql','');

update im_dynfield_widgets set parameters =
        '{custom {sql {
            select  p.person_id,
                    im_name_from_user_id(p.person_id) as person_name
            from 
                    persons p 
                    inner join im_employees e on (p.person_id = e.employee_id)
            where
                    e.end_date >= now() and
                    p.person_id in (
                            select  member_id
                            from    group_distinct_member_map
                            where   group_id in (
                                            select  group_id
                                            from    groups
                                            where   group_name = ''Employees''
                                    )
                    )
            order by 
                    lower(first_names), lower(last_name)
        }}}'
where widget_name = 'absence_vacation_replacements';


select im_dynfield_widget__new (
    null, 
    'im_dynfield_widget', 
    now(), 
    0, 
    '0.0.0.0', 
    null,
    'absence_vacation_replacements',
    'Absence Vacation Replacements', 
    'Absence Vacation Replacements',
    10007, 
    'integer', 
    'generic_sql', 
    'integer',
        '{custom {sql {
            select  p.person_id,
                    im_name_from_user_id(p.person_id) as person_name
            from 
                    persons p 
                    inner join im_employees e on (p.person_id = e.employee_id)
            where
                    e.end_date >= now() and
                    p.person_id in (
                            select  member_id
                            from    group_distinct_member_map
                            where   group_id in (
                                            select  group_id
                                            from    groups
                                            where   group_name = ''Employees''
                                    )
                    )
            order by 
                    lower(first_names), lower(last_name)
        }}}'
);
