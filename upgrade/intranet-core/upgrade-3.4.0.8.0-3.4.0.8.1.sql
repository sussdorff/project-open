-- upgrade-3.4.0.8.0-3.4.0.8.1.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.8.0-3.4.0.8.1.sql','');

-- In some installations im_dynfield_attributes::also_hard_coded_p is missing, even though it's part of the install script

create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = ''im_dynfield_attributes'' and lower(column_name) = ''also_hard_coded_p'';
        IF v_count > 0 THEN return 1; END IF;

        alter table im_dynfield_attributes add also_hard_coded_p char(1) default ''f'';
	alter table im_dynfield_attributes add constraint im_dynfield_attributes_also_hard_coded_ch check (also_hard_coded_p in (''t'',''f''));

        RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


-- Disable "Active or Potential" company status
update im_categories set enabled_p = 'f' where category_id = 40;


-- Beautify object type names
update acs_object_types set pretty_name = 'Employee Rel' where object_type = 'im_company_employee_rel';
update acs_object_types set pretty_name = 'Key Account Rel' where object_type = 'im_key_account_rel';


-- Add name method to objects
update acs_object_types set name_method = 'im_name_from_user_id' where object_type = 'user';
update acs_object_types set name_method = 'im_name_from_user_id' where object_type = 'im_gantt_person';
update acs_object_types set name_method = 'im_cost__name' where object_type = 'im_investment';


-- Fix object metadata
update acs_object_types set id_column = 'employee_rel_id' where object_type = 'im_company_employee_rel';
update acs_object_types set id_column = 'topic_id' where object_type = 'im_forum_topic';
update acs_object_types set id_column = 'file_id' where object_type = 'im_fs_file';




-- fix im_forum_topic__name
create or replace function im_forum_topic__name(integer)
returns varchar as '
DECLARE
        p_topic_id               alias for $1;
        v_name                  varchar;
BEGIN
        select  substring(topic_name for 30)
        into    v_name
        from    im_forum_topics
        where   topic_id = p_topic_id;

        return v_name;
end;' language 'plpgsql';



-----------------------------------------------------------
-- Store information about the open/closed status of 
-- hierarchical business objects including projects etc.
--

-- Store the o=open/c=closed status for business objects
-- at certain page URLs.
--


create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = ''im_biz_object_tree_status'';
	IF v_count > 0 THEN return 1; END IF;

	CREATE TABLE im_biz_object_tree_status (
			object_id	integer
					constraint im_biz_object_tree_status_object_nn 
					not null
					constraint im_biz_object_tree_status_object_fk
					references acs_objects on delete cascade,
			user_id		integer
					constraint im_biz_object_tree_status_user_nn 
					not null
					constraint im_biz_object_tree_status_user_fk
					references persons on delete cascade,
			page_url	text
					constraint im_biz_object_tree_status_page_nn 
					not null,
	
			open_p		char(1)
					constraint im_biz_object_tree_status_open_ck
					CHECK (open_p = ''o''::bpchar OR open_p = ''c''::bpchar),
			last_modified	timestamptz,
	
		primary key  (object_id, user_id, page_url)
	);

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


-----------------------------------------------------------

create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = ''im_projects'' and lower(column_name) = ''presales_probability'';
	IF v_count > 0 THEN return 1; END IF;

	alter table im_projects add presales_probability numeric(5,2);
	alter table im_projects add presales_value numeric(12,2);

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



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





-- Added from /intranet-dynfield/sql/postgresql/upgrade/upgrade-3.4.0.4.0-3.4.0.5.0.sql to ensure correct version of im_dynfield_attribute_new (...) 
-- do it the hard way (?!?)
delete from pg_proc where proname = 'im_dynfield_attribute_new';

-- Added from /intranet-dynfield/sql/postgresql/upgrade/upgrade-3.4.0.4.0-3.4.0.5.0.sql to ensure correct version of im_dynfield_attribute_new (...)
CREATE OR REPLACE FUNCTION im_dynfield_attribute_new (
        varchar, varchar, varchar, varchar, varchar, char(1), integer, char(1)
) RETURNS integer as '
DECLARE
        p_object_type           alias for $1;
        p_column_name           alias for $2;
        p_pretty_name           alias for $3;
        p_widget_name           alias for $4;
        p_datatype              alias for $5;
        p_required_p            alias for $6;
        p_pos_y                 alias for $7;
        p_also_hard_coded_p     alias for $8;

        v_dynfield_id           integer;
        v_widget_id             integer;
        v_type_category         varchar;
        row                     RECORD;
        v_count                 integer;
        v_min_n_value           integer;
BEGIN
        select  widget_id into v_widget_id from im_dynfield_widgets
        where   widget_name = p_widget_name;
        IF v_widget_id is null THEN return 1; END IF;

        select  count(*) from im_dynfield_attributes into v_count
        where   acs_attribute_id in (
                        select  attribute_id
                        from    acs_attributes
                        where   attribute_name = p_column_name and
                                object_type = p_object_type
                );
        IF v_count > 0 THEN return 1; END IF;

        v_min_n_value := 0;
        IF p_required_p = ''t'' THEN  v_min_n_value := 1; END IF;

        v_dynfield_id := im_dynfield_attribute__new (
                null, ''im_dynfield_attribute'', now(), 0, ''0.0.0.0'', null,
                p_object_type, p_column_name, v_min_n_value, 1, null,
                p_datatype, p_pretty_name, p_pretty_name, p_widget_name,
                ''f'', ''f''
        );

        update im_dynfield_attributes set also_hard_coded_p = p_also_hard_coded_p
        where attribute_id = v_dynfield_id;

        insert into im_dynfield_layout (
                attribute_id, page_url, pos_y, label_style
        ) values (
                v_dynfield_id, ''default'', p_pos_y, ''plain''
        );

        -- set all im_dynfield_type_attribute_map to "edit"
        select type_category_type into v_type_category from acs_object_types
        where object_type = p_object_type;
        FOR row IN
                select  category_id
                from    im_categories
                where   category_type = v_type_category
        LOOP
                select  count(*) into v_count from im_dynfield_type_attribute_map
                where   object_type_id = row.category_id and attribute_id = v_dynfield_id;
                IF 0 = v_count THEN
                        insert into im_dynfield_type_attribute_map (
                                attribute_id, object_type_id, display_mode
                        ) values (
                                v_dynfield_id, row.category_id, ''edit''
                        );
                END IF;
        END LOOP;

        PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name=''Employees''), ''read'');
        PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name=''Employees''), ''write'');
        PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name=''Customers''), ''read'');
        PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name=''Customers''), ''write'');
        PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name=''Freelancers''), ''read'');
        PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name=''Freelancers''), ''write'');

        RETURN v_dynfield_id;
END;' language 'plpgsql';

-- Shortcut function
-- Added from /intranet-dynfield/sql/postgresql/upgrade/upgrade-3.4.0.4.0-3.4.0.5.0.sql to ensure correct version of im_dynfield_attribute_new (...)
CREATE OR REPLACE FUNCTION im_dynfield_attribute_new (
        varchar, varchar, varchar, varchar, varchar, char(1)
) RETURNS integer as '
BEGIN
        RETURN im_dynfield_attribute_new($1,$2,$3,$4,$5,$6,null,''f'');
END;' language 'plpgsql';



SELECT im_dynfield_attribute_new ('im_project', 'presales_probability', 'Presales Probability', 'integer', 'integer', 'f');
SELECT im_dynfield_attribute_new ('im_project', 'presales_value', 'Presales Value', 'integer', 'integer', 'f');



-- reported_days_cache for controlling per day.
--
create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = ''im_projects'' and lower(column_name) = ''reported_days_cache'';
	IF v_count > 0 THEN return 1; END IF;

	alter table im_projects add reported_days_cache numeric(12,2) default 0;

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




-- -------------------------------------------------------
-- Setup "templates" menu 
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
		''admin_templates'',		-- label
		''Templates'',			-- name
		''/intranet/admin/templates/'',	-- url
		2601,				-- sort_order
		v_main_menu,			-- parent_menu_id
		''0''				-- p_visible_tcl
	);

	update im_menus set menu_gif_small = ''arrow_right''
	where menu_id = v_admin_menu;

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



