-- upgrade-5.0.1.0.0-5.0.1.0.1.sql

SELECT acs_log__debug('/packages/intranet-portfolio-management/sql/postgresql/upgrade/upgrade-5.0.1.0.0-5.0.1.0.1.sql','');


create or replace function inline_0 ()
returns integer as $$
declare
	v_count			integer;
BEGIN
	select	count(*) into v_count
	from	user_tab_columns where lower(table_name) = 'im_projects' and lower(column_name) = 'project_roi';
	IF 0 = v_count THEN return 1; END IF;

	alter table im_projects add column score_finance_roi numeric(12,1);
	update im_projects set score_finance_roi = project_roi;
	update acs_attributes set attribute_name = 'score_finance_roi' where attribute_name = 'project_roi' and table_name = 'im_projects';
	alter table im_projects drop column project_roi;

	alter table im_projects add column score_strategic numeric(12,1);
	update im_projects set score_strategic = project_strategic_value;
	update acs_attributes set attribute_name = 'score_strategic' where attribute_name = 'project_strategic_value' and table_name = 'im_projects';
	alter table im_projects drop column project_strategic_value;

	return 0;
end;$$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();
