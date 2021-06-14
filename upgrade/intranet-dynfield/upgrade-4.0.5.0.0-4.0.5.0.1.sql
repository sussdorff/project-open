-- upgrade-4.0.5.0.0-4.0.5.0.1.sql

SELECT acs_log__debug('/packages/intranet-dynfield/sql/postgresql/upgrade/upgrade-4.0.5.0.0-4.0.5.0.1.sql','');

alter table im_dynfield_widgets alter column widget type text;

-- Add "Event" object type
SELECT im_menu__new (
	null,							-- p_menu_id
	'im_menu',						-- object_type
	now(),							-- creation_date
	null,							-- creation_user
	null,							-- creation_ip
	null,							-- context_id
	'intranet-dynfield',					-- package_name
	'dynfield_otype_events',				-- label
	'Event',						-- name
	'/intranet-dynfield/object-type?object_type=im_event',	-- url
	118,							-- sort_order
	(select menu_id from im_menus where label = 'dynfield_otype'),	-- parent_menu_id
	null							-- p_visible_tcl
);

