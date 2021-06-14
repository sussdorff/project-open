-- upgrade-4.0.3.3.6-4.0.3.3.7.sql

SELECT acs_log__debug('/packages/intranet-planning/sql/postgresql/upgrade/upgrade-4.0.3.3.6-4.0.3.3.7.sql','');

-- Create a new object type.
-- This statement only creates an entry in acs_object_types with some
-- meta-information (table name, ... as specified below) about the new 
-- object. 
-- Please note that this is quite different from creating a new object
-- class in Java or other languages.

SELECT acs_object_type__create_type (
	'im_planning_item',			-- object_type - only lower case letters and "_"
	'Planning Item',			-- pretty_name - Human readable name
	'Planning Items',			-- pretty_plural - Human readable plural
	'acs_object',				-- supertype - "acs_object" is topmost object type.
	'im_planning_items',			-- table_name - where to store data for this object?
	'item_id',				-- id_column - where to store object_id in the table?
	'intranet-planning',			-- package_name - name of this package
	'f',					-- abstract_p - abstract class or not
	null,					-- type_extension_table
	'im_planning_item__name'		-- name_method - a PL/SQL procedure that
						-- returns the name of the object.
);

-- Add additional meta information to allow DynFields to extend the im_planning_item object.
update acs_object_types set
        status_type_table = 'im_planning_items',	-- which table contains the status_id field?
        status_column = 'item_status_id',		-- which column contains the status_id field?
        type_column = 'item_type_id'			-- which column contains the type_id field?
where object_type = 'im_planning_item';

-- Object Type Tables contain the lists of all tables (except for
-- acs_objects...) that contain information about an im_planning_item object.
-- This way, developers can add "extension tables" to an object to
-- hold additional DynFields, without changing the program code.
insert into acs_object_type_tables (object_type,table_name,id_column)
values ('im_planning_item', 'im_planning_items', 'item_id');


-- Generic URLs to link to an object of type "im_planning_item".
-- These URLs are used by the Full-Text Search Engine and the Workflow
-- to show links to the object type.
insert into im_biz_object_urls (object_type, url_type, url) values (
'im_planning_item','view','/intranet-planning/new?display_mode=display&item_id=');
insert into im_biz_object_urls (object_type, url_type, url) values (
'im_planning_item','edit','/intranet-planning/new?display_mode=edit&item_id=');


SELECT im_category_new (73005, 'Requested', 'Intranet Planning Status');

-- Type
SELECT im_category_new (73100, 'Revenues', 'Intranet Planning Type');
SELECT im_category_new (73101,'Benefit Estimation','Intranet Planning Type');
SELECT im_category_new (73102, 'Costs', 'Intranet Planning Type');
SELECT im_category_new (73103,'Resources','Intranet Planning Type');
SELECT im_category_new (73121,'Investment Cost','Intranet Planning Type');
SELECT im_category_new (73122,'One Time Cost','Intranet Planning Type');
SELECT im_category_new (73123,'Repeating Cost','Intranet Planning Type');


SELECT im_component_plugin__new (null, 'acs_object', now(), null, null, null, 'Project Assignment Component', 'intranet-pmo', 'left', '/intranet/projects/view', null, 10, 'im_project_assignment_component -user_id $user_id -project_id $project_id -return_url $return_url');

-- Set component as readable for employees and poadmins
CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE

	v_object_id	integer;
	v_employees	integer;
	v_poadmins	integer;

BEGIN
	SELECT group_id INTO v_employees FROM groups where group_name = ''P/O Admins'';

	SELECT group_id INTO v_poadmins FROM groups where group_name = ''Employees'';

	SELECT plugin_id INTO v_object_id FROM im_component_plugins WHERE plugin_name = ''Project Assignment Component'' AND page_url = ''/intranet/projects/view'';

	PERFORM im_grant_permission(v_object_id,v_employees,''read'');
	PERFORM im_grant_permission(v_object_id,v_poadmins,''read'');

	
	RETURN 0;

END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();
