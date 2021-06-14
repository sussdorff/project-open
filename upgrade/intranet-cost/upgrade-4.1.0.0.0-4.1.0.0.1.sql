-- upgrade-4.1.0.0.0-4.1.0.0.1.sql
SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-4.1.0.0.0-4.1.0.0.1.sql','');

-- Create new invoice type for invoice corrections
create or replace function inline_0 ()
returns varchar as $body$
DECLARE
	v_exists_p	integer;
BEGIN
	select count(*) into v_exists_p from im_categories
	where category_id = 3725;
	IF v_exists_p = 0 THEN
		insert into im_categories (
			category_id, category, category_type, 
			sort_order) 
		values (3725, 'Customer Invoice Correction', 'Intranet Cost Type', 
			3725);
	END IF;
	PERFORM im_category_hierarchy_new (3725, 3708);
    	
	select count(*) into v_exists_p from im_categories
	where category_id = 3735;
	IF v_exists_p = 0 THEN
		insert into im_categories (
			category_id, category, category_type, 
			sort_order) 
		values (3735, 'Provide Bill Correction', 'Intranet Cost Type', 
			3735);
	END IF;
    PERFORM im_category_hierarchy_new (3735, 3710);

	return 0;
end;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();



