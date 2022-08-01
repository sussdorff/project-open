-- upgrade-5.0.1.0.1-5.0.1.0.2.sql

SELECT acs_log__debug('/packages/intranet-portfolio-management/sql/postgresql/upgrade/upgrade-5.0.1.0.1-5.0.1.0.2.sql','');


create or replace function inline_0 ()
returns integer as $$
declare
	v_count			integer;
BEGIN
	select	count(*) into v_count
	from	user_tab_columns where lower(table_name) = 'im_projects' and lower(column_name) = 'score_roi';
	IF 0 = v_count THEN return 1; END IF;

	alter table im_projects add column score_finance_roi numeric(12,1);
	update im_projects set score_finance_roi = score_roi;
	update acs_attributes set attribute_name = 'score_finance_roi' where attribute_name = 'score_roi' and table_name = 'im_projects';
	alter table im_projects drop column score_roi;

	return 0;
end;$$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


update im_menus
set url = '/intranet/projects/index?view_name=project_portfolio_list&exclude_project_type_id=2510'
where url = '/intranet/projects/index?view_name=project_portfolio_list';



delete from im_view_columns where column_id = 30010;
insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (30010,300,'Program Name',
'"<A HREF=/intranet/projects/view?project_id=$project_id>[string range $project_name 0 40]</A>"','','',10,'');

delete from im_view_columns where column_id = 30050;
insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (30050,300,'Done','[expr round(10.0 * $percent_completed) / 10.0]%','','',50,'');


