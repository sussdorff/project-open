-- upgrade-3.4.0.0.0-3.4.0.1.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.0.0-3.4.0.1.0.sql','');




-------------------------------------------------------------
-- Updated version of grant_permission that deals with the
-- case that the grantee doesnt exist.
-------------------------------------------------------------


create or replace function acs_permission__grant_permission (integer, integer, varchar)
returns integer as '
declare
	grant_permission__object_id		alias for $1;
	grant_permission__grantee_id		alias for $2;
	grant_permission__privilege		alias for $3;
	exists_p				boolean;
begin
	lock table acs_permissions_lock;

	select count(*) > 0 into exists_p from acs_permissions
	where object_id = grant_permission__object_id and 
		grantee_id = grant_permission__grantee_id and
		privilege = grant_permission__privilege;

	IF NULL != grant_permission__grantee_id AND not exists_p THEN
		insert into acs_permissions (
		       	object_id, grantee_id, privilege
		) values (
			grant_permission__object_id, 
			grant_permission__grantee_id, 
			grant_permission__privilege
		);
	END IF;

	return 0; 
end;' language 'plpgsql';



-------------------------------------------------------------
-- 
-------------------------------------------------------------



create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
        select count(*) into v_count from user_tab_columns
	where table_name = ''ACS_OBJECT_TYPES'' and column_name = ''TYPE_CATEGORY_TYPE'';
        if v_count > 0 then return 0; end if;

	alter table acs_object_types
	add type_category_type char varying(50);

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




update acs_object_types
set type_category_type = 'Intranet Company Type'
where object_type = 'im_company';

update acs_object_types
set type_category_type = 'Intranet Absence Type'
where object_type = 'im_user_absence';

update acs_object_types
set type_category_type = 'Intranet Project Type'
where object_type = 'im_project';

update acs_object_types
set type_category_type = 'Intranet Cost Type'
where object_type = 'im_expense';

update acs_object_types
set type_category_type = 'Intranet Cost Type'
where object_type = 'im_expense_bundle';

update acs_object_types
set type_category_type = 'Intranet Office Type'
where object_type = 'im_office';

update acs_object_types
set type_category_type = 'Intranet User Type'
where object_type = 'person';

update acs_object_types
set type_category_type = 'Intranet Ticket Type'
where object_type = 'im_ticket';



-------------------------------------------------------------
-- Insert a category for upgrade scripts - gracefully
-------------------------------------------------------------


CREATE OR REPLACE FUNCTION im_category_new (
	integer, varchar, varchar, varchar
) RETURNS integer as '
DECLARE
	p_category_id		alias for $1;
	p_category		alias for $2;
	p_category_type		alias for $3;
	p_description		alias for $4;

	v_count			integer;
BEGIN
	select	count(*) into v_count from im_categories
	where	category = p_category and category_type = p_category_type;
	IF v_count > 0 THEN return 0; END IF;

	insert into im_categories(category_id, category, category_type, category_description)
	values (p_category_id, p_category, p_category_type, p_description);

	RETURN 0;
end;' language 'plpgsql';

CREATE OR REPLACE FUNCTION im_category_new (
	integer, varchar, varchar
) RETURNS integer as '
DECLARE
	p_category_id		alias for $1;
	p_category		alias for $2;
	p_category_type		alias for $3;
BEGIN
	RETURN im_category_new(p_category_id, p_category, p_category_type, NULL);
end;' language 'plpgsql';


CREATE OR REPLACE FUNCTION im_category_hierarchy_new (
	integer, integer
) RETURNS integer as '
DECLARE
	p_child_id		alias for $1;
	p_parent_id		alias for $2;

	row			RECORD;
	v_count			integer;
BEGIN
	IF p_child_id is null THEN 
		RAISE NOTICE ''im_category_hierarchy_new: bad category 1: "%" '',p_child_id;
		return 0;
	END IF;

	IF p_parent_id is null THEN 
		RAISE NOTICE ''im_category_hierarchy_new: bad category 2: "%" '',p_parent_id; 
		return 0;
	END IF;
	IF p_child_id = p_parent_id THEN return 0; END IF;

	select	count(*) into v_count from im_category_hierarchy
	where	child_id = p_child_id and parent_id = p_parent_id;
	IF v_count = 0 THEN
		insert into im_category_hierarchy(child_id, parent_id)
		values (p_child_id, p_parent_id);
	END IF;

	-- Loop through the parents of the parent
	FOR row IN
		select	parent_id
		from	im_category_hierarchy
		where	child_id = p_parent_id
	LOOP
		PERFORM im_category_hierarchy_new (p_child_id, row.parent_id);
	END LOOP;

	RETURN 0;
end;' language 'plpgsql';


CREATE OR REPLACE FUNCTION im_category_hierarchy_new (
	varchar, varchar, varchar
) RETURNS integer as '
DECLARE
	p_child			alias for $1;
	p_parent		alias for $2;
	p_cat_type		alias for $3;

	v_child_id		integer;
	v_parent_id		integer;
BEGIN
	select	category_id into v_child_id from im_categories
	where	category = p_child and category_type = p_cat_type;
	IF v_child_id is null THEN 
		RAISE NOTICE ''im_category_hierarchy_new: bad category 1: "%" '',p_child; 
		return 0;
	END IF;

	select	category_id into v_parent_id from im_categories
	where	category = p_parent and category_type = p_cat_type;
	IF v_parent_id is null THEN 
		RAISE NOTICE ''im_category_hierarchy_new: bad category 2: "%" '',p_parent; 
		return 0;
	END IF;

	return im_category_hierarchy_new (v_child_id, v_parent_id);

	RETURN 0;
end;' language 'plpgsql';





-- set the DefaultMaster parameter to "master"

update apm_parameter_values 
set attr_value = '/packages/intranet-core/www/master'
where parameter_id in (
	select parameter_id 
	from apm_parameters 
	where package_key = 'acs-subsite' and parameter_name = 'DefaultMaster'
);


create or replace function im_project_managers_enumerator (integer) 
returns setof integer as '
declare
	p_project_id		alias for $1;

	v_project_id		integer;
	v_parent_id		integer;
	v_project_lead_id	integer;
	v_count			integer;
BEGIN
	v_project_id := p_project_id;
	v_count := 100;

	WHILE (v_project_id is not null AND v_count > 0) LOOP
		select	parent_id, project_lead_id into v_parent_id, v_project_lead_id
		from	im_projects where project_id = v_project_id;

		IF v_project_lead_id is not null THEN RETURN NEXT v_project_lead_id; END IF;
		v_project_id := v_parent_id;
		v_count := v_count - 1;
	END LOOP;

	RETURN;
end;' language 'plpgsql';


CREATE OR REPLACE FUNCTION ad_group_member_p(integer, integer)
RETURNS character AS '
DECLARE
	p_user_id		alias for $1;
	p_group_id		alias for $2;

	ad_group_member_count	integer;
BEGIN
	select count(*)	into ad_group_member_count
	from	acs_rels r,
		membership_rels mr
	where
		r.rel_id = mr.rel_id
		and object_id_one = p_group_id
		and object_id_two = p_user_id
		and mr.member_state = ''approved''
	;

	if ad_group_member_count = 0 then
		return ''f'';
	else
		return ''t'';
	end if;
END;' LANGUAGE 'plpgsql';


-- ---------------------------------------------------------------
-- Find out the status and type of business objects in a generic way


-- ---------------------------------------------------------------
-- Find out the status and type of business objects in a generic way

CREATE OR REPLACE FUNCTION im_biz_object__get_type_id (integer)
RETURNS integer AS '
DECLARE
	p_object_id		alias for $1;

	v_query			varchar;
	v_object_type		varchar;
	v_supertype		varchar;
	v_table			varchar;
	v_id_column		varchar;
	v_type_column		varchar;

	row			RECORD;
	v_result_id		integer;
BEGIN
	-- Get information from SQL metadata system
	select	ot.object_type, ot.supertype, ot.status_type_table, ot.type_column
	into	v_object_type, v_supertype, v_table, v_type_column
	from	acs_objects o, acs_object_types ot
	where	o.object_id = p_object_id
		and o.object_type = ot.object_type;

	-- Check if the object has a supertype and update table necessary
	WHILE v_table is null AND ''acs_object'' != v_supertype AND ''im_biz_object'' != v_supertype LOOP
		select	ot.supertype, ot.table_name
		into	v_supertype, v_table
		from	acs_object_types ot
		where	ot.object_type = v_supertype;
	END LOOP;

	-- Get the id_column for v_table
	select	aott.id_column into v_id_column from acs_object_type_tables aott
	where	aott.object_type = v_object_type and aott.table_name = v_table;

	IF v_table is null OR v_id_column is null OR v_type_column is null THEN
		return 0;
	END IF;

	-- Funny way, but this is the only option to EXECUTE in PG 8.0 and below.
	v_query := '' select '' || v_type_column || '' as result_id '' || '' from '' || v_table || 
		'' where '' || v_id_column || '' = '' || p_object_id;
	FOR row IN EXECUTE v_query
        LOOP
		v_result_id := row.result_id;
		EXIT;
	END LOOP;

	return v_result_id;
END;' language 'plpgsql';



CREATE OR REPLACE FUNCTION im_biz_object__get_status_id (integer)
RETURNS integer AS '
DECLARE
	p_object_id		alias for $1;

	v_query			varchar;
	v_object_type		varchar;
	v_supertype		varchar;
	v_table			varchar;
	v_id_column		varchar;
	v_column		varchar;

	row			RECORD;
	v_result_id		integer;
BEGIN
	-- Get information from SQL metadata system
	select	ot.object_type, ot.supertype, ot.table_name, ot.status_column
	into	v_object_type, v_supertype, v_table, v_column
	from	acs_objects o, acs_object_types ot
	where	o.object_id = p_object_id
		and o.object_type = ot.object_type;

	-- Check if the object has a supertype and update table and id_column if necessary
	WHILE v_table is null AND ''acs_object'' != v_supertype AND ''im_biz_object'' != v_supertype LOOP
		select	ot.supertype, ot.table_name, ot.id_column
		into	v_supertype, v_table, v_id_column
		from	acs_object_types ot
		where	ot.object_type = v_supertype;
	END LOOP;

	-- Get the id_column for v_table
	select	aott.id_column into v_id_column from acs_object_type_tables aott
	where	aott.object_type = v_object_type and aott.table_name = v_table;

	IF v_table is null OR v_id_column is null OR v_column is null THEN
		return 0;
	END IF;

	-- Funny way, but this is the only option to get a value from an EXECUTE in PG 8.0 and below.
	v_query := '' select '' || v_column || '' as result_id '' || '' from '' || v_table || 
		'' where '' || v_id_column || '' = '' || p_object_id;
	FOR row IN EXECUTE v_query
        LOOP
		v_result_id := row.result_id;
		EXIT;
	END LOOP;

	return v_result_id;
END;' language 'plpgsql';



-----------------------------------------------------------------------
-- Set the status of Biz Objects in a generic way


CREATE OR REPLACE FUNCTION im_biz_object__set_status_id (integer, integer) RETURNS integer AS '
DECLARE
	p_object_id		alias for $1;
	p_status_id		alias for $2;
	v_object_type		varchar;
	v_supertype		varchar;	v_table			varchar;
	v_id_column		varchar;	v_column		varchar;
	row			RECORD;
BEGIN
	-- Get information from SQL metadata system
	select	ot.object_type, ot.supertype, ot.table_name, ot.id_column, ot.status_column
	into	v_object_type, v_supertype, v_table, v_id_column, v_column
	from	acs_objects o, acs_object_types ot
	where	o.object_id = p_object_id
		and o.object_type = ot.object_type;

	-- Check if the object has a supertype and update table and id_column if necessary
	WHILE ''acs_object'' != v_supertype AND ''im_biz_object'' != v_supertype LOOP
		select	ot.supertype, ot.table_name, ot.id_column
		into	v_supertype, v_table, v_id_column
		from	acs_object_types ot
		where	ot.object_type = v_supertype;
	END LOOP;

	IF v_table is null OR v_id_column is null OR v_column is null THEN
		RAISE NOTICE ''im_biz_object__set_status_id: Bad metadata: Null value for %'',v_object_type;
		return 0;
	END IF;

	update	acs_objects
	set	last_modified = now()
	where	object_id = p_object_id;

	EXECUTE ''update ''||v_table||'' set ''||v_column||''=''||p_status_id||
		'' where ''||v_id_column||''=''||p_object_id;

	return 0;
END;' language 'plpgsql';



-- compatibility for WF calls
CREATE OR REPLACE FUNCTION im_biz_object__set_status_id (integer, varchar, integer) RETURNS integer AS '
DECLARE
	p_object_id		alias for $1;
	p_dummy			alias for $2;
	p_status_id		alias for $3;
BEGIN
	return im_biz_object__set_status_id (p_object_id, p_status_id::integer);
END;' language 'plpgsql';




create or replace function im_component_plugin__new (
	integer, varchar, timestamptz, integer, varchar, integer, 
	varchar, varchar, varchar, varchar, varchar, integer, varchar
) returns integer as '
declare
	p_plugin_id	alias for $1;	-- default null
	p_object_type	alias for $2;	-- default acs_object
	p_creation_date	alias for $3;	-- default now()
	p_creation_user	alias for $4;	-- default null
	p_creation_ip	alias for $5;	-- default null
	p_context_id	alias for $6;	-- default null
	p_plugin_name	alias for $7;
	p_package_name	alias for $8;
	p_location	alias for $9;
	p_page_url	alias for $10;
	p_view_name	alias for $11;
	p_sort_order	alias for $12;
	p_component_tcl	alias for $13;
	v_plugin_id	integer;
begin
	v_plugin_id := im_component_plugin__new (
		p_plugin_id, p_object_type, p_creation_date,
		p_creation_user, p_creation_ip, p_context_id,
		p_plugin_name, p_package_name,
		p_location, p_page_url,
		p_view_name, p_sort_order,
		p_component_tcl, null
	);
	return v_plugin_id;
end;' language 'plpgsql';




create or replace function im_component_plugin__new (
	integer, varchar, timestamptz, integer, varchar, integer, 
	varchar, varchar, varchar, varchar, varchar, integer, 
	varchar, varchar
) returns integer as '
declare
	p_plugin_id	alias for $1;	-- default null
	p_object_type	alias for $2;	-- default ''acs_object''
	p_creation_date	alias for $3;	-- default now()
	p_creation_user	alias for $4;	-- default null
	p_creation_ip	alias for $5;	-- default null
	p_context_id	alias for $6;	-- default null

	p_plugin_name	alias for $7;
	p_package_name	alias for $8;
	p_location	alias for $9;
	p_page_url	alias for $10;
	p_view_name	alias for $11;	-- default null
	p_sort_order	alias for $12;
	p_component_tcl	alias for $13;
	p_title_tcl	alias for $14;

	v_plugin_id	im_component_plugins.plugin_id%TYPE;
	v_count		integer;
begin
	select count(*) into v_count
	from im_component_plugins
	where plugin_name = p_plugin_name;

	IF v_count > 0 THEN return 0; END IF;

	v_plugin_id := acs_object__new (
		p_plugin_id,		-- object_id
		p_object_type,		-- object_type
		p_creation_date,	-- creation_date
		p_creation_user,	-- creation_user
		p_creation_ip,		-- creation_ip
		p_context_id		-- context_id
	);

	insert into im_component_plugins (
		plugin_id, plugin_name, package_name, sort_order, 
		view_name, page_url, location, 
		component_tcl, title_tcl
	) values (
		v_plugin_id, p_plugin_name, p_package_name, p_sort_order, 
		p_view_name, p_page_url, p_location, 
		p_component_tcl, p_title_tcl
	);

	return v_plugin_id;
end;' language 'plpgsql';


create or replace function im_new_menu (varchar, varchar, varchar, varchar, integer, varchar, varchar) 
returns integer as '
declare
	p_package_name		alias for $1;
	p_label			alias for $2;
	p_name			alias for $3;
	p_url			alias for $4;
	p_sort_order		alias for $5;
	p_parent_menu_label	alias for $6;
	p_visible_tcl		alias for $7;

	v_menu_id		integer;
	v_parent_menu_id	integer;
begin
	-- Check for duplicates
	select	menu_id into v_menu_id
	from	im_menus m where m.label = p_label;
	IF v_menu_id is not null THEN return v_menu_id; END IF;

	-- Get parent menu
	select	menu_id into v_parent_menu_id
	from	im_menus m where m.label = p_parent_menu_label;

	v_menu_id := im_menu__new (
		null,					-- p_menu_id
		''im_menu'',				-- object_type
		now(),					-- creation_date
		null,					-- creation_user
		null,					-- creation_ip
		null,					-- context_id
		p_package_name,
		p_label,
		p_name,
		p_url,
		p_sort_order,
		v_parent_menu_id,
		p_visible_tcl
	);

	return v_menu_id;
end;' language 'plpgsql';

create or replace function im_new_menu_perms (varchar, varchar)
returns integer as '
declare
	p_label		alias for $1;
	p_group		alias for $2;
	v_menu_id		integer;
	v_group_id		integer;
begin
	select	menu_id into v_menu_id
	from	im_menus where label = p_label;

	select	group_id into v_group_id
	from	groups where lower(group_name) = lower(p_group);

	PERFORM acs_permission__grant_permission(v_menu_id, v_group_id, ''read'');
	return v_menu_id;
end;' language 'plpgsql';




CREATE OR REPLACE FUNCTION im_category_new (
	integer, varchar, varchar
) RETURNS integer as '
DECLARE
	p_category_id	alias for $1;
	p_category		alias for $2;
	p_category_type	alias for $3;
	v_count		integer;
BEGIN
	select	count(*) into v_count
	from	im_categories
	where	category = p_category and
		category_type = p_category_type;

	IF v_count > 0 THEN return 0; END IF;

	insert into im_categories(category_id, category, category_type)
	values (p_category_id, p_category, p_category_type);

	RETURN 0;
end;' language 'plpgsql';



CREATE OR REPLACE FUNCTION im_category_hierarchy_new (
	varchar, varchar, varchar
) RETURNS integer as '
DECLARE
	p_child			alias for $1;
	p_parent		alias for $2;
	p_cat_type		alias for $3;

	v_child_id		integer;
	v_parent_id		integer;
	v_count			integer;
BEGIN
	select	category_id into v_child_id from im_categories
	where	category = p_child and category_type = p_cat_type;
	IF v_child_id is null THEN RAISE NOTICE ''im_category_hierarchy_new: bad category 1: "%" '',p_child; END IF;

	select	category_id into v_parent_id from im_categories
	where	category = p_parent and category_type = p_cat_type;
	IF v_parent_id is null THEN RAISE NOTICE ''im_category_hierarchy_new: bad category 2: "%" '',p_parent; END IF;

	select	count(*) into v_count from im_category_hierarchy
	where	child_id = v_child_id and parent_id = v_parent_id;
	IF v_count > 0 THEN return 0; END IF;

	insert into im_category_hierarchy(child_id, parent_id)
	values (v_child_id, v_parent_id);

	RETURN 0;
end;' language 'plpgsql';




-- -------------------------------------------------------
-- Setup "components" menu 
--

create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_admin_menu		integer;
	v_main_menu		integer;
BEGIN
	select menu_id into v_main_menu
	from im_menus where label = ''admin'';

	-- Main admin menu - just an invisible top-menu
	-- for all admin entries links under Projects
	v_admin_menu := im_menu__new (
		null,				-- p_menu_id
		''im_menu'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-core'',		-- package_name
		''admin_components'',		-- label
		''Portlet Components'',		-- name
		''/intranet/admin/components/'', -- url
		90,				-- sort_order
		v_main_menu,			-- parent_menu_id
		''0''				-- p_visible_tcl
	);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




-- -------------------------------------------------------
-- Setup "DynView" menu 
--

create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_admin_menu		integer;
	v_main_menu		integer;
BEGIN
	select menu_id into v_main_menu
	from im_menus where label = ''admin'';

	-- Main admin menu - just an invisible top-menu
	-- for all admin entries links under Projects
	v_admin_menu := im_menu__new (
		null,				-- p_menu_id
		''im_menu'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-core'',		-- package_name
		''admin_dynview'',		-- label
		''DynView'',			-- name
		''/intranet/admin/views/'',	-- url
		751,				-- sort_order
		v_main_menu,			-- parent_menu_id
		''0''				-- p_visible_tcl
	);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



-- -------------------------------------------------------
-- Setup "backup" menu 
--

create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_admin_menu		integer;
	v_main_menu		integer;
BEGIN
	select menu_id into v_main_menu
	from im_menus where label = ''admin'';

	-- Main admin menu - just an invisible top-menu
	-- for all admin entries links under Projects
	v_admin_menu := im_menu__new (
		null,				-- p_menu_id
		''im_menu'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-core'',		-- package_name
		''admin_backup'',		-- label
		''Backup'',			-- name
		''/intranet/admin/backup/'',	-- url
		11,				-- sort_order
		v_main_menu,			-- parent_menu_id
		''0''				-- p_visible_tcl
	);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



-- -------------------------------------------------------
-- Setup "Packages" menu 
--

create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_admin_menu		integer;
	v_main_menu		integer;
BEGIN
	select menu_id into v_main_menu
	from im_menus where label = ''admin'';

	-- Main admin menu - just an invisible top-menu
	-- for all admin entries links under Projects
	v_admin_menu := im_menu__new (
		null,				-- p_menu_id
		''im_menu'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-core'',		-- package_name
		''admin_packages'',		-- label
		''Packages'',			-- name
		''/acs-admin/apm/'',		-- url
		190,				-- sort_order
		v_main_menu,			-- parent_menu_id
		''0''				-- p_visible_tcl
	);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



-- -------------------------------------------------------
-- Setup "Workflow" menu 
--

create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_admin_menu		integer;
	v_main_menu		integer;
BEGIN
	select menu_id into v_main_menu
	from im_menus where label = ''admin'';

	-- Main admin menu - just an invisible top-menu
	-- for all admin entries links under Projects
	v_admin_menu := im_menu__new (
		null,				-- p_menu_id
		''im_menu'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-workflow'',		-- package_name
		''admin_workflow'',		-- label
		''Workflow'',			-- name
		''/workflow/admin/'',		-- url
		1090,				-- sort_order
		v_main_menu,			-- parent_menu_id
		''0''				-- p_visible_tcl
	);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



-- -------------------------------------------------------
-- Setup "Flush Permission Cash" menu 
--

create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_admin_menu		integer;
	v_main_menu		integer;
BEGIN
	select menu_id into v_main_menu
	from im_menus where label = ''admin'';

	-- Main admin menu - just an invisible top-menu
	-- for all admin entries links under Projects
	v_admin_menu := im_menu__new (
		null,				-- p_menu_id
		''im_menu'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-core'',		-- package_name
		''admin_flush'',		-- label
		''Flush Cache'',		-- name
		''/intranet/admin/flush_cache'',	-- url
		11,				-- sort_order
		v_main_menu,			-- parent_menu_id
		''0''				-- p_visible_tcl
	);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


-- -------------------------------------------------------
-- Developer
-- -------------------------------------------------------

create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_admin_menu		integer;
	v_main_menu		integer;
BEGIN
	select menu_id into v_main_menu
	from im_menus where label = ''main'';

	-- Main admin menu - just an invisible top-menu
	-- for all admin entries links under Projects
	v_admin_menu := im_menu__new (
		null,				-- p_menu_id
		''im_menu'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-core'',		-- package_name
		''openacs'',			-- label
		''OpenACS'',			-- name
		''/acs-admin/'',		-- url
		1000,				-- sort_order
		v_main_menu,			-- parent_menu_id
		''''				-- p_visible_tcl
	);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


-- -------------------------------------------------------
-- API-Doc

create or replace function inline_0 ()
returns integer as '
declare
	v_admin_menu		integer;
	v_main_menu		integer;
BEGIN
	select menu_id into v_main_menu
	from im_menus where label = ''openacs'';

	-- Main admin menu - just an invisible top-menu
	-- for all admin entries links under Projects
	v_admin_menu := im_menu__new (
		null,				-- p_menu_id
		''im_menu'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-core'',		-- package_name
		''openacs_api_doc'',		-- label
		''API Doc'',			-- name
		''/api-doc/'',			-- url
		10,				-- sort_order
		v_main_menu,			-- parent_menu_id
		''''				-- p_visible_tcl
	);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



-- -------------------------------------------------------
-- API-Doc

create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_admin_menu		integer;
	v_main_menu		integer;
BEGIN
	select menu_id into v_main_menu
	from im_menus where label = ''openacs'';

	-- Main admin menu - just an invisible top-menu
	-- for all admin entries links under Projects
	v_admin_menu := im_menu__new (
		null,				-- p_menu_id
		''im_menu'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-core'',		-- package_name
		''openacs_developer'',		-- label
		''Developer Home'',		-- name
		''/acs-admin/developer'',	-- url
		20,				-- sort_order
		v_main_menu,			-- parent_menu_id
		''''				-- p_visible_tcl
	);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_admin_menu		integer;
	v_main_menu		integer;
BEGIN
	select menu_id into v_main_menu
	from im_menus where label = ''openacs'';

	-- Main admin menu - just an invisible top-menu
	-- for all admin entries links under Projects
	v_admin_menu := im_menu__new (
		null,				-- p_menu_id
		''im_menu'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-core'',		-- package_name
		''openacs_l10n'',		-- label
		''Localization Home'',		-- name
		''/acs-lang/admin'',		-- url
		20,				-- sort_order
		v_main_menu,			-- parent_menu_id
		''''				-- p_visible_tcl
	);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_admin_menu		integer;
	v_main_menu		integer;
BEGIN
	select menu_id into v_main_menu
	from im_menus where label = ''openacs'';

	-- Main admin menu - just an invisible top-menu
	-- for all admin entries links under Projects
	v_admin_menu := im_menu__new (
		null,				-- p_menu_id
		''im_menu'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-core'',		-- package_name
		''openacs_package_manager'',	-- label
		''Package Manager'',		-- name
		''/acs-admin/apm/'',		-- url
		30,				-- sort_order
		v_main_menu,			-- parent_menu_id
		''''				-- p_visible_tcl
	);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_admin_menu		integer;
	v_main_menu		integer;
BEGIN
	select menu_id into v_main_menu
	from im_menus where label = ''openacs'';

	-- Main admin menu - just an invisible top-menu
	-- for all admin entries links under Projects
	v_admin_menu := im_menu__new (
		null,				-- p_menu_id
		''im_menu'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-core'',		-- package_name
		''openacs_sitemap'',		-- label
		''Sitemap'',			-- name
		''/admin/site-map/'',			-- url
		40,				-- sort_order
		v_main_menu,			-- parent_menu_id
		''''				-- p_visible_tcl
	);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_admin_menu		integer;
	v_main_menu		integer;
BEGIN
	select menu_id into v_main_menu
	from im_menus where label = ''openacs'';

	-- Main admin menu - just an invisible top-menu
	-- for all admin entries links under Projects
	v_admin_menu := im_menu__new (
		null,				-- p_menu_id
		''im_menu'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-core'',		-- package_name
		''openacs_ds'',			-- label
		''SQL Profiling'',		-- name
		''/ds/'',			-- url
		50,				-- sort_order
		v_main_menu,			-- parent_menu_id
		''''				-- p_visible_tcl
	);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_admin_menu		integer;
	v_main_menu		integer;
BEGIN
	select menu_id into v_main_menu
	from im_menus where label = ''openacs'';

	-- Main admin menu - just an invisible top-menu
	-- for all admin entries links under Projects
	v_admin_menu := im_menu__new (
		null,				-- p_menu_id
		''im_menu'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-core'',		-- package_name
		''openacs_shell'',		-- label
		''Interactive Shell'',		-- name
		''/ds/shell'',			-- url
		55,				-- sort_order
		v_main_menu,			-- parent_menu_id
		''''				-- p_visible_tcl
	);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_admin_menu		integer;
	v_main_menu		integer;
BEGIN
	select menu_id into v_main_menu
	from im_menus where label = ''openacs'';

	-- Main admin menu - just an invisible top-menu
	-- for all admin entries links under Projects
	v_admin_menu := im_menu__new (
		null,				-- p_menu_id
		''im_menu'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-core'',		-- package_name
		''openacs_cache'',		-- label
		''Cache Status'',		-- name
		''/acs-admin/cache/'',		-- url
		60,				-- sort_order
		v_main_menu,			-- parent_menu_id
		''''				-- p_visible_tcl
	);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_admin_menu		integer;
	v_main_menu		integer;
BEGIN
	select menu_id into v_main_menu
	from im_menus where label = ''openacs'';

	-- Main admin menu - just an invisible top-menu
	-- for all admin entries links under Projects
	v_admin_menu := im_menu__new (
		null,				-- p_menu_id
		''im_menu'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-core'',		-- package_name
		''openacs_auth'',		-- label
		''Authentication'',		-- name
		''/acs-admin/auth/'',			-- url
		80,				-- sort_order
		v_main_menu,			-- parent_menu_id
		''''				-- p_visible_tcl
	);

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




-- -----------------------------------------------------
-- Auth Authorities
-- -----------------------------------------------------

create or replace function inline_1 ()
returns integer as '
declare
	v_menu			integer;
	v_admin_menu		integer;
	v_admins		integer;
begin
	select group_id into v_admins from groups where group_name = ''P/O Admins'';

	select menu_id into v_admin_menu
	from im_menus
	where label=''admin'';

	v_menu := im_menu__new (
		null,				-- p_menu_id
		''im_menu'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-core'',		-- package_name
		''admin_auth_authorities'',	-- label
		''Auth Authorities'',		-- name
		''/acs-admin/auth/index'',	-- url
		120,				-- sort_order
		v_admin_menu,			-- parent_menu_id
		null				-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
	return 0;
end;' language 'plpgsql';
select inline_1 ();
drop function inline_1();

-- new ticket type for helpdesk
SELECT im_category_new(101, 'Ticket', 'Intranet Project Type');


CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer as '
DECLARE
	v_count			integer;
BEGIN
	select	count(*) into v_count from acs_object_type_tables
	where	object_type = ''im_office'' and table_name = ''im_offices'';
	IF v_count > 0 THEN return 0; END IF;

	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_office'', ''im_offices'', ''office_id'');

	RETURN 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();






select define_function_args('im_biz_object__delete','id');
select define_function_args('im_biz_object__name','id');
select define_function_args('im_biz_object__new','biz_object_id,object_type,creation_date,creation_user,creation_ip,context_id');
select define_function_args('im_biz_object__type','object_id');
select define_function_args('im_biz_object_member__delete','object_id,user_id');
select define_function_args('im_biz_object_member__new','rel_id,rel_type,object_id,user_id,object_role_id,percentage,creation_user,creation_ip');
select define_function_args('im_company__delete','company_id');
select define_function_args('im_company__name','company_id');
select define_function_args('im_company__new','company_id,object_type,creation_date,creation_user,creation_ip,context_id,company_name,company_path,main_office_id,company_type_id,company_status_id');
select define_function_args('im_component_plugin__del_module','module_name');
select define_function_args('im_component_plugin__delete','plugin_id');
select define_function_args('im_component_plugin__name','plugin_id');
select define_function_args('im_component_plugin__new','plugin_id;null,object_type;acs_object,creation_date;now(),creation_user;null,creation_ip;null,context_id;null,plugin_name,package_name,location,page_url,view_name;null,sort_order,component_tcl,title_tcl');
select define_function_args('im_cost__delete','cost_id');
select define_function_args('im_cost__name','cost_id');
select define_function_args('im_cost__new','cost_id,object_type,creation_date,creation_user,creation_ip,context_id,cost_name,parent_id,project_id,customer_id,provider_id,investment_id,cost_status_id,cost_type_id,template_id,effective_date,payment_days,amount,currency,vat,tax,variable_cost_p,needs_redistribution_p,redistributed_p,planning_p,planning_type_id,note,description');
select define_function_args('im_cost_center__delete','cost_center_id');
select define_function_args('im_cost_center__name','cost_center_id');
select define_function_args('im_cost_center__new','cost_center_id,object_type,creation_date,creation_user,creation_ip,context_id,cost_center_name,cost_center_label,cost_center_code,type_id,status_id,parent_id,manager_id,department_p,description,note');
select define_function_args('im_dynfield_attribute__del','attribute_id');
select define_function_args('im_dynfield_attribute__name','attribute_id');
select define_function_args('im_dynfield_attribute__new','attribute_id,object_type,creation_date,creation_user,creation_ip,context_id,attribute_object_type,attribute_name,min_n_values,max_n_values,default_value,datatype,pretty_name,pretty_plural,widget_name,deprecated_p,already_existed_p');
select define_function_args('im_dynfield_widget__delete','widget_id');
select define_function_args('im_dynfield_widget__name','widget_id');
select define_function_args('im_dynfield_widget__new','widget_id,object_type,creation_date,creation_user,creation_ip,context_id,widget_name,pretty_name,pretty_plural,storage_type_id,acs_datatype,widget,sql_datatype,parameters');
select define_function_args('im_expense__delete','expense_id');
select define_function_args('im_expense__name','expenses_id');
select define_function_args('im_expense__new','expense_id,object_type,creation_date,creation_user,creation_ip,context_id,expense_name,project_id,expense_date,expense_currency,expense_template_id,expense_status_id,cost_type_id,payment_days,amount,vat,tax,note,external_company_name,external_company_vat_number,receipt_reference,expense_type_id,billable_p,reimbursable,expense_payment_type_id,customer_id,provider_id');
select define_function_args('im_expenses__delete','expense_id');
select define_function_args('im_expenses__name','expenses_id');
select define_function_args('im_fs_file__delete','fs_file_id');
select define_function_args('im_fs_file__name','fs_file_id');
select define_function_args('im_fs_file__new','fs_file_id,object_type,creation_date,creation_user,creation_ip,context_id,fs_file_path,fs_file_type_id,fs_file_status_id');
select define_function_args('im_invoice__delete','invoice_id');
select define_function_args('im_invoice__name','invoice_id');
select define_function_args('im_invoice__new','invoice_id,object_type,creation_date,creation_user,creation_ip,context_id,invoice_nr,company_id,provider_id,company_contact_id,invoice_date,invoice_currency,invoice_template_id,invoice_status_id,invoice_type_id,payment_method_id,payment_days,amount,vat,tax,note');
select define_function_args('im_material__delete','material_id');
select define_function_args('im_material__name','material_id');
select define_function_args('im_material__new','material_id,object_type,creation_date,creation_user,creation_ip,context_id,material_name,material_nr,material_type_id,material_status_id,material_uom_id,description');
select define_function_args('im_menu__del_module','module_name');
select define_function_args('im_menu__delete','menu_id');
select define_function_args('im_menu__name','menu_id');
select define_function_args('im_menu__new','menu_id;null,object_type;acs_object,creation_date;now(),creation_user;null,creation_ip;null,context_id;null,package_name,label,name,url,sort_order,parent_menu_id,visible_tcl;null');
select define_function_args('im_office__delete','office_id');
select define_function_args('im_office__name','office_id');
select define_function_args('im_office__name','office_id');
select define_function_args('im_office__new','office_id,object_type,creation_date,creation_user,creation_ip,context_id,office_name,office_path,office_type_id,office_status_id,company_id');
select define_function_args('im_profile__delete','profile_id');
select define_function_args('im_profile__name','profile_id');
select define_function_args('im_profile__new','profile_id,object_type,creation_date,creation_user,creation_ip,context_id,email,url,group_name,join_policy,profile_gif');
select define_function_args('im_project__delete','project_id');
select define_function_args('im_project__name','project_id');
select define_function_args('im_project__new','project_id,object_type,creation_date,creation_user,creation_ip,context_id,project_name,project_nr,project_path,parent_id,company_id,project_type_id,project_status_id');
select define_function_args('im_repeating_cost__delete','cost_id');
select define_function_args('im_repeating_cost__name','cost_id');
select define_function_args('im_timesheet_invoice__delete','invoice_id');
select define_function_args('im_timesheet_invoice__name','invoice_id');
select define_function_args('im_timesheet_invoice__new','invoice_id,object_type,creation_date,creation_user,creation_ip,context_id,invoice_nr,customer_id,provider_id,company_contact_id,invoice_date,invoice_currency,invoice_template_id,invoice_status_id,invoice_type_id,payment_method_id,payment_days,amount,vat,tax,note');
select define_function_args('im_timesheet_task__delete','task_id');
select define_function_args('im_timesheet_task__name','task_id');
select define_function_args('im_timesheet_task__new','task_id,object_type,creation_date,creation_user,creation_ip,context_id,task_nr,task_name,project_id,material_id,cost_center_id,uom_id,task_type_id,task_status_id,description');
select define_function_args('im_trans_invoice__delete','invoice_id');
select define_function_args('im_trans_invoice__name','invoice_id');
select define_function_args('im_trans_invoice__new','invoice_id,object_type,creation_date,creation_user,creation_ip,context_id,invoice_nr,customer_id,provider_id,company_contact_id,invoice_date,invoice_currency,invoice_template_id,invoice_status_id,invoice_type_id,payment_method_id,payment_days,amount,vat,tax,note');
select define_function_args('im_trans_rfq__delete','trans_rfq_id');
select define_function_args('im_trans_rfq__name','trans_rfqs_id');
select define_function_args('im_trans_rfq__new','trans_rfq_id,object_type,creation_date,creation_user,creation_ip,context_id,rfq_name,project_id');
select define_function_args('im_trans_rfq_answer__delete','trans_rfq_answer_id');
select define_function_args('im_trans_rfq_answer__name','trans_rfq_answers_id');
select define_function_args('im_trans_rfq_answer__new','trans_rfq_answer_id,object_type,creation_date,creation_user,creation_ip,context_id,user_id,rfq_id,project_id,type_id,status_id');
select define_function_args('im_trans_task__delete','task_id');
select define_function_args('im_trans_task__name','task_id');
select define_function_args('im_trans_task__new','task_id,object_type,creation_date,creation_user,creation_ip,context_id,project_id,task_type_id,task_status_id,source_language_id,target_language_id,task_uom_id');
select define_function_args('im_trans_task__project_clone','parent_project_id,clone_project_id');



create or replace function workflow__add_trans_attribute_map (varchar,varchar,integer,integer)
returns integer as '
declare
  p_workflow_key                alias for $1;
  p_transition_key              alias for $2;
  p_attribute_id                alias for $3;
  p_sort_order                  alias for $4;
  v_num_rows                    integer;
  v_sort_order                  integer;
begin
        select count(*)
          into v_num_rows
          from wf_transition_attribute_map
         where workflow_key = p_workflow_key
           and transition_key = p_transition_key
           and attribute_id = p_attribute_id;

        if v_num_rows > 0 then
            return 0;
        end if;
        if p_sort_order is null then
            select coalesce(max(sort_order)+1, 1)
              into v_sort_order
              from wf_transition_attribute_map
             where workflow_key = p_workflow_key
               and transition_key = p_transition_key;
        else
            v_sort_order := p_sort_order;
        end if;
        insert into wf_transition_attribute_map (
            workflow_key,
            transition_key,
            attribute_id,
            sort_order
        ) values (
            p_workflow_key,
            p_transition_key,
            p_attribute_id,
            v_sort_order
       );
  return 0;
end;' language 'plpgsql';

