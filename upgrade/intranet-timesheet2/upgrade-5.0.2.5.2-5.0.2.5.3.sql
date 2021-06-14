SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-5.0.2.5.2-5.0.2.5.3.sql','');

-- ------------------------------------------
-- Manager Vacation Replacement
-- in order to prevent employees
-- from approving vacations for colleagues
---------------------------------------------

CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS $$
DECLARE
        v_count                 integer;
BEGIN
    SELECT	count(*) into v_count FROM user_tab_columns
    WHERE 	lower(table_name) = 'im_user_absences' and
    lower(column_name) = 'manager_vacation_replacement_id';

    IF v_count > 0 THEN return 1; END IF;

    ALTER TABLE im_user_absences
    ADD column manager_vacation_replacement_id integer
    CONSTRAINT im_user_absences_mgr_vacation_replacement_fk REFERENCES parties;

        return 0;
END;$$ LANGUAGE 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();



SELECT im_dynfield_widget__new (
    null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
    'absence_mgr_vacation_replacements', 'Manager Vacation Replacements', 'Manager Vacation Replacements',
    10007, 'integer', 'generic_sql', 'integer',
    '{custom {sql {
        select	p.person_id,
            im_name_from_user_id(p.person_id) as person_name
        from 
            persons p
        where
            p.person_id in (
                select	member_id
                from	group_distinct_member_map
                where	group_id in (
                        select	group_id
                        from	groups
                        where	group_name = ''Manager/Leads''
                    )
            )
        order by 
            lower(first_names), lower(last_name)
    }}}'
);

SELECT im_dynfield_attribute_new ('im_user_absence', 'manager_vacation_replacement_id', 'Manager Replacement', 'absence_mgr_vacation_replacements', 'integer', 'f');


update im_dynfield_type_attribute_map set default_value = 'global_var {absence_owner_id current_user_id} tcl {db_string supervisor "select supervisor_id from im_employees where employee_id = $absence_owner_id" -default "$current_user_id"}' where attribute_id = (select attribute_id from im_dynfield_attributes where acs_attribute_id = (select attribute_id from acs_attributes where attribute_name = 'manager_vacation_replacement_id' and object_type = 'im_user_absence'));

-- Limit Permission 

create or replace function inline_1 ()
returns integer as '
declare
        v_attribute          integer;
        v_managers              integer;
begin

    select da.attribute_id into v_attribute from im_dynfield_attributes da, acs_attributes aa where da.acs_attribute_id = aa.attribute_id and aa.attribute_name = ''manager_vacation_replacement_id'';
    select group_id into v_managers from groups where group_name = ''Manager/Leads'' or group_name = ''Senior Managers'';
    delete from acs_permissions where object_id = v_attribute;
    
    IF v_managers = null THEN return 1; END IF;

    PERFORM acs_permission__grant_permission(v_attribute, v_managers, ''read'');
    PERFORM acs_permission__grant_permission(v_attribute, v_managers, ''write'');

    return 0;
end;' language 'plpgsql';
select inline_1 ();
drop function inline_1();

-- Overwrite vacation procedure
create or replace function im_workflow__assign_to_vacation_replacement_if(
    p_task_id           integer,
    p_case_id           integer,
    p_owner_id          integer,
    p_supervisor_id     integer,
    p_transition_key    varchar,
    p_creation_user     integer,
    p_creation_ip       varchar,
    p_object_type       varchar
)
returns void as
$$
declare
    v_vacation_replacement_id   integer;
    v_vacation_replacement_name varchar;
    v_journal_id                integer;
    v_slack_time_days           integer;
    v_msg                       varchar;
    v_table_exists_p            boolean;
begin

    select true
    into v_table_exists_p 
    from pg_class c 
    inner join pg_attribute a 
    on (a.attrelid=c.oid) 
    where relname='im_user_absences' 
    and attname='vacation_replacement_id';

    if v_table_exists_p is null then
        return;
    end if;

    select attr_value into v_slack_time_days
    from apm_parameter_values pv
    inner join apm_packages pkg
    on (pkg.package_id=pv.package_id)
    inner join apm_parameters p
    on (p.parameter_id=pv.parameter_id)
    where pkg.package_key='intranet-timesheet2' and p.parameter_name='TimesheetSlackTimeDays';

    if v_slack_time_days is null then
        raise exception 'intranet-timesheet2/TimesheetSlackTimeDays parameter must be a number';
    end if;

    -- check if the supervisor_id found is currently on vacation 
    -- (quick query in im_user_absences if now is in between absence dates)
    -- End date is usually at 0:00 in the morning, hence the adding of the 1 day to make sure it is correctly opened
    -- Only for active absences

    select manager_vacation_replacement_id, person__name(manager_vacation_replacement_id) 
    into v_vacation_replacement_id, v_vacation_replacement_name
    from im_user_absences
    where owner_id = p_supervisor_id
    and (now() between (start_date - (v_slack_time_days || ' days')::interval) and  (end_date + '1 days'::interval))
    and absence_status_id = 16000;

    -- In case an absence is found, check if there is a vacation_replacement_id. 

    if v_vacation_replacement_id = p_owner_id then

        select supervisor_id, person__name(supervisor_id)
        into v_vacation_replacement_id, v_vacation_replacement_name
        from im_employees
        where employee_id = p_supervisor_id;

        v_msg = 'Assigning to ' || v_vacation_replacement_name || ', the supervisor of ' || person__name(p_supervisor_id) || '.';
    else
        v_msg = 'Assigning to ' || v_vacation_replacement_name || ', the vacation replacement of ' || person__name(p_supervisor_id) || '.';
    end if;

    if v_vacation_replacement_id is not null then

        -- If there is, assign the workflow to both the supervisor_id and the 
        -- vacation_replacement_id. Record this additional assigning in the 
        -- workflow journal as well.

        v_journal_id := journal_entry__new(
            null, 
            p_case_id,
            p_transition_key || ' assign_to_supervisor ' || v_vacation_replacement_name,
            p_transition_key || ' assign_to_supervisor ' || v_vacation_replacement_name,
            now(), 
            p_creation_user, 
            p_creation_ip,
            v_msg
        );

        perform workflow_case__add_task_assignment(p_task_id, v_vacation_replacement_id, 'f');

        perform workflow_case__notify_assignee (p_task_id, v_vacation_replacement_id, null, null, 
            'wf_' || p_object_type || '_assignment_notif');

    end if;
end;
$$ language 'plpgsql';
