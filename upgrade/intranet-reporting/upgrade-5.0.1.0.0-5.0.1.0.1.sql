-- upgrade-5.0.1.0.0-5.0.1.0.1.sql
SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-5.0.1.0.0-5.0.1.0.1.sql','');

CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS $BODY$
 
DECLARE
	v_error_stack text;
BEGIN

 	alter table im_reports ADD CONSTRAINT im_reports_report_menu_id_unique UNIQUE (report_menu_id);
        RETURN 1;
 
EXCEPTION when others then

        GET STACKED DIAGNOSTICS v_error_stack = MESSAGE_TEXT;
	RAISE NOTICE 'Unable to create unique constraint "im_reports_report_menu_id_unique" for table "im_reports": %', v_error_stack;
        RETURN 0;

END;$BODY$ LANGUAGE 'plpgsql';
 
SELECT inline_0 ();
DROP FUNCTION inline_0 ();


