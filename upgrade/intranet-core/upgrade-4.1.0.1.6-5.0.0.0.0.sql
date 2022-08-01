-- upgrade-4.1.0.1.6-5.0.0.0.0.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.0.1.6-5.0.0.0.0.sql','');


-- Drop translation fields if translation is not installed
create or replace function inline_0 () 
returns integer as $body$
DECLARE
	v_count			integer;
BEGIN
	-- Check that template_p exists in the database
	select	count(*) into v_count 
	from	apm_packages
	where	package_key = 'intranet-translation';
	IF v_count > 0 THEN return 1; END IF; 

	PERFORM im_dynfield_attribute__del(
		(select	attribute_id
		from	im_dynfield_attributes
		where	acs_attribute_id in (
			select	attribute_id
			from	acs_attributes
			where	object_type = 'im_project' and
				attribute_name = 'subject_area_id'
		))
	);
	
	
	PERFORM im_dynfield_attribute__del(
		(select	attribute_id
		from	im_dynfield_attributes
		where	acs_attribute_id in (
			select	attribute_id
			from	acs_attributes
			where	object_type = 'im_project' and
				attribute_name = 'source_language_id'
		))
	);

	return 0;
END;$body$ language 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();



SELECT im_lang_add_message('en_US','intranet-confdb','Apply','Apply');
SELECT im_lang_add_message('en_US','intranet-contacts','Contacts','Contacts');
SELECT im_lang_add_message('en_US','intranet-ganttproject','Dim_','Dim');
SELECT im_lang_add_message('en_US','intranet-translation','Trans_Langs','Trans Langs');
SELECT im_lang_add_message('en_US','intranet-invoices','clone','Clone');
SELECT im_lang_add_message('en_US','intranet-hr','Salary_period_','Salary Period');
-- SELECT im_lang_add_message('en_US','intranet-','','');
