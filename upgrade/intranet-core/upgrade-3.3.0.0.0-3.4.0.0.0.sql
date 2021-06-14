-- upgrade-3.3.0.0.0-3.4.0.0.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.3.0.0.0-3.4.0.0.0.sql','');


create or replace function inline_0 ()
returns integer as '
DECLARE
        v_count                 integer;
BEGIN
	select count(*) into v_count from user_tab_columns
	where	lower(table_name) = ''users'' and lower(column_name) = ''skin'';
	IF v_count > 0 THEN return 0; END IF;

	alter table users add skin int not null default 0;

	return 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();


create or replace function inline_0 ()
returns integer as '
DECLARE
        v_count                 integer;
BEGIN
	select count(*) into v_count
	from user_tab_columns
	where	lower(table_name) = ''im_component_plugins''
		and lower(column_name) = ''menu_name'';
	IF v_count = 0 THEN
  		ALTER TABLE im_component_plugins ADD menu_name varchar(50) default null;
	END IF;

	select count(*) into v_count
	from user_tab_columns
	where	lower(table_name) = ''im_component_plugins''
		and lower(column_name) = ''menu_sort_order'';
	IF v_count = 0 THEN
  		ALTER TABLE im_component_plugins ADD menu_sort_order integer not null default 0;
	END IF;

	return 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();

