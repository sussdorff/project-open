-- upgrade-3.4.0.6.0-3.4.0.6.1.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.6.0-3.4.0.6.1.sql','');


update im_menus set
	menu_gif_small = 'arrow_right'
where
	parent_menu_id in (
		select	menu_id
		from	im_menus
		where	label = 'admin'
	)
;



-------------------------------------------------------------------
-- Activate links for email and URL in the UserViewPage
--
delete from im_view_columns where view_id = 11;
--
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (1101,11,NULL,'Name','$name','','',1,
'im_view_user_permission $user_id $current_user_id $name view_users');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (1103,11,NULL,'Email',
'"<a href=mailto:$email>$email</a>"','','',2,
'im_view_user_permission $user_id $current_user_id $email view_users');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (1105,11,NULL,'Home',
'"<a href=$url>$url</a>"','','',3,
'im_view_user_permission $user_id $current_user_id $url view_users');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (1107,11,NULL,'Username',
'$username','','',4,
'parameter::get_from_package_key -package_key intranet-core -parameter EnableUsersUsernameP -default 0');



-- Get the object status for generic objects
-- This function relies on the information in the OpenACS SQL metadata
-- system, so that errors in the OO configuration will give errors here.
-- Basically, the acs_object_types table contains the name and the column
-- of the table that stores the "status_id" for the given object type.
-- We will pull out this information and then dynamically create a SQL
-- statement to extract this information.
---
CREATE OR REPLACE FUNCTION im_biz_object__get_status_id (integer)
RETURNS integer AS '
DECLARE
	p_object_id		alias for $1;

	v_object_type		varchar;
	v_supertype		varchar;

	v_status_table		varchar;
	v_status_column		varchar;
	v_status_table_id_col	varchar;

	v_query			varchar;
	row			RECORD;
	v_result_id		integer;
BEGIN
	-- Get information from SQL metadata system
	select	ot.object_type, ot.supertype, ot.status_type_table, ot.status_column
	into	v_object_type, v_supertype, v_status_table, v_status_column
	from	acs_objects o, acs_object_types ot
	where	o.object_id = p_object_id and o.object_type = ot.object_type;

	-- In the case that the information about should not be set up correctly:
	-- Check if the object has a supertype and update table and id_column if necessary
	WHILE v_status_table is null AND ''acs_object'' != v_supertype AND ''im_biz_object'' != v_supertype LOOP
		select	ot.supertype, ot.status_type_table, ot.id_column
		into	v_supertype, v_status_table, v_status_table_id_col
		from	acs_object_types ot
		where	ot.object_type = v_supertype;
	END LOOP;

	-- Get the id_column for the v_status_table (not the objects main table...)
	select	aott.id_column into v_status_table_id_col from acs_object_type_tables aott
	where	aott.object_type = v_object_type and aott.table_name = v_status_table;

	-- Avoid reporting an error. However, this may make it more difficult diagnosing errors.
	IF v_status_table is null OR v_status_table_id_col is null OR v_status_column is null THEN
		return 0;
	END IF;

	-- Funny way, but this is the only option to get a value from an EXECUTE in PG 8.0 and below.
	v_query := '' select '' || v_status_column || '' as result_id '' || '' from '' || v_status_table || 
		'' where '' || v_status_table_id_col || '' = '' || p_object_id;
	FOR row IN EXECUTE v_query
        LOOP
		v_result_id := row.result_id;
		EXIT;
	END LOOP;

	return v_result_id;
END;' language 'plpgsql';




create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_types
	where object_type = ''im_timesheet_task'';
	IF v_count = 0 THEN RETURN 1; END IF;
	
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_timesheet_task'' and table_name = ''im_projects'';
	IF v_count > 0 THEN RETURN 1; END IF;

	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_timesheet_task'', ''im_projects'', ''project_id'');

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_types
	where object_type = ''im_timesheet_conf_object'';
	IF v_count = 0 THEN RETURN 1; END IF;
	
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_timesheet_conf_object'' and table_name = ''im_timesheet_conf_objects'';
	IF v_count > 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_timesheet_conf_object'', ''im_timesheet_conf_objects'', ''conf_id'');

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_dynfield_attribute'' and table_name = ''im_dynfield_attributes'';
	IF v_count > 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_dynfield_attribute'', ''im_dynfield_attributes'', ''attribute_id'');
	
	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_forum_topic'' and table_name = ''im_forum_topics'';
	IF v_count > 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_forum_topic'', ''im_forum_topics'', ''topic_id'');

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_invoice'' and table_name = ''im_costs'';
	IF v_count > 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_invoice'', ''im_costs'', ''cost_id'');	

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_types
	where object_type = ''im_timesheet_invoice'';
	IF v_count = 0 THEN RETURN 1; END IF;
	
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_timesheet_invoice'' and table_name = ''im_invoices'';
	IF v_count > 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_timesheet_invoice'', ''im_invoices'', ''invoice_id'');

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_types
	where object_type = ''im_timesheet_invoice'';
	IF v_count = 0 THEN RETURN 1; END IF;
	
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_timesheet_invoice'' and table_name = ''im_costs'';
	IF v_count > 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_timesheet_invoice'', ''im_costs'', ''cost_id'');
	

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_trans_invoice'' and table_name = ''im_invoices'';
	IF v_count > 0 THEN RETURN 1; END IF;

	select count(*) into v_count from acs_object_types
	where object_type = ''im_trans_invoice'';
	IF v_count = 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_trans_invoice'', ''im_invoices'', ''invoice_id'');

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_trans_invoice'' and table_name = ''im_costs'';
	IF v_count > 0 THEN RETURN 1; END IF;
	
	select count(*) into v_count from acs_object_types
	where object_type = ''im_trans_invoice'';
	IF v_count = 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_trans_invoice'', ''im_costs'', ''cost_id'');
	

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_gantt_project'' and table_name = ''im_gantt_projects'';
	IF v_count > 0 THEN RETURN 1; END IF;
	
	-- make sure im_gantt_project object type exists...
	select count(*) into v_count from acs_object_types
	where object_type = ''im_gantt_project'';
	IF v_count = 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_gantt_project'', ''im_gantt_projects'', ''project_id'');

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_gantt_project'' and table_name = ''im_projects'';
	IF v_count > 0 THEN RETURN 1; END IF;

	-- make sure im_gantt_project object type exists...
	select count(*) into v_count from acs_object_types
	where object_type = ''im_gantt_project'';
	IF v_count = 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_gantt_project'', ''im_projects'', ''project_id'');

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



delete from im_biz_object_urls where object_type = 'im_gantt_project';
insert into im_biz_object_urls (object_type, url_type, url) values (
'im_gantt_project','view','/intranet/projects/view?project_id=');
insert into im_biz_object_urls (object_type, url_type, url) values (
'im_gantt_project','edit','/intranet/projects/new?project_id=');



create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_types
	where object_type = ''im_ticket'';
	IF v_count = 0 THEN RETURN 1; END IF;
	
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_ticket'' and table_name = ''im_projects'';
	IF v_count > 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_ticket'', ''im_projects'', ''project_id'');
	

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_types
	where object_type = ''im_indicator'';
	IF v_count = 0 THEN RETURN 1; END IF;
	
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_indicator'' and table_name = ''im_indicators'';
	IF v_count > 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_indicator'', ''im_indicators'', ''indicator_id'');

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_types
	where object_type = ''im_indicator'';
	IF v_count = 0 THEN RETURN 1; END IF;
	
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_indicator'' and table_name = ''im_reports'';
	IF v_count > 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_indicator'', ''im_reports'', ''report_id'');

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_cost_center'' and table_name = ''im_cost_centers'';
	IF v_count > 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_cost_center'', ''im_cost_centers'', ''cost_center_id'');
	

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_cost'' and table_name = ''im_costs'';
	IF v_count > 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_cost'', ''im_costs'', ''cost_id'');

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_repeating_cost'' and table_name = ''im_repeating_costs'';
	IF v_count > 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_repeating_cost'', ''im_repeating_costs'', ''rep_cost_id'');

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_cost'' and table_name = ''im_costs'';
	IF v_count > 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_cost'', ''im_costs'', ''cost_id'');
	

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_investment'' and table_name = ''im_investments'';
	IF v_count > 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_investment'', ''im_investments'', ''investment_id'');

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_investment'' and table_name = ''im_repeating_costs'';
	IF v_count > 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_investment'', ''im_repeating_costs'', ''rep_cost_id'');

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from acs_object_type_tables
	where object_type = ''im_investment'' and table_name = ''im_costs'';
	IF v_count > 0 THEN RETURN 1; END IF;
	
	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_investment'', ''im_costs'', ''cost_id'');
	
	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

