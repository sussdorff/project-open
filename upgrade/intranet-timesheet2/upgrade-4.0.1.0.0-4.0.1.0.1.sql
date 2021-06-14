-- upgrade-4.0.1.0.0-4.0.1.0.1.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.0.1.0.0-4.0.1.0.1.sql','');

-- -------------------------------------------------------
-- Create nerw Absence types for module intranet-overtime 
-- -------------------------------------------------------

CREATE OR REPLACE FUNCTION inline_0 () 
RETURNS INTEGER AS '

declare
        v_count                 integer;
	v_null			integer;	
begin

        select count(*) into v_count from im_categories
        where category_id = 5006 or category_id = 5007;

        IF      0 != v_count
        THEN
                RAISE NOTICE ''upgrade-4.0.1.0.0-4.0.1.0.1.sql failed - could not add categories'';
                return 0;
        END IF;

        SELECT INTO v_null im_category_new(5006, ''Overtime'', ''Intranet Absence Type'');
        SELECT INTO v_null im_category_new(5007, ''Reduction in Working Hours'', ''Intranet Absence Type'');

        return 1;

end;' LANGUAGE 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();
