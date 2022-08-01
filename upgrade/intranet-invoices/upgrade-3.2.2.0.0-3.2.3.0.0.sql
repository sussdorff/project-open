-- upgrade-3.2.2.0.0-3.2.3.0.0.sql

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-3.2.2.0.0-3.2.3.0.0.sql','');



-- Add a "CostCenter" column to the main Inovice list
delete from im_view_columns where column_id=3002;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (3002,30,NULL,'CC',
'$cost_center_code','','',2,'');


-- Dont show status_select for an invoice if the user cant read it.
delete from im_view_columns where column_id = 3017;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (3017,30,NULL,'Status',
'$status_select','','',17,'');


-- Setup new Menu links for PO and Delivery Note from scratch
-- and DelNote from Quote
--
create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_invoices_providers	integer;
	v_invoices_customers	integer;

	-- Groups
	v_employees		integer;
	v_accounting		integer;
	v_senman		integer;
	v_customers		integer;
	v_freelancers		integer;
	v_proman		integer;
	v_admins		integer;

	v_count			integer;
begin

    select group_id into v_admins from groups where group_name = ''P/O Admins'';
    select group_id into v_senman from groups where group_name = ''Senior Managers'';
    select group_id into v_proman from groups where group_name = ''Project Managers'';
    select group_id into v_accounting from groups where group_name = ''Accounting'';
    select group_id into v_employees from groups where group_name = ''Employees'';
    select group_id into v_customers from groups where group_name = ''Customers'';
    select group_id into v_freelancers from groups where group_name = ''Freelancers'';

    select menu_id into v_invoices_customers from im_menus
    where label=''invoices_customers'';

    select menu_id into v_invoices_providers from im_menus
    where label=''invoices_providers'';

    select count(*) into v_count from im_menus 
    where label = ''invoices_providers_new_po'';

    IF v_count = 0 THEN
	    v_menu := im_menu__new (
		null,						-- menu_id
		''im_menu'',					-- object_type
		now(),						-- creation_date
		null,						-- creation_user
		null,						-- creation_ip
		null,						-- context_id
		''intranet-invoices'',				-- package_name
		''invoices_providers_new_po'',			-- label
		''New Purchase Order from scratch'',		-- name
		''/intranet-invoices/new?cost_type_id=3706'',	-- url
		40,						-- sort_order
		v_invoices_providers,				-- parent_menu_id
		null						-- visible_tcl
	    );
	    PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
	    PERFORM acs_permission__grant_permission(v_menu, v_senman, ''read'');
	    PERFORM acs_permission__grant_permission(v_menu, v_accounting, ''read'');
    END IF;

    select count(*) into v_count from im_menus 
    where label = ''invoices_providers_new_delnote'';

    IF v_count = 0 THEN
	    v_menu := im_menu__new (
		null,			   -- menu_id
		''im_menu'',		 -- object_type
		now(),			  -- creation_date
		null,			   -- creation_user
		null,			   -- creation_ip
		null,			   -- context_id
		''intranet-invoices'',		-- package_name
		''invoices_providers_new_delnote'',	-- label
		''New Delivery Note from scratch'',	-- name
		''/intranet-invoices/new?cost_type_id=3724'',	-- url
		30,						-- sort_order
		v_invoices_customers,				-- parent_menu_id
		null						-- visible_tcl
	    );
	    PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
	    PERFORM acs_permission__grant_permission(v_menu, v_senman, ''read'');
	    PERFORM acs_permission__grant_permission(v_menu, v_accounting, ''read'');
    END IF;

    select count(*) into v_count from im_menus 
    where label = ''invoices_customers_new_delnote_from_quote'';

    IF v_count = 0 THEN
	    v_menu := im_menu__new (
		null,			   -- menu_id
		''im_menu'',		 -- object_type
		now(),			  -- creation_date
		null,			   -- creation_user
		null,			   -- creation_ip
		null,			   -- context_id
		''intranet-invoices'',		-- package_name
		''invoices_customers_new_delnote_from_quote'',	-- label
		''New Delivery Note from Quote'',		-- name
		''/intranet-invoices/new-copy?target_cost_type_id=3724\&source_cost_type_id=3702'',
		20,				-- sort_order
		v_invoices_customers,		-- parent_menu_id
		null				-- visible_tcl
	    );
	    PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
	    PERFORM acs_permission__grant_permission(v_menu, v_senman, ''read'');
	    PERFORM acs_permission__grant_permission(v_menu, v_accounting, ''read'');
    END IF;

    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




-- Setup new Menu links for PO and Delivery Note from scratch
-- and DelNote from Quote
--
create or replace function inline_0 ()
returns integer as '
declare
	v_menu			integer;
	v_invoices_customers	integer;
	v_accounting		integer;
	v_senman		integer;
	v_admins		integer;
	v_count			integer;
begin
    select group_id into v_admins from groups where group_name = ''P/O Admins'';
    select group_id into v_senman from groups where group_name = ''Senior Managers'';
    select group_id into v_accounting from groups where group_name = ''Accounting'';

    select menu_id into v_invoices_customers from im_menus where label=''invoices_customers'';
    select count(*) into v_count from im_menus 
    where label = ''invoices_customers_new_invoice_from_delnote'';
    IF v_count = 0 THEN
	    v_menu := im_menu__new (
		null,			   -- menu_id
		''im_menu'',		 -- object_type
		now(),			  -- creation_date
		null,			   -- creation_user
		null,			   -- creation_ip
		null,			   -- context_id
		''intranet-invoices'',		-- package_name
		''invoices_customers_new_invoice_from_delnote'',	-- label
		''New Customer Invoice from Delivery Note'',	-- name
		''/intranet-invoices/new-copy?target_cost_type_id=3700\&source_cost_type_id=3724'',
		325,						-- sort_order
		v_invoices_customers,				-- parent_menu_id
		null						-- visible_tcl
	    );
	    PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
	    PERFORM acs_permission__grant_permission(v_menu, v_senman, ''read'');
	    PERFORM acs_permission__grant_permission(v_menu, v_accounting, ''read'');
    END IF;
    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




-- ------------------------------------------------
-- Update all FinancialDocuments to set the "project_id" field
-- IF there is exactly one project associated
create or replace function inline_0 ()
returns integer as '
DECLARE
    row			 RECORD;
    v_project_id		integer;
BEGIN
    FOR row IN
	select  c.cost_id, c.project_id, t.cnt
	from    im_costs c
		LEFT OUTER JOIN (
			 select  c.cost_id,
				 count(*) as cnt
			 from    im_costs c,
				 im_projects p,
				 acs_rels r
			 where   r.object_id_one = p.project_id
				 and r.object_id_two = c.cost_id
			 group by c.cost_id
		) t ON (c.cost_id = t.cost_id)
	where	c.project_id is null
		and t.cnt = 1
    LOOP
	-- There is exactly one project to which the cost item is associated.
	select	max(p.project_id)
	into	v_project_id
	from	im_projects p,
		acs_rels r
	where	p.project_id = r.object_id_one
		and r.object_id_two = row.cost_id;
	RAISE NOTICE ''inline_0: cost_id=%-> pid=%'', row.cost_id, v_project_id;
	update im_costs
	set project_id = v_project_id
	where cost_id = row.cost_id;
    END LOOP;
    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0();







-----------------------------------------------------------------
-- VAW changes
-----------------------------------------------------------------

-- Set unit precesision to 3 digits
-- alter table im_invoice_items alter column item_units type numeric(12,3);




-- Setup the "Invoices New" admin menu for Company Documents
--
create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu		  integer;
	v_invoices_new_menu	 integer;
	v_finance_menu	  integer;

	-- Groups
	v_employees		 integer;
	v_accounting		integer;
	v_senman		integer;
	v_customers		 integer;
	v_freelancers	   integer;
	v_proman		integer;
	v_admins		integer;

	v_count			integer;
begin
    select group_id into v_admins from groups where group_name = ''P/O Admins'';
    select group_id into v_senman from groups where group_name = ''Senior Managers'';
    select group_id into v_accounting from groups where group_name = ''Accounting'';
    select group_id into v_customers from groups where group_name = ''Customers'';
    select group_id into v_freelancers from groups where group_name = ''Freelancers'';

    select menu_id
    into v_invoices_new_menu
    from im_menus
    where label=''invoices_providers'';

    select count(*) into v_count from im_menus 
    where label = ''invoices_providers_new_po'';

    IF v_count = 0 THEN
	    v_finance_menu := im_menu__new (
		null,					-- menu_id
		''im_menu'',				-- object_type
		now(),					-- creation_date
		null,					-- creation_user
		null,					-- creation_ip
		null,					-- context_id
		''intranet-invoices'',			-- package_name
		''invoices_providers_new_po'',  	-- label
		''New Purchase Order from scratch'',	-- name
		''/intranet-invoices/new?cost_type_id=3706'', -- url
		30,					-- sort_order
		v_invoices_new_menu,			-- parent_menu_id
		null					-- visible_tcl
	    );
	
	    PERFORM acs_permission__grant_permission(v_finance_menu, v_admins, ''read'');
	    PERFORM acs_permission__grant_permission(v_finance_menu, v_senman, ''read'');
	    PERFORM acs_permission__grant_permission(v_finance_menu, v_accounting, ''read'');
	    PERFORM acs_permission__grant_permission(v_finance_menu, v_customers, ''read'');
	    PERFORM acs_permission__grant_permission(v_finance_menu, v_freelancers, ''read'');
    END IF;

    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



-- -------------------------------------------------------------
-- Add a "category_invoice_template" widget to DynField Widgets
-- if not there already.
-- The new widget shows a list of templates.


create or replace function inline_0 ()
returns integer as '
declare
	v_count			integer;
begin
	select count(*)
	into v_count
	from im_dynfield_widgets
	where widget_name = ''category_invoice_template'';

	IF v_count = 0 THEN

		PERFORM im_dynfield_widget__new (
			null, ''im_dynfield_widget'', now()::date,
			null, null, null,
			''category_invoice_template'', ''Invoice Template'', ''Invoice Template'',
			10007, ''integer'', ''im_category_tree'', ''integer'',
			''{custom {category_type "Intranet Cost Template"}}''
		);
	END IF;

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();





-- -------------------------------------------------------------
-- Add field default_quote_template_id to im_companies
--
-- Add new attributes to im_companies for default templates


create or replace function inline_0 ()
returns integer as '
declare
	v_attrib_name		varchar;
	v_attrib_pretty		varchar;
	v_acs_attrib_id		integer;
	v_attrib_id		integer;
	v_count			integer;
begin
	v_attrib_name := ''default_bill_template_id'';
	v_attrib_pretty := ''Default Provider Bill Template'';

	select count(*)	into v_count
	from acs_attributes
	where attribute_name = v_attrib_name;
	IF 0 != v_count THEN return 0; END IF;

	v_acs_attrib_id := acs_attribute__create_attribute (
		''im_company'',
		v_attrib_name,
		''integer'',
		v_attrib_pretty,
		v_attrib_pretty,
		''im_companies'',
		NULL, NULL, ''0'', ''1'',
		NULL, NULL, NULL
	);
	alter table im_companies add default_bill_template_id integer;
	v_attrib_id := acs_object__new (
		null,
		''im_dynfield_attribute'',
		now(),
		null, null, null
	);
	insert into im_dynfield_attributes (
		attribute_id, acs_attribute_id, widget_name, deprecated_p
	) values (
		v_attrib_id, v_acs_attrib_id, ''category_invoice_template'', ''f''
	);
    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();






create or replace function inline_0 ()
returns integer as '
declare
	v_attrib_name		varchar;
	v_attrib_pretty		varchar;
	v_acs_attrib_id		integer;
	v_attrib_id		integer;
	v_count			integer;
begin
	v_attrib_name := ''default_po_template_id'';
	v_attrib_pretty := ''Default PO Template'';

	select count(*)	into v_count
	from acs_attributes
	where attribute_name = v_attrib_name;
	IF 0 != v_count THEN return 0; END IF;

	v_acs_attrib_id := acs_attribute__create_attribute (
		''im_company'',
		v_attrib_name,
		''integer'',
		v_attrib_pretty,
		v_attrib_pretty,
		''im_companies'',
		NULL, NULL,
		''0'', ''1'',
		NULL, NULL,
		NULL
	);

	alter table im_companies add default_po_template_id integer;

	v_attrib_id := acs_object__new (
		null,
		''im_dynfield_attribute'',
		now(),
		null,
		null, 
		null
	);

	insert into im_dynfield_attributes (
		attribute_id, acs_attribute_id, widget_name, deprecated_p
	) values (
		v_attrib_id, v_acs_attrib_id, ''category_invoice_template'', ''f''
	);

    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();





create or replace function inline_0 ()
returns integer as '
declare
	v_attrib_name		varchar;
	v_attrib_pretty		varchar;
	v_acs_attrib_id		integer;
	v_attrib_id		integer;
	v_count			integer;
begin
	v_attrib_name := ''default_delnote_template_id'';
	v_attrib_pretty := ''Default Delivery Note Template'';

	select count(*)	into v_count
	from acs_attributes
	where attribute_name = v_attrib_name;
	IF 0 != v_count THEN return 0; END IF;

	v_acs_attrib_id := acs_attribute__create_attribute (
		''im_company'',
		v_attrib_name,
		''integer'',
		v_attrib_pretty,
		v_attrib_pretty,
		''im_companies'',
		NULL, NULL,
		''0'', ''1'',
		NULL, NULL,
		NULL
	);

	alter table im_companies add default_delnote_template_id integer;

	v_attrib_id := acs_object__new (
		null,
		''im_dynfield_attribute'',
		now(),
		null,
		null, 
		null
	);

	insert into im_dynfield_attributes (
		attribute_id, acs_attribute_id, widget_name, deprecated_p
	) values (
		v_attrib_id, v_acs_attrib_id, ''category_invoice_template'', ''f''
	);

    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




