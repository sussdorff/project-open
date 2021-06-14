-- upgrade-3.2.9.0.0-3.3.0.0.0.sql

SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-3.2.9.0.0-3.3.0.0.0.sql','');

-----------------------------------------------------------
-- Reports
--
-- Table for user-defined reports. Types:
--	- SQL Report - Simply show the result of an SQL statement via im_ad_hoc_query
--	- ... (more types of reports possibly in the future).
--
create or replace function inline_0 ()
returns integer as '
declare
	v_count			integer;
	v_menu_id		integer;
begin
	select  count(*) into v_count from acs_object_types
	where   object_type = ''im_report'';
	IF v_count > 0 THEN return 0; END IF;
	
	PERFORM acs_object_type__create_type (
		''im_report'',			-- object_type
		''Report'',			-- pretty_name
		''Reports'',			-- pretty_plural
		''acs_object'',			-- supertype
		''im_reports'',			-- table_name
		''report_id'',			-- id_column
		''intranet-reporting'',		-- package_name
		''f'',				-- abstract_p
		null,				-- type_extension_table
		''im_report__name''		-- name_method
	);
	

	create table im_reports (
		report_id		integer
					constraint im_report_id_pk
					primary key
					constraint im_report_id_fk
					references acs_objects,
		report_name		varchar(1000),
		report_status_id	integer 
					constraint im_report_status_nn
					not null
					constraint im_report_status_fk
					references im_categories,
		report_type_id		integer 
					constraint im_report_type_nn
					not null
					constraint im_report_type_fk
					references im_categories,
		report_sort_order	integer,
		report_menu_id		integer
					constraint im_report_menu_id_fk
					references im_menus,
		report_sql		text
					constraint im_report_report_nn
					not null,
		report_description	text
	);
	
	alter table im_reports add
		constraint im_reports_name_un
		unique(report_name);
	
    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0();



-----------------------------------------------------------
-- Create, Drop and Name Plpg/SQL functions
--
-- These functions represent crator/destructor
-- functions for the OpenACS object system.


create or replace function im_report__name(integer)
returns varchar as '
DECLARE
	p_report_id		alias for $1;
	v_name			varchar(2000);
BEGIN
	select	report_name into v_name from im_reports
	where	report_id = p_report_id;
	return v_name;
end;' language 'plpgsql';


create or replace function im_report__new (
	integer, varchar, timestamptz, integer, varchar, integer,
	varchar, integer, integer, integer, text
) returns integer as '
DECLARE
	p_report_id		alias for $1;		-- report_id  default null
	p_object_type   	alias for $2;		-- object_type default ''im_report''
	p_creation_date 	alias for $3;		-- creation_date default now()
	p_creation_user 	alias for $4;		-- creation_user default null
	p_creation_ip   	alias for $5;		-- creation_ip default null
	p_context_id		alias for $6;		-- context_id default null

	p_report_name		alias for $7;		-- report_name
	p_report_type_id	alias for $8;		
	p_report_status_id	alias for $9;
	p_report_menu_id	alias for $10;
	p_report_sql		alias for $11;

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
		report_id, report_name,
		report_type_id, report_status_id,
		report_menu_id, report_sql
	) values (
		v_report_id, p_report_name,
		p_report_type_id, p_report_status_id,
		p_report_menu_id, p_report_sql
	);

	return v_report_id;
END;' language 'plpgsql';


create or replace function im_report__delete(integer)
returns integer as '
DECLARE
	p_report_id	alias for $1;
BEGIN
	-- Delete any data related to the object
	delete from im_reports
	where	report_id = p_report_id;

	-- Finally delete the object iself
	PERFORM acs_object__delete(p_report_id);

	return 0;
end;' language 'plpgsql';




-----------------------------------------------------------
-- Type and Status
--
-- Create categories for Reports type and status.
-- Status acutally is not use, so we just define "active"

-- Here are the ranges for the constants as defined in
-- /intranet-core/sql/common/intranet-categories.sql
--
-- Please contact support@project-open.com if you need to
-- reserve a range of constants for a new module.
--
-- 15000-15099  Intranet Report Status
-- 15100-15199  Intranet Report Type
-- 15200-15999	Reserved for Reporting


SELECT im_category_new(15000, 'Active', 'Intranet Report Status');
SELECT im_category_new(15002, 'Deleted', 'Intranet Report Status');

SELECT im_category_new(15100, 'Simple SQL Report', 'Intranet Report Type');
SELECT im_category_new(15110, 'Indicator', 'Intranet Report Type');


-----------------------------------------------------------
-- Create views for shortcut
--

create or replace view im_report_status as
select	category_id as report_status_id, category as report_status
from	im_categories
where	category_type = 'Intranet Report Status'
	and (enabled_p is null or enabled_p = 't');

create or replace view im_report_types as
select	category_id as report_type_id, category as report_type
from	im_categories
where	category_type = 'Intranet Report Type'
	and (enabled_p is null or enabled_p = 't');


------------------------------------------------------------------------------
--
------------------------------------------------------------------------------



create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_main_menu		integer;

	-- Groups
	v_employees		integer;
	v_accounting		integer;
	v_senman		integer;
	v_customers		integer;
	v_freelancers		integer;
	v_proman		integer;
	v_admins		integer;
	v_reg_users		integer;
BEGIN
	select group_id into v_admins from groups where group_name = ''P/O Admins'';
	select group_id into v_senman from groups where group_name = ''Senior Managers'';
	select group_id into v_proman from groups where group_name = ''Project Managers'';
	select group_id into v_accounting from groups where group_name = ''Accounting'';
	select group_id into v_employees from groups where group_name = ''Employees'';
	select group_id into v_customers from groups where group_name = ''Customers'';
	select group_id into v_freelancers from groups where group_name = ''Freelancers'';
	select group_id into v_reg_users from groups where group_name = ''Registered Users'';

	select menu_id into v_main_menu from im_menus
	where label=''reporting-timesheet'';

	v_menu := im_menu__new (
		null,					-- p_menu_id
		''im_menu'',				-- object_type
		now(),					-- creation_date
		null,					-- creation_user
		null,					-- creation_ip
		null,					-- context_id
		''intranet-reporting'',			-- package_name
		''reporting-timesheet-finance'',	-- label
		''Timesheet Project Hierarchy & Finance'', -- name
		''/intranet-reporting/timesheet-finance?'', -- url
		5,					-- sort_order
		v_main_menu,				-- parent_menu_id
		null					-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
	PERFORM acs_permission__grant_permission(v_menu, v_senman, ''read'');
	PERFORM acs_permission__grant_permission(v_menu, v_accounting, ''read'');

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

