-- upgrade-3.2.8.0.0-3.2.9.0.0.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-3.2.8.0.0-3.2.9.0.0.sql','');



-------------------------------------------------------------
-- Project Insert Trigger

create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from pg_trigger
        where lower(tgname) = ''im_projects_project_cache_ins_tr'';
        IF v_count = 0 THEN return 0; END IF;
        DROP TRIGGER im_projects_project_cache_ins_tr ON im_projects;
        return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();




-------------------------------------------------------------
-- Project Delete Trigger

create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from pg_trigger
        where lower(tgname) = ''im_projects_project_cache_del_tr'';
        IF v_count = 0 THEN return 0; END IF;
        DROP TRIGGER im_projects_project_cache_del_tr ON im_projects;
        return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();


