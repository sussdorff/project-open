-- upgrade-5.0.2.3.4-5.0.2.3.5.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.2.3.6-5.0.2.3.7.sql','');




create or replace function inline_0()
returns integer as $body$
DECLARE
	v_count		integer;
BEGIN
	select	count(*) into v_count from im_categories
	where	category_id = 1309;
	IF v_count > 0 THEN return 1; END IF;

	-- New role for Conf Items
	insert into im_categories (
		category_id, category, category_type, 
		category_gif, category_description) 
	values (1309, 'Conf Item Manager', 'Intranet Biz Object Role', 
	       'member', 'Conf Item Manager');

	-- Add the new role as a valid role for configuration items
	insert into im_biz_object_role_map values ('im_conf_item',85,1309);

	return 0;
END;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();

