-- upgrade-3.2.7.0.0-3.2.8.0.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.2.7.0.0-3.2.8.0.0.sql','');

\i upgrade-3.0.0.0.first.sql


----------------------------------------------------------------
-- percentage column for im_biz_object_members
--
create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = ''im_biz_object_members'' and lower(column_name) = ''percentage'';
        IF 0 != v_count THEN return 0; END IF;

	ALTER TABLE im_biz_object_members ADD column percentage numeric(8,2);
	ALTER TABLE im_biz_object_members ALTER column percentage set default 100;

        return 1;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();





create or replace function im_day_enumerator (
        date, date
) returns setof date as '
declare
        p_start_date            alias for $1;
        p_end_date              alias for $2;
        v_date                  date;
BEGIN
        v_date := p_start_date;
        WHILE (v_date < p_end_date) LOOP
                RETURN NEXT v_date;
                v_date := v_date + 1;
        END LOOP;
        RETURN;
end;' language 'plpgsql';






create or replace function im_day_enumerator_weekdays (
        date, date
) returns setof date as '
declare
        p_start_date            alias for $1;
        p_end_date              alias for $2;
        v_date                  date;
        v_weekday               integer;
BEGIN
        v_date := p_start_date;
        WHILE (v_date < p_end_date) LOOP

                v_weekday := to_char(v_date, ''D'');
                IF v_weekday != 1 AND v_weekday != 7 THEN
                        RETURN NEXT v_date;
                END IF;
                v_date := v_date + 1;
        END LOOP;
        RETURN;
end;' language 'plpgsql';



-- Delete the customer_project_nr DynField.
-- The DynField has become part of the static Project fields.

delete from im_dynfield_attributes
where acs_attribute_id in (
		select	attribute_id 
		from
			acs_attributes 
		where 
			attribute_name = 'company_project_nr' 
			and object_type = 'im_project'
	)
;


SELECT im_component_plugin__new (
		null,					-- plugin_id
		'im_component_plugin',			-- object_type
		now(),					-- creation_date
	        null,                   	        -- creation_user
	        null,                   	        -- creation_ip
	        null,                   	        -- context_id
		'Task Members',				-- plugin_name
		'intranet',				-- package_name
		'right',				-- location
		'/intranet-timesheet2-tasks/new',	-- page_url
		null,					-- view_name	
		20,					-- sort_order
		'im_group_member_component $task_id $current_user_id $user_admin_p $return_url "" "" 1'
);




-- Allow for "Full-Member" membership of a timesheet-task
create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
        select	count(*) into v_count from im_biz_object_role_map
        where	acs_object_type = ''im_timesheet_task''
		and object_type_id = 85
		and object_role_id = 1300;

        IF 0 = v_count THEN 
		insert into im_biz_object_role_map values (''im_timesheet_task'',85,1300);
	END IF;

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



-- Create an index on tree_sortkey to speed up child queries
create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
        select count(*) into v_count from pg_class 
	where lower(relname) = ''im_project_treesort_idx'';

        IF 0 = v_count THEN 
		create index im_project_treesort_idx on im_projects(tree_sortkey);
	END IF;

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();





---------------------------------------------------------
-- Determine the default locale for the user
create or replace function acs_lang_get_locale_for_user (integer) returns text as '
declare
	p_user_id	alias for $1;

	v_workflow_key		varchar(100);
	v_transition_key	varchar(100);
	v_acs_lang_package_id	integer;
	v_locale		varchar(10);
begin
	-- Get the users local from preferences
	select	locale into v_locale
	from	user_preferences
	where	user_id = p_user_id;

	-- Get users locale from global default
	IF v_locale is null THEN
		select	package_id
		into	v_acs_lang_package_id
		from	apm_packages
		where	package_key = ''acs-lang'';

		v_locale := apm__get_value (v_acs_lang_package_id, ''SiteWideLocale'');
	END IF;

	-- Partial locale - lookup complete one
	IF length(v_locale) = 2 THEN
		select	locale into v_locale
		from	ad_locales
		where	language = v_locale
			and enabled_p = ''t''
			and (default_p = ''t''
			   or (select count(*) from ad_locales where language = v_locale) = 1
			);
	END IF;

	-- Default: English
	IF v_locale is null THEN
		v_locale := ''en_US'';
	END IF;

	return v_locale;
end;' language 'plpgsql';


-- Determine the message string for (locale, package_key, message_key):
create or replace function acs_lang_lookup_message (text, text, text) returns text as '
declare
	p_locale		alias for $1;
	p_package_key		alias for $2;
	p_message_key		alias for $3;
	v_message		text;
	v_locale		text;
	v_acs_lang_package_id	integer;
begin
	-- --------------------------------------------
	-- Check full locale
	select	message into v_message
	from	lang_messages
	where	message_key = p_message_key
		and package_key = p_package_key
		and locale = p_locale;
	IF v_message is not null THEN return v_message; END IF;

	-- --------------------------------------------
	-- Partial locale - lookup complete one
	v_locale := substring(p_locale from 1 for 2);

	select	locale into v_locale
	from	ad_locales
	where	language = v_locale
		and enabled_p = ''t''
		and (default_p = ''t'' or
		(select count(*) from ad_locales where language = v_locale) = 1);

	select	message into v_message
	from	lang_messages
	where	message_key = p_message_key
		and package_key = p_package_key
		and locale = v_locale;
	IF v_message is not null THEN return v_message; END IF;

	-- --------------------------------------------
	-- Try System Locale
	select	package_id into	v_acs_lang_package_id
	from	apm_packages
	where	package_key = ''acs-lang'';
	v_locale := apm__get_value (v_acs_lang_package_id, ''SiteWideLocale'');

	select	message into v_message
	from	lang_messages
	where	message_key = p_message_key
		and package_key = p_package_key
		and locale = v_locale;
	IF v_message is not null THEN return v_message; END IF;

	-- --------------------------------------------
	-- Try with English...
	v_locale := ''en_US'';
	select	message into v_message
	from	lang_messages
	where	message_key = p_message_key
		and package_key = p_package_key
		and locale = v_locale;
	IF v_message is not null THEN return v_message; END IF;

	-- --------------------------------------------
	-- Nothing found...
	v_message := ''MISSING '' || p_locale || '' TRANSLATION for '' || p_package_key || ''.'' || p_message_key;
	return v_message;	

end;' language 'plpgsql';





-- ------------------------------------------------------------
-- Project Membership Packages
-- ------------------------------------------------------------

-- New version of the PlPg/SQL routine with percentage parameter
--
create or replace function im_biz_object_member__new (
integer, varchar, integer, integer, integer, numeric, integer, varchar)
returns integer as '
DECLARE
	p_rel_id		alias for $1;	-- null
	p_rel_type		alias for $2;	-- im_biz_object_member
	p_object_id		alias for $3;	-- object_id_one
	p_user_id		alias for $4;	-- object_id_two
	p_object_role_id	alias for $5;	-- type of relationship
	p_percentage		alias for $6;	-- percentage of assignation
	p_creation_user		alias for $7;	-- null
	p_creation_ip		alias for $8;	-- null

	v_rel_id		integer;
	v_count			integer;
BEGIN
	select	count(*) into v_count
	from	acs_rels
	where	object_id_one = p_object_id
		and object_id_two = p_user_id;

	IF v_count > 0 THEN 
		-- Return the lowest rel_id (might be several?)
		select	min(rel_id) into v_rel_id
		from	acs_rels
		where	object_id_one = p_object_id
			and object_id_two = p_user_id;

		return v_rel_id;
	END IF;

	v_rel_id := acs_rel__new (
		p_rel_id,
		p_rel_type,	
		p_object_id,
		p_user_id,
		p_object_id,
		p_creation_user,
		p_creation_ip
	);

	insert into im_biz_object_members (
	       rel_id, object_role_id, percentage
	) values (
	       v_rel_id, p_object_role_id, p_percentage
	);

	return v_rel_id;
end;' language 'plpgsql';


-- Downward compatibility - offers the same API as before
-- with percentage = null
create or replace function im_biz_object_member__new (
integer, varchar, integer, integer, integer, integer, varchar)
returns integer as '
DECLARE
	p_rel_id		alias for $1;	-- null
	p_rel_type		alias for $2;	-- im_biz_object_member
	p_object_id		alias for $3;	-- object_id_one
	p_user_id		alias for $4;	-- object_id_two
	p_object_role_id	alias for $5;	-- type of relationship
	p_creation_user		alias for $6;	-- null
	p_creation_ip		alias for $7;	-- null
BEGIN
	return im_biz_object_member__new (
		p_rel_id, 
		p_rel_type, 
		p_object_id, 
		p_user_id, 
		p_object_role_id, 
		null, 
		p_creation_user, 
		p_creation_ip
	);
end;' language 'plpgsql';



