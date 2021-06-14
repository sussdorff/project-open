-- upgrade-3.3.1.2.0-3.3.1.2.1.sql

SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-3.3.1.2.0-3.3.1.2.1.sql','');


create or replace function inline_0 ()
returns integer as '
declare
	v_count			integer;
begin
	select  count(*) into v_count from user_tab_columns
	where   lower(table_name) = ''im_reports'' and lower(column_name) = ''report_code'';
	IF v_count > 0 THEN return 0; END IF;
	
	alter table im_reports add report_code varchar(100);
	
    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0();


create or replace function inline_0 ()
returns integer as '
declare
	v_count			integer;
begin
	select  count(*) into v_count from user_tab_columns
	where   lower(table_name) = ''im_reports'' and lower(column_name) = ''report_sort_order'';
	IF v_count > 0 THEN return 0; END IF;
	
	alter table im_reports add report_sort_order integer;
	
    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0();


create or replace function inline_0 ()
returns integer as '
declare
	v_count			integer;
begin
	select  count(*) into v_count from user_tab_columns
	where   lower(table_name) = ''im_reports'' and lower(column_name) = ''report_description'';
	IF v_count > 0 THEN return 0; END IF;
	
	alter table im_reports add report_description text;
	
    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0();




-----------------------------------------------------------
-- Privileges

create or replace function inline_0 ()
returns integer as '
declare
	v_count		 integer;
begin
	select count(*) into v_count
	from acs_privileges where privilege = ''add_reports'';
	if v_count > 0 then return 0; end if;

	PERFORM acs_privilege__create_privilege(''add_reports'',''Add Reports'',''Add Reports'');
	PERFORM acs_privilege__add_child(''admin'', ''add_reports'');

	PERFORM acs_privilege__create_privilege(''view_reports_all'',''View Reports All'',''View Reports All'');
	PERFORM acs_privilege__add_child(''admin'', ''view_reports_all'');

	PERFORM im_priv_create(''add_reports'', ''Accounting'');
	PERFORM im_priv_create(''add_reports'', ''P/O Admins'');
	PERFORM im_priv_create(''add_reports'', ''Senior Managers'');

	PERFORM im_priv_create(''view_reports_all'', ''Accounting'');
	PERFORM im_priv_create(''view_reports_all'', ''P/O Admins'');
	PERFORM im_priv_create(''view_reports_all'', ''Senior Managers'');

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

