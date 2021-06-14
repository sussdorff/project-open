-- upgrade-4.0.3.5.2-4.0.3.5.3.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.5.2-4.0.3.5.3.sql','');

update apm_parameters set description = 'Order of first and last name when shown in conjunction. Default is &quot;1&quot; for FIRST_NAME LAST_NAME. If set to &quot;2&quot; name will be shown as LAST_NAME FIRST_NAME. If set to &quot;3&quot; name will be shown as LAST_NAME, FIRST_NAME' where description like 'Order of first and last name when shown in conjunction%';


-- Delete dangeling entries in acs_objects 
-- if im_trans_tasks does not exist anymore
create or replace function inline_0() returns varchar as $body$
        DECLARE
                v_count         integer;
        BEGIN
                select count(*) into v_count from user_tab_columns
		where lower(table_name) = 'im_trans_tasks';

                IF v_count > 0 THEN
			return 1;
                END IF;

		delete from acs_objects where object_type = 'im_trans_task';
                return 0;
        END;
$body$ language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();
