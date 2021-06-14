-- upgrade-3.4.0.8.5-3.4.0.8.6.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.8.5-3.4.0.8.6.sql','');




-- Groups of projects = "program"
-- To be added to the ProjectNewPage via DynField
create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = ''im_projects'' and lower(column_name) = ''program_id'';
	IF v_count > 0 THEN return 1; END IF;

	alter table im_projects add
	program_id                      integer
	                                constraint im_projects_program_id
	                                references im_projects;

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




SELECT im_category_new (2510, 'Program', 'Intranet Project Type');
update im_categories
set category_description = 'A group of projects with common resources or a common budget'
where category_id = 2510;


