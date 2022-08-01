-- upgrade-4.0.3.0.7-4.0.3.0.8.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.0.7-4.0.3.0.8.sql','');


-- -----------------------------------------------------
-- Consistency Checks
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
	from im_menus where label=''admin'';

	v_menu := im_menu__new (
		null,				-- p_menu_id
		''im_menu'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-core'',		-- package_name
		''admin_consistency_check'',	-- label
		''Consistency Checks'',		-- name
		''/acs-admin/auth/index'',	-- url
		650,				-- sort_order
		v_admin_menu,			-- parent_menu_id
		null				-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_admins, ''read'');
	return 0;
end;' language 'plpgsql';
select inline_1 ();
drop function inline_1();



-- fix missing image on menus
update	im_menus 
set	menu_gif_small = 'arrow_right'
where	menu_gif_small is null and
	label like 'admin_%';




-- Set sort_orders
--

update im_menus set sort_order =  100, menu_gif_small = 'arrow_right' where label = 'admin_home';
update im_menus set sort_order =  200, menu_gif_small = 'arrow_right' where label = 'openacs_api_doc';
update im_menus set sort_order =  300, menu_gif_small = 'arrow_right' where label = 'admin_auth_authorities';
update im_menus set sort_order =  400, menu_gif_small = 'arrow_right' where label = 'admin_backup';
update im_menus set sort_order =  450, menu_gif_small = 'arrow_right' where label = 'admin_flush';
update im_menus set sort_order =  500, menu_gif_small = 'arrow_right' where label = 'openacs_cache';
update im_menus set sort_order =  600, menu_gif_small = 'arrow_right' where label = 'admin_categories';
update im_menus set sort_order =  650, menu_gif_small = 'arrow_right' where label = 'admin_consistency_check';
update im_menus set sort_order =  700, menu_gif_small = 'arrow_right' where label = 'admin_cost_centers';
update im_menus set sort_order =  800, menu_gif_small = 'arrow_right' where label = 'admin_cost_center_permissions';
update im_menus set sort_order =  900, menu_gif_small = 'arrow_right' where label = 'openacs_developer';
update im_menus set sort_order = 1000, menu_gif_small = 'arrow_right' where label = 'dynfield_admin';
update im_menus set sort_order = 1100, menu_gif_small = 'arrow_right' where label = 'admin_dynview';
update im_menus set sort_order = 1200, menu_gif_small = 'arrow_right' where label = 'admin_exchange_rates';
update im_menus set sort_order = 1400, menu_gif_small = 'arrow_right' where label = 'openacs_shell';
update im_menus set sort_order = 1500, menu_gif_small = 'arrow_right' where label = 'openacs_auth';
update im_menus set sort_order = 1600, menu_gif_small = 'arrow_right' where label = 'openacs_l10n';
update im_menus set sort_order = 1650, menu_gif_small = 'arrow_right' where label = 'mail_import';
update im_menus set sort_order = 1700, menu_gif_small = 'arrow_right' where label = 'material';
update im_menus set sort_order = 1800, menu_gif_small = 'arrow_right' where label = 'admin_menus';
update im_menus set sort_order = 1900, menu_gif_small = 'arrow_right' where label = 'admin_packages';
update im_menus set sort_order = 2000, menu_gif_small = 'arrow_right' where label = 'admin_parameters';
update im_menus set sort_order = 2100, menu_gif_small = 'arrow_right' where label = 'admin_components';
update im_menus set sort_order = 2300, menu_gif_small = 'arrow_right' where label = 'openacs_restart_server';
update im_menus set sort_order = 2400, menu_gif_small = 'arrow_right' where label = 'openacs_ds';
update im_menus set sort_order = 2500, menu_gif_small = 'arrow_right' where label = 'admin_survsimp';
update im_menus set sort_order = 2600, menu_gif_small = 'arrow_right' where label = 'openacs_sitemap';
update im_menus set sort_order = 2700, menu_gif_small = 'arrow_right' where label = 'software_updates';
update im_menus set sort_order = 2800, menu_gif_small = 'arrow_right' where label = 'admin_sysconfig';
update im_menus set sort_order = 2850, menu_gif_small = 'arrow_right' where label = 'update_server';
update im_menus set sort_order = 2900, menu_gif_small = 'arrow_right' where label = 'admin_user_exits';
update im_menus set sort_order = 3000, menu_gif_small = 'arrow_right' where label = 'admin_usermatrix';
update im_menus set sort_order = 3050, menu_gif_small = 'arrow_right' where label = 'admin_profiles';
update im_menus set sort_order = 3100, menu_gif_small = 'arrow_right' where label = 'admin_workflow';

update im_dynfield_attributes
set also_hard_coded_p = 't'
where acs_attribute_id in (
	select	attribute_id
	from	acs_attributes
	where	object_type = 'im_project' and
		attribute_name in (
'end_date', 
'project_budget_hours', 
'company_id', 
'description', 
'note', 
'on_track_status_id', 
'parent_id', 
'percent_completed', 
'project_budget', 
'project_budget_currency', 
'project_lead_id', 
'project_name', 
'project_nr', 
'project_path', 
'project_status_id', 
'project_type_id'
		)
	)
;


-- Determine the message string for (locale, package_key, message_key):
create or replace function acs_lang_lookup_message (text, text, text) returns text as $body$
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
	where	(message_key = p_message_key OR message_key = replace(p_message_key, ' ', '_'))
		and package_key = p_package_key
		and locale = p_locale
	LIMIT 1;
	IF v_message is not null THEN return v_message; END IF;

	-- --------------------------------------------
	-- Partial locale - lookup complete one
	v_locale := substring(p_locale from 1 for 2);

	select	locale into v_locale
	from	ad_locales
	where	language = v_locale
		and enabled_p = 't'
		and (default_p = 't' or
		(select count(*) from ad_locales where language = v_locale) = 1);

	select	message into v_message
	from	lang_messages
	where	(message_key = p_message_key OR message_key = replace(p_message_key, ' ', '_'))
		and package_key = p_package_key
		and locale = v_locale
	LIMIT 1;
	IF v_message is not null THEN return v_message; END IF;

	-- --------------------------------------------
	-- Try System Locale
	select	package_id into	v_acs_lang_package_id
	from	apm_packages
	where	package_key = 'acs-lang';
	v_locale := apm__get_value (v_acs_lang_package_id, 'SiteWideLocale');

	select	message into v_message
	from	lang_messages
	where	(message_key = p_message_key OR message_key = replace(p_message_key, ' ', '_'))
		and package_key = p_package_key
		and locale = v_locale
	LIMIT 1;
	IF v_message is not null THEN return v_message; END IF;

	-- --------------------------------------------
	-- Try with English...
	v_locale := 'en_US';
	select	message into v_message
	from	lang_messages
	where	(message_key = p_message_key OR message_key = replace(p_message_key, ' ', '_'))
		and package_key = p_package_key
		and locale = v_locale
	LIMIT 1;
	IF v_message is not null THEN return v_message; END IF;

	-- --------------------------------------------
	-- Nothing found...
	v_message := 'MISSING ' || p_locale || ' TRANSLATION for ' || p_package_key || '.' || p_message_key;
	return v_message;	

end;$body$ language 'plpgsql';

create or replace function inline_0 ()
returns integer as $body$
declare
        v_count  integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = 'im_biz_object_members' and lower(column_name) = 'skill_profile_rel_id';
        IF v_count = 0 THEN
                alter table im_biz_object_members
		add column skill_profile_rel_id integer
		constraint im_biz_object_members_skill_profile_rel_fk
		references im_biz_object_members;
        END IF;

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




-- Return a TCL list of the member_ids of the members of a
-- business object.
create or replace function im_biz_object_member__list (integer)
returns varchar as $body$
DECLARE
        p_object_id     alias for $1;
        v_members       varchar;
        row             record;
BEGIN
        v_members := '';
        FOR row IN
                select  r.rel_id,
                        r.object_id_two as party_id,
                        coalesce(bom.object_role_id::varchar, '""') as role_id,
                        coalesce(bom.percentage::varchar, '""') as percentage
                from    acs_rels r,
                        im_biz_object_members bom
                where   r.rel_id = bom.rel_id and
                        r.object_id_one = p_object_id
                order by party_id
        LOOP
                IF '' != v_members THEN v_members := v_members || ' '; END IF;
                v_members := v_members || '{' || row.party_id || ' ' || row.role_id || ' ' || row.percentage || ' ' || row.rel_id || '}';
        END LOOP;

        return v_members;
end;$body$ language 'plpgsql';

