-- upgrade-4.0.3.0.5-4.0.3.0.6.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.0.5-4.0.3.0.6.sql','');



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




