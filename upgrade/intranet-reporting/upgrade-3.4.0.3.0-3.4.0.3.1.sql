-- upgrade-3.4.0.3.0-3.4.0.3.1.sql

SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-3.4.0.3.0-3.4.0.3.1.sql','');



-- add a "?" at the end of the productivity report to avoid a bad URL error
update im_menus
set url = '/intranet-reporting/timesheet-productivity?'
where url = '/intranet-reporting/timesheet-productivity';


create or replace function im_report__new (
	integer, varchar, timestamptz, integer, varchar, integer,
	varchar, varchar, integer, integer, integer, text
) returns integer as '
DECLARE
	p_report_id		alias for $1;		-- report_id  default null
	p_object_type   	alias for $2;		-- object_type default ''im_report''
	p_creation_date 	alias for $3;		-- creation_date default now()
	p_creation_user 	alias for $4;		-- creation_user default null
	p_creation_ip   	alias for $5;		-- creation_ip default null
	p_context_id		alias for $6;		-- context_id default null

	p_report_name		alias for $7;		-- report_name
	p_report_code		alias for $8;
	p_report_type_id	alias for $9;		
	p_report_status_id	alias for $10;
	p_report_menu_id	alias for $11;
	p_report_sql		alias for $12;

	v_report_id		integer;
	v_count			integer;
BEGIN
	select count(*) into v_count from im_reports
	where report_name = p_report_name;
	if v_count > 0 then return 0; end if;

	v_report_id := acs_object__new (
		p_report_id,		-- object_id
		p_object_type,		-- object_type
		p_creation_date,	-- creation_date
		p_creation_user,	-- creation_user
		p_creation_ip,		-- creation_ip
		p_context_id,		-- context_id
		''t''			-- security_inherit_p
	);

	insert into im_reports (
		report_id, report_name, report_code,
		report_type_id, report_status_id,
		report_menu_id, report_sql
	) values (
		v_report_id, p_report_name, p_report_code,
		p_report_type_id, p_report_status_id,
		p_report_menu_id, p_report_sql
	);

	return v_report_id;
END;' language 'plpgsql';
 
