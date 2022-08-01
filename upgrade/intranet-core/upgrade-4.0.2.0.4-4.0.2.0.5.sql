-- upgrade-4.0.2.0.4-4.0.2.0.5.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.2.0.4-4.0.2.0.5.sql','');


------------------------------------------------
-- Copy of upgrade-3.0.0.0.first.sql

create or replace function acs_privilege__create_privilege (varchar,varchar,varchar)
returns integer as '
declare
	create_privilege__privilege             alias for $1;  
	create_privilege__pretty_name           alias for $2;  -- default null  
	create_privilege__pretty_plural         alias for $3;  -- default null
	v_count					integer;
begin
	select count(*) into v_count from acs_privileges
	where privilege = create_privilege__privilege;
	IF v_count > 0 THEN return 0; END IF;

	insert into acs_privileges (
		privilege, pretty_name, pretty_plural
	) values (
		create_privilege__privilege, 
		create_privilege__pretty_name, 
		create_privilege__pretty_plural
	);

    return 0; 
end;' language 'plpgsql';



create or replace function acs_privilege__add_child (varchar,varchar)
returns integer as '
declare
	add_child__privilege            alias for $1;  
	add_child__child_privilege      alias for $2;  
	v_count				integer;
begin
	select count(*) into v_count from acs_privilege_hierarchy
	where privilege = add_child__privilege and child_privilege = add_child__child_privilege;
	IF v_count > 0 THEN return 0; END IF;
	
	insert into acs_privilege_hierarchy (
		privilege, child_privilege
	) values (
		add_child__privilege, add_child__child_privilege
	);

    return 0; 
end;' language 'plpgsql';



-----------------------------------------------------------------------
-- im_menus
-----------------------------------------------------------------------

create or replace function im_menu__new (integer, varchar, timestamptz, integer, varchar, integer,
varchar, varchar, varchar, varchar, integer, integer, varchar) returns integer as '
declare
	p_menu_id	  alias for $1;   -- default null
        p_object_type	  alias for $2;   -- default ''acs_object''
        p_creation_date	  alias for $3;   -- default now()
        p_creation_user	  alias for $4;   -- default null
        p_creation_ip	  alias for $5;   -- default null
        p_context_id	  alias for $6;   -- default null
	p_package_name	  alias for $7;
	p_label		  alias for $8;
	p_name		  alias for $9;
	p_url		  alias for $10;
	p_sort_order	  alias for $11;
	p_parent_menu_id  alias for $12;
	p_visible_tcl	  alias for $13;  -- default null

	v_menu_id	  im_menus.menu_id%TYPE;
begin
	select	menu_id	into v_menu_id from im_menus m where m.label = p_label;
	IF v_menu_id is not null THEN return v_menu_id; END IF;

	v_menu_id := acs_object__new (
                p_menu_id,    -- object_id
                p_object_type,  -- object_type
                p_creation_date,        -- creation_date
                p_creation_user,        -- creation_user
                p_creation_ip,  -- creation_ip
                p_context_id    -- context_id
        );

	insert into im_menus (
		menu_id, package_name, label, name, 
		url, sort_order, parent_menu_id, visible_tcl
	) values (
		v_menu_id, p_package_name, p_label, p_name, p_url, 
		p_sort_order, p_parent_menu_id, p_visible_tcl
	);
	return v_menu_id;
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




-----------------------------------------------------------------------
-- im_plugin_components
-----------------------------------------------------------------------

-- Add a "title_tcl" field to Components
--
create or replace function inline_0 ()
returns integer as '
declare
	v_count	 integer;
begin
	select count(*) into v_count from user_tab_columns
	where table_name = ''IM_COMPONENT_PLUGINS'' and column_name = ''TITLE_TCL'';
	if v_count > 0 then return 0; end if;

	alter table im_component_plugins add title_tcl text;

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


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
begin
	select plugin_id into v_plugin_id from im_component_plugins
	where plugin_name = p_plugin_name and package_name = p_package_name;
	IF v_plugin_id is not null THEN return v_plugin_id; END IF;

	v_plugin_id := acs_object__new (
		p_plugin_id,	-- object_id
		p_object_type,	-- object_type
		p_creation_date,	-- creation_date
		p_creation_user,	-- creation_user
		p_creation_ip,	-- creation_ip
		p_context_id	-- context_id
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


create or replace function im_component_plugin__new (
	integer, varchar, timestamptz, integer, varchar, integer, 
	varchar, varchar, varchar, varchar, varchar, integer, varchar
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
	where	(category = p_category and category_type = p_category_type) OR
		category_id = p_category_id;
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


-----------------------------------------------------------------------
-- 
-----------------------------------------------------------------------

-- Duplicate tollerant version of create_type
create or replace function acs_object_type__create_type (
	varchar, varchar, varchar, varchar, varchar,
	varchar, varchar, boolean, varchar, varchar
) returns integer as '
declare
	create_type__object_type		alias for $1;	
	create_type__pretty_name		alias for $2;	
	create_type__pretty_plural		alias for $3;	
	create_type__supertype			alias for $4;	
	create_type__table_name			alias for $5;	
	create_type__id_column			alias for $6;	-- default ''XXX''
	create_type__package_name		alias for $7;	-- default null
	create_type__abstract_p			alias for $8;	-- default ''f''
	create_type__type_extension_table	alias for $9;	-- default null
	create_type__name_method		alias for $10;	-- default null
	v_package_name				acs_object_types.package_name%TYPE;
	v_supertype				acs_object_types.supertype%TYPE;
	v_name_method				varchar;
	v_idx					integer;
	v_count					integer;
begin
	select count(*) into v_count from acs_object_types
	where object_type = create_type__object_type;
	if v_count > 0 then return 0; end if;

	v_idx := position(''.'' in create_type__name_method);
	if v_idx <> 0 then
		 v_name_method := substr(create_type__name_method,1,v_idx - 1) || 
			 ''__'' || substr(create_type__name_method, v_idx + 1);
	else 	 v_name_method := create_type__name_method;
	end if;

	if create_type__package_name is null or create_type__package_name = '''' then
		v_package_name := create_type__object_type;
	else	v_package_name := create_type__package_name;
	end if;

	if create_type__supertype is null or create_type__supertype = '''' then
		v_supertype := ''acs_object'';
	else	v_supertype := create_type__supertype;
	end if;

	insert into acs_object_types (
		object_type, pretty_name, pretty_plural, supertype, table_name,
		 id_column, abstract_p, type_extension_table, package_name,
		 name_method
	) values (
		create_type__object_type, create_type__pretty_name, 
		 create_type__pretty_plural, v_supertype, 
		 create_type__table_name, create_type__id_column, 
		 create_type__abstract_p, create_type__type_extension_table, 
		 v_package_name, v_name_method
	);

	return 0; 
end;' language 'plpgsql';



-----------------------------------------------------------------------
-- 
-----------------------------------------------------------------------

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



-----------------------------------------------------------------------
-- 
-----------------------------------------------------------------------


create or replace function im_dynfield_widget__new (
	integer, varchar, timestamptz, integer, varchar, integer,
	varchar, varchar, varchar, integer, varchar, varchar, 
	varchar, varchar
) returns integer as '
DECLARE
	p_widget_id		alias for $1;
	p_object_type		alias for $2;
	p_creation_date 	alias for $3;
	p_creation_user 	alias for $4;
	p_creation_ip		alias for $5;
	p_context_id		alias for $6;

	p_widget_name		alias for $7;
	p_pretty_name		alias for $8;
	p_pretty_plural		alias for $9;
	p_storage_type_id	alias for $10;
	p_acs_datatype		alias for $11;
	p_widget		alias for $12;
	p_sql_datatype		alias for $13;
	p_parameters		alias for $14;

	v_widget_id		integer;
BEGIN
	select widget_id  into v_widget_id from im_dynfield_widgets
	where widget_name = p_widget_name;
	if v_widget_id is not null then return v_widget_id; end if;

	v_widget_id := acs_object__new (
		p_widget_id,
		p_object_type,
		p_creation_date,
		p_creation_user,
		p_creation_ip,
		p_context_id
	);

	insert into im_dynfield_widgets (
		widget_id, widget_name, pretty_name, pretty_plural,
		storage_type_id, acs_datatype, widget, sql_datatype, parameters
	) values (
		v_widget_id, p_widget_name, p_pretty_name, p_pretty_plural,
		p_storage_type_id, p_acs_datatype, p_widget, p_sql_datatype, p_parameters
	);
	return v_widget_id;
end;' language 'plpgsql';



create or replace function im_dynfield_attribute__new (
	integer, varchar, timestamptz, integer, varchar, integer,
	varchar, varchar, integer, integer, varchar, 
	varchar, varchar, varchar, varchar, char, char
) returns integer as '
DECLARE
	p_attribute_id		alias for $1;
	p_object_type		alias for $2;
	p_creation_date 	alias for $3;
	p_creation_user 	alias for $4;
	p_creation_ip		alias for $5;
	p_context_id		alias for $6;

	p_attribute_object_type	alias for $7;
	p_attribute_name	alias for $8;
	p_min_n_values		alias for $9;
	p_max_n_values		alias for $10;
	p_default_value		alias for $11;

	p_datatype		alias for $12;
	p_pretty_name		alias for $13;
	p_pretty_plural		alias for $14;
	p_widget_name		alias for $15;
	p_deprecated_p		alias for $16;
	p_already_existed_p	alias for $17;

	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_table_name		varchar;
BEGIN
	-- Check for duplicate
	select	da.attribute_id into v_attribute_id
	from	acs_attributes aa, im_dynfield_attributes da 
	where	aa.attribute_id = da.acs_attribute_id and
		aa.attribute_name = p_attribute_name and aa.object_type = p_attribute_object_type;
	if v_attribute_id is not null then return v_attribute_id; end if;

	select table_name into v_table_name
	from acs_object_types where object_type = p_attribute_object_type;

	v_acs_attribute_id := acs_attribute__create_attribute (
		p_attribute_object_type,
		p_attribute_name,
		p_datatype,
		p_pretty_name,
		p_pretty_plural,
		v_table_name,		-- table_name
		null,			-- column_name
		p_default_value,
		p_min_n_values,
		p_max_n_values,
		null,			-- sort order
		''type_specific'',	-- storage
		''f''			-- static_p
	);

	v_attribute_id := acs_object__new (
		p_attribute_id,
		p_object_type,
		p_creation_date,
		p_creation_user,
		p_creation_ip,
		p_context_id
	);

	insert into im_dynfield_attributes (
		attribute_id, acs_attribute_id, widget_name,
		deprecated_p, already_existed_p
	) values (
		v_attribute_id, v_acs_attribute_id, p_widget_name,
		p_deprecated_p, p_already_existed_p
	);

	-- By default show the field for all object types
	insert into im_dynfield_type_attribute_map (attribute_id, object_type_id, display_mode)
	select	ida.attribute_id,
		c.category_id,
		''edit''
	from	im_dynfield_attributes ida,
		acs_attributes aa,
		acs_object_types aot,
		im_categories c
	where	ida.acs_attribute_id = aa.attribute_id and
		aa.object_type = aot.object_type and
		aot.type_category_type = c.category_type and
		aot.object_type = p_attribute_object_type and
		aa.attribute_name = p_attribute_name;

	return v_attribute_id;
end;' language 'plpgsql';






create or replace function im_dynfield_attribute__new (
	integer, varchar, timestamptz, integer, varchar, integer,
	varchar, varchar, integer, integer, varchar, 
	varchar, varchar, varchar, varchar, char, char, char
) returns integer as '
DECLARE
	p_attribute_id		alias for $1;
	p_object_type		alias for $2;
	p_creation_date 	alias for $3;
	p_creation_user 	alias for $4;
	p_creation_ip		alias for $5;
	p_context_id		alias for $6;

	p_attribute_object_type	alias for $7;
	p_attribute_name	alias for $8;
	p_min_n_values		alias for $9;
	p_max_n_values		alias for $10;
	p_default_value		alias for $11;

	p_datatype		alias for $12;
	p_pretty_name		alias for $13;
	p_pretty_plural		alias for $14;
	p_widget_name		alias for $15;
	p_deprecated_p		alias for $16;
	p_already_existed_p	alias for $17;

	p_table_name		alias for $18;

	v_acs_attribute_id	integer;
	v_attribute_id		integer;

BEGIN
	-- Check for duplicate
	select	da.attribute_id into v_attribute_id
	from	acs_attributes aa, im_dynfield_attributes da 
	where	aa.attribute_id = da.acs_attribute_id and
		aa.attribute_name = p_attribute_name and aa.object_type = p_attribute_object_type;
	if v_attribute_id is not null then return v_attribute_id; end if;

	v_acs_attribute_id := acs_attribute__create_attribute (
		p_attribute_object_type,
		p_attribute_name,
		p_datatype,
		p_pretty_name,
		p_pretty_plural,
		p_table_name,		-- table_name
		null,			-- column_name
		p_default_value,
		p_min_n_values,
		p_max_n_values,
		null,			-- sort order
		''type_specific'',	-- storage
		''f''			-- static_p
	);

	v_attribute_id := acs_object__new (
		p_attribute_id,
		p_object_type,
		p_creation_date,
		p_creation_user,
		p_creation_ip,
		p_context_id
	);

	insert into im_dynfield_attributes (
		attribute_id, acs_attribute_id, widget_name,
		deprecated_p, already_existed_p
	) values (
		v_attribute_id, v_acs_attribute_id, p_widget_name,
		p_deprecated_p, p_already_existed_p
	);

	-- By default show the field for all object types
	insert into im_dynfield_type_attribute_map (attribute_id, object_type_id, display_mode)
	select	ida.attribute_id,
		c.category_id,
		''edit''
	from	im_dynfield_attributes ida,
		acs_attributes aa,
		acs_object_types aot,
		im_categories c
	where	ida.acs_attribute_id = aa.attribute_id and
		aa.object_type = aot.object_type and
		aot.type_category_type = c.category_type and
		aot.object_type = p_attribute_object_type and
		aa.attribute_name = p_attribute_name;

	return v_attribute_id;
end;' language 'plpgsql';






----------------------------------------------------------------
-- upgrade-4.0.2.0.4-4.0.2.0.5.sql


-- Create a fake object type, because im_categories does not "reference" acs_objects.
select acs_object_type__create_type (
	'im_category',		-- object_type
	'PO Category',		-- pretty_name
	'PO Categories',	-- pretty_plural
	'acs_object',		-- supertype
	'im_categories',	-- table_name
	'category_id',		-- id_column
	'intranet-core',	-- package_name
	'f',			-- abstract_p
	null,			-- type_extension_table
	'im_category_from_id'	-- name_method
);




-- Select out the lowest parent of the category.
-- This makes sense as a fast approximation, but 
-- isn't correct. 
-- ToDo: Pull out the real top-level parent
--
create or replace function im_category_min_parent (
	integer
) returns integer as $body$
declare
	p_cat			alias for $1;
	v_cat			integer;
BEGIN
	select	min(c.category_id) into v_cat
	from	im_categories c,
		im_category_hierarchy h
	where	c.category_id = h.parent_id and
		h.child_id = p_cat and
		(c.enabled_p = 't' OR c.enabled_p is NULL);

	RETURN v_cat;
end;$body$ language 'plpgsql';


