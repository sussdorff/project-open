-- 4.1.0.0.9-4.1.0.1.0.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.0.0.9-4.1.0.1.0.sql','');



create or replace function inline_0 () 
returns integer as $body$
DECLARE
	v_count			integer;
BEGIN
	select	count(*) into v_count 
	from	user_tab_columns 
	where	lower(table_name) = 'im_categories' and
		lower(column_name) = 'visible_tcl';
	IF v_count > 0  THEN return 1; END IF; 

	alter table im_categories
	add column visible_tcl text;

	return 0;
END;$body$ language 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();
