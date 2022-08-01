-- upgrade-5.0.0.0.0-5.0.0.0.1.sql

SELECT acs_log__debug('/packages/intranet-translation/sql/postgresql/upgrade/upgrade-5.0.0.0.0-5.0.0.0.1.sql','');

create or replace function inline_0 ()
returns integer as $BODY$
declare
        v_count                 integer;
begin

        -- milestone_p had been made a Dynfield of object im_timesheet_tasks
        -- add it manually as it's been used not only PM specific (e.g. clone project, etc.)

        select count(*) into v_count from user_tab_columns
        where lower(table_name) = 'im_projects' and lower(column_name) = 'milestone_p';

        IF      0 = v_count
        THEN
                alter table im_projects add column milestone_p character(1);
                comment on column public.im_projects.milestone_p is 'Field has been added for compatibility reasons only.';
                return 0;
        END IF;
        return 1;

end;$BODY$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();
