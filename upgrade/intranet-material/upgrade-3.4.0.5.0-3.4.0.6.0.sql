-- upgrade-3.4.0.5.0-3.4.0.6.0.sql

SELECT acs_log__debug('/packages/intranet-material/sql/postgresql/upgrade/upgrade-3.4.0.5.0-3.4.0.6.0.sql','');


create or replace function inline_0 ()
returns integer as '
DECLARE
	v_count		integer;
BEGIN
	select	count(*) into v_count
	from	user_tab_columns
	where	lower(table_name) = ''im_materials''
		and lower(column_name) = ''material_billable_p'';
	IF v_count > 0 THEN return 0; END IF;

	alter table im_materials add
	material_billable_p	char(1) default ''t'';

	alter table im_materials add
	constraint im_materials_billable_ck
	check (material_billable_p in (''t'',''f''));

	return 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();


delete from im_view_columns where column_id = 90009;

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (90009,900,NULL,'Bill',
'$material_billable_p','','',9,'');

