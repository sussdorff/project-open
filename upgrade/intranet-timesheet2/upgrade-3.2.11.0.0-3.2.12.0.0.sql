-- upgrade-3.2.11.0.0-3.2.12.0.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-3.2.11.0.0-3.2.12.0.0.sql','');



create or replace function inline_0 () returns integer as '
declare
	v_count integer; 
begin 
	select count(*) into v_count 
	from pg_constraint where lower(conname) = ''im_hours_project_fk''; 
	IF v_count > 0 THEN return 0; END IF; 

	alter table im_hours add constraint im_hours_project_fk foreign key(project_id) references im_projects; 

	return v_count; 
end;' language 'plpgsql';
SELECT inline_0(); 
DROP FUNCTION inline_0();
