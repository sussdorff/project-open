-- upgrade-5.0.2.0.0-5.0.2.0.1.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.2.0.0-5.0.2.0.1.sql','');

CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS $BODY$
 
DECLARE
        v_parameter_id                 INTEGER;
BEGIN
 
	select parameter_id into v_parameter_id from apm_parameters where parameter_name = 'GracefulErrorHandlingComponents' and package_key = 'intranet-core';
        IF      v_parameter_id is not null
        THEN
		PERFORM apm__unregister_parameter(v_parameter_id);
        END IF;
 
        RETURN 1;
 
END;$BODY$ LANGUAGE 'plpgsql';
 
SELECT inline_0 ();
DROP FUNCTION inline_0 ();
