-- upgrade-4.0.2.0.5-4.0.2.0.6.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.2.0.5-4.0.2.0.6.sql','');




create or replace function inline_0 ()
returns integer as $body$
declare
	v_count	 integer;
begin
	select count(*) into v_count from user_tab_columns
	where table_name = 'IM_BIZ_OBJECTS' and column_name = 'LOCK_USER';
	IF v_count = 0 THEN
		alter table im_biz_objects
		add column lock_user integer
		constraint im_biz_object_lock_user_fk
		references persons;
	END IF;

	select count(*) into v_count from user_tab_columns
	where table_name = 'IM_BIZ_OBJECTS' and column_name = 'LOCK_DATE';
	IF v_count = 0 THEN
		alter table im_biz_objects
		add column lock_date timestamptz;
	END IF;

	select count(*) into v_count from user_tab_columns
	where table_name = 'IM_BIZ_OBJECTS' and column_name = 'LOCK_IP';
	IF v_count = 0 THEN
		alter table im_biz_objects
		add column lock_ip text;
	END IF;

	return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



-- Fix "checkbox" widget in Widget Gallery
update im_dynfield_widgets
set parameters = '{options {{"" t}}}'
where widget_name = 'checkbox';

