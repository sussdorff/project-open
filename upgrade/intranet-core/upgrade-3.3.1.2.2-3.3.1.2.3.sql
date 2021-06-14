-- upgrade-3.3.1.2.2-3.3.1.2.3.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.3.1.2.2-3.3.1.2.3.sql','');

\i upgrade-3.0.0.0.first.sql


-- ProjectOpen News Component
SELECT  im_component_plugin__new (
	null,				-- plugin_id
	'im_component_plugin',		-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id
	'Home &#93;po&#91; News',	-- plugin_name
	'intranet',			-- package_name
	'right',			-- location
	'/intranet/index',		-- page_url
	null,				-- view_name
	115,				-- sort_order
	'im_home_news_component'	-- component_tcl
);

