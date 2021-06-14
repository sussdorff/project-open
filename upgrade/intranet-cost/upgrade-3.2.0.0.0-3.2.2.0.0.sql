-- /packages/intranet-cost/sql/postgres/upgrade/upgrade-3.2.0.0.0-3.2.2.0.0.sql
--
-- ]project-open[ Cost Core
-- 040207 frank.bergmann@project-open.com
--
-- Copyright (C) 2006 - 2009 ]project-open[
--
-- All rights including reserved. To inquire license terms please 
-- refer to http://www.project-open.com/modules/<module-key>

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-3.2.0.0.0-3.2.2.0.0.sql','');


-- Source new __new duplicate tollerant scripts
\i ../../../../intranet-core/sql/postgresql/upgrade/upgrade-3.0.0.0.first.sql



-- Add cache fields for Delivery Notes
create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select  count(*) into v_count from user_tab_columns
	where   lower(table_name) = ''im_projects''
		and lower(column_name) = ''cost_delivery_notes_cache'';
	if v_count = 1 then return 0; end if;

	alter table im_projects add cost_delivery_notes_cache numeric(12,2);
	alter table im_projects alter cost_delivery_notes_cache set default 0;

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



-- Remove old "Travel Costs" cost type
delete from im_categories where category_id = 3712;


-- Add a new category "Delivery Note" if not already there...
SELECT im_category_new(3724, 'Delivery Note', 'Intranet Cost Type');

-- Establish that a Delivery Note is a "Customer Documents"
SELECT im_category_hierarchy_new (3724, 3708);


-------------------------------------------------------------
-- 
-------------------------------------------------------------

create or replace function im_cost_center_code_from_id (integer)
returns varchar as '
DECLARE
	p_id	alias for $1;
	v_name  varchar(400);
BEGIN
	select  cc.cost_center_code into v_name from im_cost_centers cc
	where   cost_center_id = p_id;

	return v_name;
end;' language 'plpgsql';


-------------------------------------------------------------
-- Menus
-- Create a Cost Centers menu in Admin
---------------------------------------------------------


create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu		integer;
	v_admin_menu	integer;

	-- Groups
	v_accounting	integer;
	v_senman	integer;
	v_admins	integer;

	v_count		integer;
BEGIN
	select  count(*) into v_count from im_menus
	where   label = ''admin_cost_centers'';
	if v_count = 1 then return 0; end if;

	select group_id into v_admins from groups where group_name = ''P/O Admins'';
	select group_id into v_senman from groups where group_name = ''Senior Managers'';
	select group_id into v_accounting from groups where group_name = ''Accounting'';

	select menu_id into v_admin_menu from im_menus where label=''admin'';

	v_menu := im_menu__new (
		null,			-- p_menu_id
		''im_menu'',		-- object_type
		now(),			-- creation_date
		null,			-- creation_user
		null,			-- creation_ip
		null,			-- context_id
		''intranet-cost'',  -- package_name
		''admin_cost_centers'',	-- label
		''Cost Centers'',	-- name
		''/intranet-cost/cost-centers/index'',   -- url
		85,			-- sort_order
		v_admin_menu,		-- parent_menu_id
		null			-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
	PERFORM acs_permission__grant_permission(v_menu, v_senman, ''read'');
	PERFORM acs_permission__grant_permission(v_menu, v_accounting, ''read'');

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



-------------------------------------------------------------
-- Cost Center Permissions for Financial Documents
-------------------------------------------------------------

-- Permissions and Privileges
--

-- All privilege - We cannot directly inherit from "read" or "write",
-- because all registered_users have read access to the "SubSite".
--

create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select  count(*) into v_count from acs_privileges
	where   privilege = ''fi_read_all'';
	if v_count = 1 then return 0; end if;

	PERFORM acs_privilege__create_privilege(''fi_read_all'',''Read All'',''Read All'');
	PERFORM acs_privilege__create_privilege(''fi_write_all'',''Write All'',''Write All'');
	PERFORM acs_privilege__add_child(''admin'', ''fi_read_all'');
	PERFORM acs_privilege__add_child(''admin'', ''fi_write_all'');
	
	-- Start defining the cost_type specific privileges
	--
	PERFORM acs_privilege__create_privilege(''fi_read_invoices'',''Read Invoices'',''Read Invoices'');
	PERFORM acs_privilege__create_privilege(''fi_write_invoices'',''Write Invoices'',''Write Invoices'');
	PERFORM acs_privilege__add_child(''fi_read_all'', ''fi_read_invoices'');
	PERFORM acs_privilege__add_child(''fi_write_all'', ''fi_write_invoices'');
	
	PERFORM acs_privilege__create_privilege(''fi_read_quotes'',''Read Quotes'',''Read Quotes'');
	PERFORM acs_privilege__create_privilege(''fi_write_quotes'',''Write Quotes'',''Write Quotes'');
	PERFORM acs_privilege__add_child(''fi_read_all'', ''fi_read_quotes'');
	PERFORM acs_privilege__add_child(''fi_write_all'', ''fi_write_quotes'');
	
	PERFORM acs_privilege__create_privilege(''fi_read_bills'',''Read Bills'',''Read Bills'');
	PERFORM acs_privilege__create_privilege(''fi_write_bills'',''Write Bills'',''Write Bills'');
	PERFORM acs_privilege__add_child(''fi_read_all'', ''fi_read_bills'');
	PERFORM acs_privilege__add_child(''fi_write_all'', ''fi_write_bills'');
	
	PERFORM acs_privilege__create_privilege(''fi_read_pos'',''Read Pos'',''Read Pos'');
	PERFORM acs_privilege__create_privilege(''fi_write_pos'',''Write Pos'',''Write Pos'');
	PERFORM acs_privilege__add_child(''fi_read_all'', ''fi_read_pos'');
	PERFORM acs_privilege__add_child(''fi_write_all'', ''fi_write_pos'');
	
	PERFORM acs_privilege__create_privilege(''fi_read_timesheets'',''Read Timesheets'',''Read Timesheets'');
	PERFORM acs_privilege__create_privilege(''fi_write_timesheets'',''Write Timesheets'',''Write Timesheets'');
	PERFORM acs_privilege__add_child(''fi_read_all'', ''fi_read_timesheets'');
	PERFORM acs_privilege__add_child(''fi_write_all'', ''fi_write_timesheets'');
	
	PERFORM acs_privilege__create_privilege(''fi_read_delivery_notes'',''Read Delivery Notes'',''Read Delivery Notes'');
	PERFORM acs_privilege__create_privilege(''fi_write_delivery_notes'',''Write Delivery Notes'',''Write Delivery Notes'');
	PERFORM acs_privilege__add_child(''fi_read_all'', ''fi_read_delivery_notes'');
	PERFORM acs_privilege__add_child(''fi_write_all'', ''fi_write_delivery_notes'');
	
	PERFORM acs_privilege__create_privilege(''fi_read_expense_items'',''Read Expense Items'',''Read Expense Items'');
	PERFORM acs_privilege__create_privilege(''fi_write_expense_items'',''Write Expense Items'',''Write Expense Items'');
	PERFORM acs_privilege__add_child(''fi_read_all'', ''fi_read_expense_items'');
	PERFORM acs_privilege__add_child(''fi_write_all'', ''fi_write_expense_items'');
	
	PERFORM acs_privilege__create_privilege(''fi_read_expense_bundles'',''Read Expense Reports'',''Read Expense Reports'');
	PERFORM acs_privilege__create_privilege(''fi_write_expense_bundles'',''Write Expense Reports'',''Write Expense Reports'');
	PERFORM acs_privilege__add_child(''fi_read_all'', ''fi_read_expense_bundles'');
	PERFORM acs_privilege__add_child(''fi_write_all'', ''fi_write_expense_bundles'');
	
	PERFORM acs_privilege__create_privilege(''fi_read_repeatings'',''Read Repeatings'',''Read Repeatings'');
	PERFORM acs_privilege__create_privilege(''fi_write_repeatings'',''Write Repeatings'',''Write Repeatings'');
	PERFORM acs_privilege__add_child(''fi_read_all'', ''fi_read_repeatings'');
	PERFORM acs_privilege__add_child(''fi_write_all'', ''fi_write_repeatings'');

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




select im_priv_create('fi_read_all','P/O Admins');
select im_priv_create('fi_read_all','Senior Managers');
select im_priv_create('fi_read_all','Accounting');
select im_priv_create('fi_write_all','P/O Admins');
select im_priv_create('fi_write_all','Senior Managers');
select im_priv_create('fi_write_all','Accounting');




-------------------------------------------------------------
-- Update the context_id field of the "Co - The Company"
-- so that permissions are inherited from SubSite
--
create or replace function inline_0 ()
returns integer as '
DECLARE
	v_subsite_id		integer;
BEGIN
	-- Get the Main Site id, used as the global identified for permissions
	select package_id into v_subsite_id
	from apm_packages where package_key=''acs-subsite'';

	update acs_objects
		set context_id = v_subsite_id
	where
		object_id in (
			select	cost_center_id
			from	im_cost_centers
		) and
		context_id is null;

	return 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();


-------------------------------------------------------------
-- Update all im_costs with empty cost_center_id
-- to set them to 'company'
--
update im_costs
set cost_center_id = (
	select cost_center_id
	from im_cost_centers
	where cost_center_label = 'company'
)
where cost_center_id is null;



-- Add a Project Manager field to Profit & Loss Analysis
delete from im_view_columns where column_id = 2109;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (2109,21,NULL,'Project Manager',
'"<A HREF=/intranet/users/view?user_id=$project_lead_id>$lead_name</A>"',
'','',9,'');



-- Fix Profit & Loss report to show columns only if Company-CC is readable 
update	im_view_columns set 
	visible_for = 'expr [im_permission $user_id view_finance] && [im_cc_read_p]'
where	view_id = 21
	and visible_for = 'im_permission $user_id view_finance'
;

update im_view_columns set
	visible_for = 'im_permission $user_id view_budget'
where	column_id = 2111;

update im_view_columns set
	visible_for = 'im_permission $user_id view_budget_hours'
where	column_id = 2113
;





-------------------------------------------------------------
-- Update the context_id fields of the cost centers, 
-- so that permissions are inherited
--
create or replace function inline_0 ()
returns integer as '
DECLARE
	row			RECORD;
BEGIN
	FOR row IN
		select  *
		from	im_cost_centers
	LOOP
		if row.cost_center_id != row.parent_id then
			RAISE NOTICE ''inline_0: cc_id=%'', row.cost_center_id;
			update acs_objects
			set context_id = row.parent_id
			where object_id = row.cost_center_id;
		end if;

	END LOOP;
	return 0;

END;' language 'plpgsql';
select inline_0 ();
drop function inline_0();




