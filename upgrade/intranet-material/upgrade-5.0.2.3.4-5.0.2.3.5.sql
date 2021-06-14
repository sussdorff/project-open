-- upgrade-5.0.2.3.4-5.0.2.3.5.sql

SELECT acs_log__debug('/packages/intranet-material/sql/postgresql/upgrade/upgrade-5.0.2.3.4-5.0.2.3.5.sql','');


SELECT im_category_new(9020, 'Customer Material', 'Intranet Material Type');

-- Make all material types subtypes of "Customer Material"
create or replace function inline_0()
returns integer as $body$
DECLARE
        row     RECORD;
BEGIN
        FOR row IN
                select * from im_categories
                where category_type = 'Intranet Material Type' and
                      category_id != 9020
        LOOP
                PERFORM im_category_hierarchy_new(row.category_id,9020);
        END LOOP;
        return 0;
END;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();

SELECT im_category_new(9022, 'Provider Material', 'Intranet Material Type');


