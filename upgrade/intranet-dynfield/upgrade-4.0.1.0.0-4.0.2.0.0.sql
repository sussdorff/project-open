-- upgrade-4.0.1.0.0-4.0.2.0.0.sql

SELECT acs_log__debug('/packages/intranet-dynfield/sql/postgresql/upgrade/upgrade-4.0.1.0.0-4.0.2.0.0.sql','');

select im_dynfield_widget__new (
	null,			-- widget_id
	'im_dynfield_widget',	-- object_type
	now(),			-- creation_date
	null,			-- creation_user
	null,			-- creation_ip	
	null,			-- context_id
	'timestamp',		-- widget_name
	'Timestamp',		-- pretty_name
	'Timestamp',		-- pretty_plural
	10007,			-- storage_type_id
	'date',			-- acs_datatype
	'date',			-- widget
	'timestamptz',		-- sql_datatype
	'{format "YYYY-MM-DD HH24:MI"} {after_html {<input type="button" style="height:20px; width:20px; background: url(''/resources/acs-templating/calendar.gif'');" onclick ="return showCalendarWithDateWidget(''$attribute_name'', ''y-m-d'');" >}}'
);

