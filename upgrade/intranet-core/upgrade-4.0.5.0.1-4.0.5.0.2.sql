-- upgrade-4.0.5.0.1-4.0.5.0.2.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.5.0.1-4.0.5.0.2.sql','');

-- Create new biz-object-member roles
create or replace function inline_0 ()
returns varchar as $body$
DECLARE
	v_exists_p	integer;
BEGIN
	select count(*) into v_exists_p from im_categories
	where category_id = 1307;
	IF v_exists_p = 0 THEN
		insert into im_categories (
			category_id, category, category_type, 
			category_gif, category_description) 
		values (1307, 'Consultant', 'Intranet Biz Object Role', 
			'consultant', 'Consultant');
	END IF;
			
	select count(*) into v_exists_p from im_categories
	where category_id = 1308;
	IF v_exists_p = 0 THEN
		insert into im_categories (
			category_id, category, category_type, 
			category_gif, category_description) 
		values (1308, 'Trainer', 'Intranet Biz Object Role', 
			'trainer', 'Trainer');
	END IF;

	return 0;
end;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();



