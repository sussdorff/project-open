-- upgrade-5.0.2.4.5-5.0.2.4.6.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.2.4.5-5.0.2.4.6.sql','');


-- Disable old skins
update im_categories set enabled_p = 'f' where category_id in (40010, 40015, 40025);

-- Add new "Roman Blue" skin
SELECT im_category_new (40030, 'roman', 'Intranet Skin');





create or replace function inline_0 () 
returns integer as $body$
DECLARE
	v_count			integer;
BEGIN
	-- Check if colum exists in the database
	select	count(*) into v_count from lang_message_keys where message_key = 'roman' and package_key = 'intranet-core';
	IF v_count = 0  THEN
		insert into lang_message_keys values ('roman', 'intranet-core');
	END IF; 

	select	count(*) into v_count from lang_messages 
	where message_key = 'roman' and package_key = 'intranet-core' and locale = 'en_US';
	IF v_count = 0  THEN
		insert into lang_messages values ('roman', 'intranet-core', 'en_US', 'Roman Blue');
	END IF; 

	return 0;
END;$body$ language 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();

