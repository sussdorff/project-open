-- upgrade-5.0.0.0.1-5.0.0.0.2.sql

SELECT acs_log__debug('/packages/intranet-translation/sql/postgresql/upgrade/upgrade-5.0.0.0.1-5.0.0.0.2.sql','');

create or replace function inline_0 ()
returns integer as $BODY$
declare
        v_count                 integer;
begin

        -- final_company had been removed from core project
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = 'im_projects' and lower(column_name) = 'final_company';

        IF      0 = v_count
        THEN
                alter table im_projects add column final_company character(50);
                comment on column public.im_projects.milestone_p is 'Field has been added for compatibility reasons only.';
                return 0;
        END IF;
        return 1;

end;$BODY$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();
