-- upgrade-3.4.1.0.5-3.4.1.0.6.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.1.0.5-3.4.1.0.6.sql','');

-- configure ajax columns


-- Introduce default_tax field
create or replace function inline_0 ()
returns integer as $body$
DECLARE
	v_count			integer;
BEGIN
	select	count(*) into v_count from user_tab_columns
	where	lower(table_name) = 'im_view_columns' and lower(column_name) = 'ajax_configuration';
        IF v_count > 0 THEN return 0; END IF;

	alter table im_view_columns add ajax_configuration text;

        return 0;
end; $body$ language 'plpgsql';
select inline_0();
drop function inline_0();

SELECT im_category_new (1415, 'Ajax', 'Intranet DynView Type');

