-- upgrade-3.2.1.0.0-3.2.2.0.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.2.1.0.0-3.2.2.0.0.sql','');

\i upgrade-3.0.0.0.first.sql


-- Add URLs for object type "Timesheet Task"
create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select  count(*) into v_count from im_biz_object_urls
	where   object_type = ''im_timesheet_task'' and url_type = ''view'';
	if v_count = 1 then return 0; end if;

	insert into im_biz_object_urls (object_type, url_type, url) values (
	''im_timesheet_task'',''view'',''/intranet/projects/view?project_id='');
	insert into im_biz_object_urls (object_type, url_type, url) values (
	''im_timesheet_task'',''edit'',''/intranet/projects/new?project_id='');

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



-- Counter without number restriction
--
create or replace function im_day_enumerator (date, date) 
returns setof date as '
declare
	p_start_date		alias for $1;
	p_end_date		alias for $2;
	v_date		date;
BEGIN
	v_date := p_start_date;
	WHILE (v_date < p_end_date) LOOP
		RETURN NEXT v_date;
		v_date := v_date + 1;
	END LOOP;
	RETURN;
end;' language 'plpgsql';




-- Helper functions to make our queries easier to read
-- and to avoid outer joins with parent projects etc.
--
-- Now: With varchar(1000) = length(project_name)
--
create or replace function im_project_name_from_id (integer)
returns varchar as '
DECLARE
	p_project_id	alias for $1;
	v_project_name	varchar(1000);
BEGIN
	select project_name into v_project_name from im_projects
	where project_id = p_project_id;

	return v_project_name;
end;' language 'plpgsql';



-----------------------------------------------
-- Configuration Management:
-- Add "enabled_p" to menus and components
--

create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select  count(*) into v_count from user_tab_columns
	where   lower(table_name) = ''im_menus'' and lower(column_name) = ''enabled_p'';
	if v_count = 1 then return 0; end if;

	alter table im_menus add enabled_p char(1);
	alter table im_menus alter enabled_p set default ''t'';
	update im_menus set enabled_p = ''t'';
	alter table im_menus add constraint im_menus_enabled_ck
		check (enabled_p in (''t'',''f''));

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select  count(*) into v_count from user_tab_columns
	where   lower(table_name) = ''im_component_plugins'' and lower(column_name) = ''enabled_p'';
	if v_count = 1 then return 0; end if;

	alter table im_component_plugins add enabled_p char(1);
	alter table im_component_plugins alter enabled_p set default ''t'';
	update im_component_plugins set enabled_p = ''t'';
	alter table im_component_plugins add constraint im_comp_plugin_enabled_ck
		check (enabled_p in (''t'',''f''));

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();
