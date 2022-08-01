-- upgrade-5.0.2.0.1-5.0.2.0.2.sql
SELECT acs_log__debug('/packages/intranet-reporting-indicators/sql/postgresql/upgrade/upgrade-5.0.2.0.1-5.0.2.0.2.sql','');

alter table im_indicators drop constraint if exists im_indicator_low_warn_critical;
alter table im_indicators drop constraint if exists im_indicator_low_warn_critical_ck;

alter table im_indicators drop constraint if exists im_indicator_high_warn_critical;
alter table im_indicators drop constraint if exists im_indicator_high_warn_critical_ck;

-- im_indicator_low_warn_critical
CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS $BODY$
DECLARE
        v_error_stack text;
BEGIN
	ALTER TABLE im_indicators 
	ADD constraint im_indicator_low_warn_critical_ck 
	CHECK(indicator_low_warn > indicator_low_critical);
        RETURN 1;

EXCEPTION WHEN others THEN
 
        GET STACKED DIAGNOSTICS v_error_stack = MESSAGE_TEXT;
        RAISE NOTICE 'Unable to create constraint "im_indicator_low_warn_critical" for table "im_indicators": %', v_error_stack;
        RETURN 0;
 
END;$BODY$ LANGUAGE 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();


-- im_indicator_high_warn_critical
CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS $BODY$
DECLARE
        v_error_stack text;
BEGIN
        ALTER TABLE im_indicators 
	ADD constraint im_indicator_high_warn_critical_ck
	CHECK(indicator_high_critical > indicator_high_warn);
        RETURN 1;

EXCEPTION WHEN others THEN

        GET STACKED DIAGNOSTICS v_error_stack = MESSAGE_TEXT;
        RAISE NOTICE 'Unable to create constraint "im_indicator_high_warn_critical" for table "im_indicators": %', v_error_stack;
        RETURN 0;

END;$BODY$ LANGUAGE 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();

