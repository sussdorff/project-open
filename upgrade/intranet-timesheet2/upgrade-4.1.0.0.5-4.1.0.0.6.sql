SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.1.0.0.5-4.1.0.0.6.sql','');

-- -------------------------------------------------------
-- Create new Absence types for weekends
-- -------------------------------------------------------

CREATE OR REPLACE FUNCTION inline_0 () 
RETURNS INTEGER AS
$$
declare
        v_count                 integer;
	v_null			integer;	
begin

        select count(*) into v_count from im_categories
        where category_id = 5009;

        IF      0 != v_count
        THEN
                RAISE NOTICE 'upgrade-4.1.0.0.5-4.1.0.0.6.sql failed - could not add categories';
                return 0;
        END IF;

        SELECT INTO v_null im_category_new(5009, 'Weekend', 'Intranet Absence Type');
	update im_categories set enabled_p='f' where category_id = 5009;
	insert into im_category_hierarchy (child_id ,parent_id) values (5009,5005);

    perform im_new_menu(
            'intranet-timesheet2',
            'timesheet2_remaining_vacation',
            'Remaining Vacation Report',
            '/intranet-timesheet2/leave-entitlements/remaining-vacation',
            20,
            'timesheet2_absences',
            null
    );

    perform im_new_menu_perms('timesheet2_remaining_vacation', 'Employees');

    return 1;

end;
$$ LANGUAGE 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();

update im_dynfield_type_attribute_map set default_value = 'global_var {absence_owner_id current_user_id} tcl {db_string supervisor "select supervisor_id from im_employees where employee_id = $absence_owner_id" -default "$current_user_id"}' where attribute_id = (select attribute_id from im_dynfield_attributes where acs_attribute_id = (select attribute_id from acs_attributes where attribute_name = 'vacation_replacement_id' and object_type = 'im_user_absence'));
