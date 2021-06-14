-- upgrade-3.4.0.5.0-3.4.0.5.1.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.5.1-3.4.0.5.2.sql','');


-- SELECT im_component_plugin__new (
-- 		null,				-- plugin_id
-- 		'im_component_plugin',		-- object_type
-- 		now(),				-- creation_date
-- 		null,				-- creation_user
-- 		null,				-- creation_ip
-- 		null,				-- context_id
-- 		'Home Hello World',		-- plugin_name
-- 		'intranet-core',		-- package_name
-- 		'left',				-- location
-- 		'/intranet/index',		-- page_url
-- 		null,				-- view_name
-- 		900,				-- sort_order
-- 		'im_component_includelet -params {p1 pv1 p2 pv2} -vars {start_idx status_id}'
-- );

