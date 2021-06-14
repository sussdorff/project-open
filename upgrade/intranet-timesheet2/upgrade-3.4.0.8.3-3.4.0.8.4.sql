-- upgrade-3.4.0.8.3-3.4.0.8.4.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-3.4.0.8.3-3.4.0.8.4.sql','');



-- Rename absences for category_id=5004 from 'Bank Holiday' to 'Training', if it already exists:
--
update im_categories set category = 'Training' where category_id = 5004;

SELECT im_category_new(5004, 'Training', 'Intranet Absence Type');
SELECT im_category_new(5005, 'Bank Holiday', 'Intranet Absence Type');




create or replace function inline_0 ()
returns integer as $body$
declare
        v_count                 integer;
begin
	select count(*) into v_count from pg_constraint
	where lower(conname) = 'im_user_absences_group_ck';
        if v_count = 0 then return 1; end if;

	alter table im_user_absences drop constraint im_user_absences_group_ck;

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



