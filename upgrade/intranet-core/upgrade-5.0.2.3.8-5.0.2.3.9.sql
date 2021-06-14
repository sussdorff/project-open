-- upgrade-5.0.2.3.8-5.0.2.3.9.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.2.3.8-5.0.2.3.9.sql','');



CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS $BODY$
declare
        v_count                 integer;
begin
	select count(*) into v_count from user_tab_columns 
	where lower(table_name) = 'im_project' and lower(column_name) = 'project_wbs';
        IF v_count > 0 THEN return 1; END IF;

	alter table im_projects add column project_wbs text;

        return 0;
end;$BODY$ LANGUAGE 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();

