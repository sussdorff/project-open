-- upgrade-5.0.2.3.5-5.0.2.3.6.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.2.3.5-5.0.2.3.6.sql','');




update im_component_plugins
set component_tcl = 
	'im_dashboard_histogram_sql -diagram_width 400 -sql "
		select	im_lang_lookup_category(''[ad_conn locale]'', p.project_status_id) as project_status,
		        sum(coalesce(presales_probability,project_budget,0) * coalesce(presales_value,0)) as value
		from	im_projects p
		where	p.parent_id is null and
			p.project_status_id not in (select * from im_sub_categories(81))
		group by project_status_id
		order by project_status
	"'
where package_name = 'intranet-reporting-dashboard' and plugin_name = 'Pre-Sales Queue';



update im_component_plugins
set component_tcl = 
	'im_dashboard_histogram_sql -diagram_width 400 -sql "
		select	im_lang_lookup_category(''[ad_conn locale]'', p.project_status_id) as project_status,
		        count(*) as cnt
		from	im_projects p
		where	p.parent_id is null and
			p.project_status_id not in (select * from im_sub_categories(81))
		group by project_status_id
		order by project_status
	"'
where package_name = 'intranet-reporting-dashboard' and plugin_name = 'Projects by Status';



-- ------------------------------------------------------------------
-- PL/SQL version of lang::message::lookup locale key default
-- ------------------------------------------------------------------

create or replace function im_lang_lookup(text, text, text)
returns varchar as $body$
DECLARE
	p_locale	alias for $1;
	p_package_key	alias for $2;
	p_default	alias for $3;

	v_result	text;
	v_package	text;
	v_key		text;
BEGIN
	v_package := substring(p_package_key from '^([a-z\-]+)');
	v_key := substring(p_package_key from '^[a-z\-]+\.(.*)');
	v_key := regexp_replace(v_key, '[^a-zA-z]', '_');

	select	 message into v_result from lang_messages
	where	 locale = p_locale and package_key = v_package and message_key = v_key;
	IF v_result is not null THEN return v_result; END IF;

	select	 message into v_result from lang_messages
	where	 locale = 'en_US' and package_key = v_package and message_key = v_key;
	IF v_result is not null THEN return v_result; END IF;
	
	return p_default;
END;$body$ language 'plpgsql';


create or replace function im_lang_lookup_category(text, integer)
returns varchar as $body$
DECLARE
	p_locale	alias for $1;
	p_category_id	alias for $2;

	v_default	text;
BEGIN
	v_default = im_category_from_id(p_category_id);
	return im_lang_lookup(p_locale, 'intranet-core.'||v_default, v_default);
END;$body$ language 'plpgsql';

