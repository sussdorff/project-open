-- upgrade-3.4.0.3.2-3.4.0.4.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.3.2-3.4.0.4.0.sql','');



----------------------------------------------------------
-- Fix implementation for user skins
----------------------------------------------------------

--        { 0  "left"          "Default" }
--        { 1  "opus5"         "Light Green" }
--        { 2  "default"       "Right Blue" }
--        { 4  "saltnpepper"   "SaltnPepper" }

SELECT im_category_new (40010, 'default', 'Intranet Skin');
SELECT im_category_new (40015, 'left', 'Intranet Skin');
SELECT im_category_new (40020, 'saltnpepper', 'Intranet Skin');
SELECT im_category_new (40025, 'lightgreen', 'Intranet Skin');

update im_categories set sort_order = 1 where category = 'left' and category_type = 'Intranet Skin';
update im_categories set sort_order = 2 where category = 'default' and category_type = 'Intranet Skin';
update im_categories set sort_order = 3 where category = 'saltnpepper' and category_type = 'Intranet Skin';
update im_categories set sort_order = 4 where category = 'lightgreen' and category_type = 'Intranet Skin';


-- Fix DynField issue with database "float"
CREATE OR REPLACE Function inline_0()
RETURNS character AS '
DECLARE
	v_count		integer;
BEGIN
	select count(*)	into v_count 
	from user_tab_columns
	where lower(table_name) = ''users'' and lower(column_name) = ''skin_id'';
	IF v_count > 0 THEN return 1; END IF;

	alter table users add skin_id integer references im_categories(category_id);
	update users set skin_id = 40020;


	select count(*)	into v_count 
	from user_tab_columns
	where lower(table_name) = ''users'' and lower(column_name) = ''skin'';
	IF v_count > 0 THEN 
		-- update users set skin_id = 40010 where skin = 2;
		update users set skin_id = 40015 where skin = 0;
		update users set skin_id = 40020 where skin = 4;
		update users set skin_id = 40025 where skin = 2;
	END IF;

	return 0;
END;' LANGUAGE 'plpgsql';
select inline_0();
drop function inline_0();

-- Catchall - set skin to "saltnpepper" by default
update users set skin_id = 40020 where skin_id is null;

