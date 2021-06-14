-- upgrade-3.4.0.7.0-3.4.0.7.1.sql

SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-3.4.0.7.0-3.4.0.7.1.sql','');




create or replace function im_report_new (
	varchar, varchar, varchar, integer, integer, varchar
) returns integer as '
DECLARE
	p_report_name		alias for $1;
	p_report_code		alias for $2;
	p_package_name		alias for $3;
	p_report_sort_order	alias for $4;
	p_parent_menu_id	alias for $5;
	p_report_sql		alias for $6;

	v_menu_id		integer;
	v_report_id		integer;
	v_report_url		varchar;
	v_count			integer;
BEGIN
	select count(*) into v_count from im_reports
	where report_name = p_report_name;
	if v_count > 0 then 
		return (select report_id from im_reports where report_name = p_report_name); 
	end if;

	-- default URL. Later we need to update it.
	v_report_url := '''';

	v_menu_id := im_menu__new (
		null,			-- p_menu_id
		''im_menu'',		-- object_type
		now()::timestamptz,	-- creation_date
		null,			-- creation_user
		''0.0.0.0'',		-- creation_ip
		null,			-- context_id

		p_package_name,		-- package_name
		p_report_code,		-- label
		p_report_name,		-- name
		v_report_url,		-- url
		p_report_sort_order,	-- sort_order
		p_parent_menu_id,	-- parent_menu_id
		null			-- p_visible_tcl
	);

	v_report_id := im_report__new (
		null,			-- report_id
		''im_report'',		-- object_type
		now(),			-- creation_date
		null,			-- creation_user
		''0.0.0.0'',		-- creation_ip
		null,			-- context_id
	
		p_report_name,		-- report_name
		p_report_code,		-- report_code		
		15100,			-- p_report_type_id	
		15000,			-- report_status_id	
		v_menu_id,		-- report_menu_id	
		p_report_sql		-- report_sql
	);

	-- Update the final URL
	update im_menus set
		url = ''/intranet-reporting/view?report_id='' || v_report_id
	where menu_id = v_menu_id;

	return v_report_id;
END;' language 'plpgsql';
