-- upgrade-3.4.0.7.2-3.4.0.7.3.sql

SELECT acs_log__debug('/packages/intranet-security-update-client/sql/postgresql/upgrade/upgrade-3.4.0.7.2-3.4.0.7.3.sql','');

-- ---------------------------------------------------------------
-- Set the "verbosity" of the Update Component to "-1",
-- indicating that the user needs to confirm sending server data.
-- ---------------------------------------------------------------

update apm_parameter_values 
set attr_value = -1 
where parameter_id in (
		select	parameter_id 
		from	apm_parameters
		where	parameter_name = 'SecurityUpdateVerboseP'
	)
;



-- set package_key "intranet-security-update-client"
-- set package_id [db_string package_id "select package_id from apm_packages where package_key=:package_key" -default 0]
-- parameter::set_value \
--        -package_id $package_id \
--        -parameter "SecurityUpdateVerboseP" \
--        -value -1

