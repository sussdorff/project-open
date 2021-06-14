-- 
-- packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.0.6-4.0.3.0.7.sql
-- 
-- Copyright (c) 2011, cognovís GmbH, Hamburg, Germany
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
-- 
-- @author Malte Sussdorff (malte.sussdorff@cognovis.de)
-- @creation-date 2012-03-02
-- @cvs-id $Id$
--

-- upgrade-4.0.3.0.6-4.0.3.0.7.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.0.6-4.0.3.0.7.sql','');

-- Fix the acs_attributes missing table_name for im_project object_type
create or replace function inline_0() 
returns integer as '
BEGIN
       update acs_attributes set table_name = ''im_projects'' 
       where object_type = ''im_project'' and table_name is null;

       return 0;
END;' language 'plpgsql';

SELECT inline_0();

DROP FUNCTION inline_0();


-- Project Hierarchy Component.
-- Update sort order
CREATE OR REPLACE FUNCTION inline_0 () 
RETURNS integer AS '
DECLARE
	v_component_id integer;
BEGIN
	SELECT plugin_id INTO v_component_id 
	FROM im_component_plugins 
	WHERE plugin_name = ''Project Hierarchy''
	AND package_name = ''intranet-core''
	AND page_url = ''/intranet/projects/view'';

	UPDATE im_component_plugins 
	SET location = ''right'', menu_sort_order = 0
	WHERE plugin_id = v_component_id;

	RETURN 0;
END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();



create or replace function im_dynfield_widget__new (
	integer, varchar, timestamptz, integer, varchar, integer,
	varchar, varchar, varchar, integer, varchar, varchar, 
	varchar, varchar, varchar
) returns integer as '
DECLARE
	p_widget_id		alias for $1;
	p_object_type		alias for $2;
	p_creation_date 	alias for $3;
	p_creation_user 	alias for $4;
	p_creation_ip		alias for $5;
	p_context_id		alias for $6;

	p_widget_name		alias for $7;
	p_pretty_name		alias for $8;
	p_pretty_plural		alias for $9;
	p_storage_type_id	alias for $10;
	p_acs_datatype		alias for $11;
	p_widget		alias for $12;
	p_sql_datatype		alias for $13;
	p_parameters		alias for $14;
	p_deref_plpgsql_function alias for $15;

	v_widget_id		integer;
BEGIN
	select widget_id into v_widget_id from im_dynfield_widgets
	where widget_name = p_widget_name;
	if v_widget_id is not null then return v_widget_id; end if;

	v_widget_id := acs_object__new (
		p_widget_id,
		p_object_type,
		p_creation_date,
		p_creation_user,
		p_creation_ip,
		p_context_id
	);

	insert into im_dynfield_widgets (
		widget_id, widget_name, pretty_name, pretty_plural,
		storage_type_id, acs_datatype, widget, sql_datatype, parameters, deref_plpgsql_function
	) values (
		v_widget_id, p_widget_name, p_pretty_name, p_pretty_plural,
		p_storage_type_id, p_acs_datatype, p_widget, p_sql_datatype, p_parameters, p_deref_plpgsql_function
	);
	return v_widget_id;
end;' language 'plpgsql';

create or replace function im_dynfield_widget__del (integer) returns integer as '
DECLARE
	p_widget_id		alias for $1;
BEGIN
	-- Erase the im_dynfield_widgets item associated with the id
	delete from im_dynfield_widgets
	where widget_id = p_widget_id;

	-- Erase all the privileges
	delete from acs_permissions
	where object_id = p_widget_id;

	PERFORM acs_object__delete(p_widget_id);
	return 0;
end;' language 'plpgsql';

SELECT im_dynfield_widget__new (
		null,			-- widget_id
		'im_dynfield_widget',	-- object_type
		now(),			-- creation_date
		null,			-- creation_user
		null,			-- creation_ip
		null,			-- context_id
		'customers',		-- widget_name
		'#intranet-core.Customer#',	-- pretty_name
		'#intranet-core.Customers#',	-- pretty_plural
		10007,			-- storage_type_id
		'integer',		-- acs_datatype
		'generic_tcl',		-- widget
		'integer',		-- sql_datatype
		'{custom {tcl {im_company_options -include_empty_p 0 -status "Active or Potential" -type "CustOrIntl"} switch_p 1}}', 
		'im_name_from_id'
);


SELECT im_dynfield_widget__new (
		null,			-- widget_id
		'im_dynfield_widget',	-- object_type
		now(),			-- creation_date
		null,			-- creation_user
		null,			-- creation_ip
		null,			-- context_id
		'project_leads',		-- widget_name
		'#intranet-core.Project_Manager#',	-- pretty_name
		'#intranet-core.Project_Managers#',	-- pretty_plural
		10007,			-- storage_type_id
		'integer',		-- acs_datatype
		'generic_tcl',		-- widget
		'integer',		-- sql_datatype
		'{custom {tcl {im_project_manager_options -include_empty 0} switch_p 1}}', -- -
		'im_name_from_id'
);

SELECT im_dynfield_widget__new (
		null,			-- widget_id
		'im_dynfield_widget',	-- object_type
		now(),			-- creation_date
		null,			-- creation_user
		null,			-- creation_ip
		null,			-- context_id
		'project_parent_options',		-- widget_name
		'Parent Project List',	-- pretty_name
		'Parent Project List',	-- pretty_plural
		10007,			-- storage_type_id
		'integer',		-- acs_datatype
		'generic_tcl',		-- widget
		'integer',		-- sql_datatype
		'{custom {tcl {im_project_options -exclude_subprojects_p 0 -exclude_status_id [im_project_status_closed] -project_id $super_project_id} switch_p 1 global_var super_project_id}}', -- -
		'im_name_from_id'
);

SELECT im_dynfield_widget__new (
		null,			-- widget_id
		'im_dynfield_widget',	-- object_type
		now(),			-- creation_date
		null,			-- creation_user
		null,			-- creation_ip
		null,			-- context_id
		'timestamp',		-- widget_name
		'#intranet-core.Timestamp#',	-- pretty_name
		'#intranet-core.Timestamps#',	-- pretty_plural
		10007,			-- storage_type_id
		'date',		-- acs_datatype
		'date',		-- widget
		'date',		-- sql_datatype
		'{format "YYYY-MM-DD HH24:MM"}', 
		'im_name_from_id'
);

SELECT im_dynfield_widget__new (
		null,			-- widget_id
		'im_dynfield_widget',	-- object_type
		now(),			-- creation_date
		null,			-- creation_user
		null,			-- creation_ip
		null,			-- context_id
		'on_track_status',		-- widget_name
		'#intranet-core.On_Track_Status#',	-- pretty_name
		'#intranet-core.On_Track_Status#',	-- pretty_plural
		10007,			-- storage_type_id
		'integer',		-- acs_datatype
		'im_category_tree',		-- widget
		'integer',		-- sql_datatype
		'{custom {category_type "Intranet Project On Track Status"}}', 
		'im_name_from_id'
);

SELECT im_dynfield_widget__new (
		null,			-- widget_id
		'im_dynfield_widget',	-- object_type
		now(),			-- creation_date
		null,			-- creation_user
		null,			-- creation_ip
		null,			-- context_id
		'percent',		-- widget_name
		'#intranet-core.percent_complete#',	-- pretty_name
		'#intranet-core.percent_complete#',	-- pretty_plural
		10007,			-- storage_type_id
		'float',		-- acs_datatype
		'text',		-- widget
		'float',		-- sql_datatype
		'', 
		'im_percent_from_number'
);


-- project_name
CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN


	SELECT attribute_id INTO v_acs_attribute_id FROM acs_attributes WHERE object_type = ''im_project'' AND attribute_name = ''project_name'';
	
	IF v_acs_attribute_id IS NOT NULL THEN
	   v_attribute_id := im_dynfield_attribute__new_only_dynfield (
	       null,					-- attribute_id
	       ''im_dynfield_attribute'',		-- object_type
	       now(),					-- creation_date
	       null,					-- creation_user
	       null,					-- creation_ip
	       null,					-- context_id	
	       v_acs_attribute_id,			-- acs_attribute_id
	       ''textbox_medium'',			-- widget
	       ''f'',					-- deprecated_p
	       ''t'',					-- already_existed_p
	       null,					-- pos_y
	       ''plain'',				-- label_style
	       ''f'',					-- also_hard_coded_p   
	       ''t''					-- include_in_search_p
	  );
	ELSE
	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''im_project'',			-- object_type
		 ''project_name'',			-- column_name
		 ''#intranet-core.Project_Name#'',	-- pretty_name
		 ''textbox_medium'',			-- widget_name
		 ''string'',				-- acs_datatype
		 ''t'',					-- required_p   
		 1,					-- pos y
		 ''f'',					-- also_hard_coded
		 ''im_projects''			-- table_name
	  );

	END IF;


	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_id NOT IN (100,101) AND category_type = ''Intranet Project Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',''Please enter any suitable name for the project. The name must be unique.'',null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;


	RETURN 0;
END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();

-- project_nr
CREATE OR REPLACE FUNCTION inline_1 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN


	SELECT attribute_id INTO v_acs_attribute_id FROM acs_attributes WHERE object_type = ''im_project'' AND attribute_name = ''project_nr'';
	
	IF v_acs_attribute_id IS NOT NULL THEN
	   v_attribute_id := im_dynfield_attribute__new_only_dynfield (
	       null,					-- attribute_id
	       ''im_dynfield_attribute'',		-- object_type
	       now(),					-- creation_date
	       null,					-- creation_user
	       null,					-- creation_ip
	       null,					-- context_id	
	       v_acs_attribute_id,			-- acs_attribute_id
	       ''textbox_medium'',			-- widget
	       ''f'',					-- deprecated_p
	       ''t'',					-- already_existed_p
	       null,					-- pos_y
	       ''plain'',				-- label_style
	       ''f'',					-- also_hard_coded_p   
	       ''t''					-- include_in_search_p
	  );
	ELSE
	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''im_project'',			-- object_type
		 ''project_nr'',			-- column_name
		 ''#intranet-core.Project_Nr#'',	-- pretty_name
		 ''textbox_medium'',			-- widget_name
		 ''string'',				-- acs_datatype
		 ''t'',					-- required_p   
		 2,					-- pos y
		 ''f'',					-- also_hard_coded
		 ''im_projects''			-- table_name
	  );

	END IF;


	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_id NOT IN (100,101) AND category_type = ''Intranet Project Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',''A project number is composed by 4 digits for the year plus 4 digits for current identification'',null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;


	RETURN 0;
END;' language 'plpgsql';

SELECT inline_1 ();
DROP FUNCTION inline_1 ();


-- parent_id
CREATE OR REPLACE FUNCTION inline_2 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN


	SELECT attribute_id INTO v_acs_attribute_id FROM acs_attributes WHERE object_type = ''im_project'' AND attribute_name = ''parent_id'';
	
	IF v_acs_attribute_id IS NOT NULL THEN
	   v_attribute_id := im_dynfield_attribute__new_only_dynfield (
	       null,					-- attribute_id
	       ''im_dynfield_attribute'',		-- object_type
	       now(),					-- creation_date
	       null,					-- creation_user
	       null,					-- creation_ip
	       null,					-- context_id	
	       v_acs_attribute_id,			-- acs_attribute_id
	       ''project_parent_options'',		-- widget
	       ''f'',					-- deprecated_p
	       ''t'',					-- already_existed_p
	       null,					-- pos_y
	       ''plain'',				-- label_style
	       ''f'',					-- also_hard_coded_p   
	       ''t''					-- include_in_search_p
	  );
	ELSE
	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''im_project'',			-- object_type
		 ''parent_id'',				-- column_name
		 ''#intranet-core.Parent_Project#'',	-- pretty_name
		 ''project_parent_options'',		-- widget_name
		 ''integer'',				-- acs_datatype
		 ''f'',					-- required_p   
		 3,					-- pos y
		 ''f'',					-- also_hard_coded
		 ''im_projects''			-- table_name
	  );

	END IF;


	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_id NOT IN (100,101) AND category_type = ''Intranet Project Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',''Do you want to create a subproject (a project that is part of an other project)? Leave the field blank (-- Please Select --) if you are unsure.'',null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;


	RETURN 0;
END;' language 'plpgsql';

SELECT inline_2 ();
DROP FUNCTION inline_2 ();

-- project_path
CREATE OR REPLACE FUNCTION inline_3 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN


	SELECT attribute_id INTO v_acs_attribute_id FROM acs_attributes WHERE object_type = ''im_project'' AND attribute_name = ''project_path'';
	
	IF v_acs_attribute_id IS NOT NULL THEN
	   v_attribute_id := im_dynfield_attribute__new_only_dynfield (
	       null,					-- attribute_id
	       ''im_dynfield_attribute'',		-- object_type
	       now(),					-- creation_date
	       null,					-- creation_user
	       null,					-- creation_ip
	       null,					-- context_id	
	       v_acs_attribute_id,			-- acs_attribute_id
	       ''textbox_medium'',			-- widget
	       ''f'',					-- deprecated_p
	       ''t'',					-- already_existed_p
	       null,					-- pos_y
	       ''plain'',				-- label_style
	       ''f'',					-- also_hard_coded_p   
	       ''t''					-- include_in_search_p
	  );
	ELSE
	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''im_project'',			-- object_type
		 ''project_path'',			-- column_name
		 ''#intranet-core.Project_Path#'',	-- pretty_name
		 ''textbox_medium'',			-- widget_name
		 ''string'',				-- acs_datatype
		 ''t'',					-- required_p   
		 4,					-- pos y
		 ''f'',					-- also_hard_coded
		 ''im_projects''			-- table_name
	  );

	END IF;


	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_id NOT IN (100,101) AND category_type = ''Intranet Project Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',''An optional full path to the project filestorage'',null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;


	RETURN 0;
END;' language 'plpgsql';

SELECT inline_3 ();
DROP FUNCTION inline_3 ();



-- company_id
CREATE OR REPLACE FUNCTION inline_4 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN


	SELECT attribute_id INTO v_acs_attribute_id FROM acs_attributes WHERE object_type = ''im_project'' AND attribute_name = ''company_id'';
	
	IF v_acs_attribute_id IS NOT NULL THEN
	   v_attribute_id := im_dynfield_attribute__new_only_dynfield (
	       null,					-- attribute_id
	       ''im_dynfield_attribute'',		-- object_type
	       now(),					-- creation_date
	       null,					-- creation_user
	       null,					-- creation_ip
	       null,					-- context_id	
	       v_acs_attribute_id,			-- acs_attribute_id
	       ''customers'',				-- widget
	       ''f'',					-- deprecated_p
	       ''t'',					-- already_existed_p
	       null,					-- pos_y
	       ''plain'',				-- label_style
	       ''f'',					-- also_hard_coded_p   
	       ''t''					-- include_in_search_p
	  );
	ELSE
	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''im_project'',			-- object_type
		 ''company_id'',			-- column_name
		 ''#intranet-core.Company#'',		-- pretty_name
		 ''customers'',				-- widget_name
		 ''integer'',				-- acs_datatype
		 ''t'',					-- required_p   
		 5,					-- pos y
		 ''f'',					-- also_hard_coded
		 ''im_projects''			-- table_name
	  );

	END IF;


	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_id NOT IN (100,101) AND category_type = ''Intranet Project Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',''There is a difference between &quot;Paying Client&quot; and &quot;Final Client&quot;. Here we want to know from whom we are going to receive the money...'',null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;


	RETURN 0;
END;' language 'plpgsql';

SELECT inline_4 ();
DROP FUNCTION inline_4 ();

-- project_lead_id
CREATE OR REPLACE FUNCTION inline_5 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN


	SELECT attribute_id INTO v_acs_attribute_id FROM acs_attributes WHERE object_type = ''im_project'' AND attribute_name = ''project_lead_id'';
	
	IF v_acs_attribute_id IS NOT NULL THEN
	   v_attribute_id := im_dynfield_attribute__new_only_dynfield (
	       null,					-- attribute_id
	       ''im_dynfield_attribute'',		-- object_type
	       now(),					-- creation_date
	       null,					-- creation_user
	       null,					-- creation_ip
	       null,					-- context_id	
	       v_acs_attribute_id,			-- acs_attribute_id
	       ''project_leads'',			-- widget
	       ''f'',					-- deprecated_p
	       ''t'',					-- already_existed_p
	       null,					-- pos_y
	       ''plain'',				-- label_style
	       ''f'',					-- also_hard_coded_p   
	       ''t''					-- include_in_search_p
	  );
	ELSE
	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''im_project'',			-- object_type
		 ''project_lead_id'',			-- column_name
		 ''#intranet-core.Project_Manager#'',	-- pretty_name
		 ''project_leads'',			-- widget_name
		 ''integer'',				-- acs_datatype
		 ''t'',					-- required_p   
		 6,					-- pos y
		 ''f'',					-- also_hard_coded
		 ''im_projects''			-- table_name
	  );

	END IF;


	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_id NOT IN (100,101) AND category_type = ''Intranet Project Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',null,null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;


	RETURN 0;
END;' language 'plpgsql';

SELECT inline_5 ();
DROP FUNCTION inline_5 ();


-- project_type_id
CREATE OR REPLACE FUNCTION inline_6 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN


	SELECT attribute_id INTO v_acs_attribute_id FROM acs_attributes WHERE object_type = ''im_project'' AND attribute_name = ''project_type_id'';
	
	IF v_acs_attribute_id IS NOT NULL THEN
	   v_attribute_id := im_dynfield_attribute__new_only_dynfield (
	       null,					-- attribute_id
	       ''im_dynfield_attribute'',		-- object_type
	       now(),					-- creation_date
	       null,					-- creation_user
	       null,					-- creation_ip
	       null,					-- context_id	
	       v_acs_attribute_id,			-- acs_attribute_id
	       ''project_type'',			-- widget
	       ''f'',					-- deprecated_p
	       ''t'',					-- already_existed_p
	       null,					-- pos_y
	       ''plain'',				-- label_style
	       ''f'',					-- also_hard_coded_p   
	       ''t''					-- include_in_search_p
	  );
	ELSE
	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''im_project'',			-- object_type
		 ''project_type_id'',			-- column_name
		 ''#intranet-core.Project_Type#'',	-- pretty_name
		 ''project_type'',			-- widget_name
		 ''integer'',				-- acs_datatype
		 ''t'',					-- required_p   
		 7,					-- pos y
		 ''f'',					-- also_hard_coded
		 ''im_projects''			-- table_name
	  );

	END IF;


	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_id NOT IN (100,101) AND category_type = ''Intranet Project Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',''General type of project. This allows us to create a suitable folder structure.'',null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;


	RETURN 0;
END;' language 'plpgsql';

SELECT inline_6 ();
DROP FUNCTION inline_6 ();


-- project_status_id
CREATE OR REPLACE FUNCTION inline_7 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN


	SELECT attribute_id INTO v_acs_attribute_id FROM acs_attributes WHERE object_type = ''im_project'' AND attribute_name = ''project_status_id'';
	
	IF v_acs_attribute_id IS NOT NULL THEN
	   v_attribute_id := im_dynfield_attribute__new_only_dynfield (
	       null,					-- attribute_id
	       ''im_dynfield_attribute'',		-- object_type
	       now(),					-- creation_date
	       null,					-- creation_user
	       null,					-- creation_ip
	       null,					-- context_id	
	       v_acs_attribute_id,			-- acs_attribute_id
	       ''project_status'',			-- widget
	       ''f'',					-- deprecated_p
	       ''t'',					-- already_existed_p
	       null,					-- pos_y
	       ''plain'',				-- label_style
	       ''f'',					-- also_hard_coded_p   
	       ''t''					-- include_in_search_p
	  );
	ELSE
	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''im_project'',			-- object_type
		 ''project_status_id'',			-- column_name
		 ''#intranet-core.Project_Status#'',	-- pretty_name
		 ''project_status'',			-- widget_name
		 ''integer'',				-- acs_datatype
		 ''t'',					-- required_p   
		 8,					-- pos y
		 ''f'',					-- also_hard_coded
		 ''im_projects''			-- table_name
	  );

	END IF;


	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_id NOT IN (100,101) AND category_type = ''Intranet Project Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',''In Process: Work is starting immediately, Potential Project: May become a project later, Not Started Yet: We are waiting to start working on it, Finished: Finished already...'',null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;


	RETURN 0;
END;' language 'plpgsql';

SELECT inline_7 ();
DROP FUNCTION inline_7 ();

-- start_date
CREATE OR REPLACE FUNCTION inline_8 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN


	SELECT attribute_id INTO v_acs_attribute_id FROM acs_attributes WHERE object_type = ''im_project'' AND attribute_name = ''start_date'';
	
	IF v_acs_attribute_id IS NOT NULL THEN
	   v_attribute_id := im_dynfield_attribute__new_only_dynfield (
	       null,					-- attribute_id
	       ''im_dynfield_attribute'',		-- object_type
	       now(),					-- creation_date
	       null,					-- creation_user
	       null,					-- creation_ip
	       null,					-- context_id	
	       v_acs_attribute_id,			-- acs_attribute_id
	       ''date'',				-- widget
	       ''f'',					-- deprecated_p
	       ''t'',					-- already_existed_p
	       null,					-- pos_y
	       ''plain'',				-- label_style
	       ''f'',					-- also_hard_coded_p   
	       ''t''					-- include_in_search_p
	  );
	ELSE
	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''im_project'',			-- object_type
		 ''start_date'',			-- column_name
		 ''#intranet-core.Start_Date#'',	-- pretty_name
		 ''date'',				-- widget_name
		 ''date'',				-- acs_datatype
		 ''t'',					-- required_p   
		 9,					-- pos y
		 ''f'',					-- also_hard_coded
		 ''im_projects''			-- table_name
	  );

	END IF;


	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_id NOT IN (100,101) AND category_type = ''Intranet Project Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',null,null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;


	RETURN 0;
END;' language 'plpgsql';

SELECT inline_8 ();
DROP FUNCTION inline_8 ();

update im_dynfield_type_attribute_map set default_value = 'tcl {db_string now "select to_char(now(),''YYYY MM DD'') from dual"}' where attribute_id = (select ida.attribute_id from im_dynfield_attributes ida, acs_attributes aa where ida.acs_attribute_id = aa.attribute_id and aa.attribute_name = 'start_date' and object_type = 'im_project');

-- Add javascript calendar buton on date widget
UPDATE im_dynfield_widgets set parameters = '{format "YYYY-MM-DD"} {after_html {<input type="button" style="height:23px; width:23px; background: url(''/resources/acs-templating/calendar.gif'');" onclick ="return showCalendarWithDateWidget(''$attribute_name'', ''y-m-d'');" ></b>}}' where widget_name = 'date';

-- end_date
CREATE OR REPLACE FUNCTION inline_9 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN


	SELECT attribute_id INTO v_acs_attribute_id FROM acs_attributes WHERE object_type = ''im_project'' AND attribute_name = ''end_date'';
	
	IF v_acs_attribute_id IS NOT NULL THEN
	   v_attribute_id := im_dynfield_attribute__new_only_dynfield (
	       null,					-- attribute_id
	       ''im_dynfield_attribute'',		-- object_type
	       now(),					-- creation_date
	       null,					-- creation_user
	       null,					-- creation_ip
	       null,					-- context_id	
	       v_acs_attribute_id,			-- acs_attribute_id
	       ''date'',				-- widget
	       ''f'',					-- deprecated_p
	       ''t'',					-- already_existed_p
	       null,					-- pos_y
	       ''plain'',				-- label_style
	       ''f'',					-- also_hard_coded_p   
	       ''t''					-- include_in_search_p
	  );
	ELSE
	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''im_project'',			-- object_type
		 ''end_date'',				-- column_name
		 ''#intranet-core.End_Date#'',		-- pretty_name
		 ''timestamp'',				-- widget_name
		 ''timestamp'',				-- acs_datatype
		 ''t'',					-- required_p   
		 10,					-- pos y
		 ''f'',					-- also_hard_coded
		 ''im_projects''			-- table_name
	  );

	END IF;


	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_id NOT IN (100,101) AND category_type = ''Intranet Project Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',null,null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;


	RETURN 0;
END;' language 'plpgsql';

SELECT inline_9 ();
DROP FUNCTION inline_9 ();

update im_dynfield_type_attribute_map set default_value = 'tcl {db_string now "select to_char(now(),''YYYY MM DD HH24 MM SS'') from dual"}' where attribute_id = (select ida.attribute_id from im_dynfield_attributes ida, acs_attributes aa where ida.acs_attribute_id = aa.attribute_id and aa.attribute_name = 'end_date' and object_type = 'im_project');

-- on_track_status_id
CREATE OR REPLACE FUNCTION inline_10 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN


	SELECT attribute_id INTO v_acs_attribute_id FROM acs_attributes WHERE object_type = ''im_project'' AND attribute_name = ''on_track_status_id'';
	
	IF v_acs_attribute_id IS NOT NULL THEN
	   v_attribute_id := im_dynfield_attribute__new_only_dynfield (
	       null,					-- attribute_id
	       ''im_dynfield_attribute'',		-- object_type
	       now(),					-- creation_date
	       null,					-- creation_user
	       null,					-- creation_ip
	       null,					-- context_id	
	       v_acs_attribute_id,			-- acs_attribute_id
	       ''on_track_status'',			-- widget
	       ''f'',					-- deprecated_p
	       ''t'',					-- already_existed_p
	       null,					-- pos_y
	       ''plain'',				-- label_style
	       ''f'',					-- also_hard_coded_p   
	       ''t''					-- include_in_search_p
	  );
	ELSE
	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''im_project'',			-- object_type
		 ''on_track_status_id'',		-- column_name
		 ''#intranet-core.On_Track_Status#'',	-- pretty_name
		 ''on_track_status'',			-- widget_name
		 ''integer'',				-- acs_datatype
		 ''t'',					-- required_p   
		 11,					-- pos y
		 ''f'',					-- also_hard_coded
		 ''im_projects''			-- table_name
	  );

	END IF;


	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_id NOT IN (100,101) AND category_type = ''Intranet Project Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',''Is the project going to be in time and budget (green), does it need attention (yellow) or is it doomed (red)?'',null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;


	RETURN 0;
END;' language 'plpgsql';

SELECT inline_10 ();
DROP FUNCTION inline_10 ();

-- percent_completed
CREATE OR REPLACE FUNCTION inline_11 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN


	SELECT attribute_id INTO v_acs_attribute_id FROM acs_attributes WHERE object_type = ''im_project'' AND attribute_name = ''percent_completed'';
	
	IF v_acs_attribute_id IS NOT NULL THEN
	   v_attribute_id := im_dynfield_attribute__new_only_dynfield (
	       null,					-- attribute_id
	       ''im_dynfield_attribute'',		-- object_type
	       now(),					-- creation_date
	       null,					-- creation_user
	       null,					-- creation_ip
	       null,					-- context_id	
	       v_acs_attribute_id,			-- acs_attribute_id
	       ''numeric'',				-- widget
	       ''f'',					-- deprecated_p
	       ''t'',					-- already_existed_p
	       null,					-- pos_y
	       ''plain'',				-- label_style
	       ''f'',					-- also_hard_coded_p   
	       ''t''					-- include_in_search_p
	  );
	ELSE
	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''im_project'',			-- object_type
		 ''percent_completed'',			-- column_name
		 ''#intranet-core.Percent_Completed#'',	-- pretty_name
		 ''numeric'',				-- widget_name
		 ''float'',				-- acs_datatype
		 ''f'',					-- required_p   
		 12,					-- pos y
		 ''f'',					-- also_hard_coded
		 ''im_projects''			-- table_name
	  );

	END IF;


	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_id NOT IN (100,101) AND category_type = ''Intranet Project Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',null,null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;


	RETURN 0;
END;' language 'plpgsql';

SELECT inline_11 ();
DROP FUNCTION inline_11 ();


-- project_budget_hours
CREATE OR REPLACE FUNCTION inline_12 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN


	SELECT attribute_id INTO v_acs_attribute_id FROM acs_attributes WHERE object_type = ''im_project'' AND attribute_name = ''project_budget_hours'';
	
	IF v_acs_attribute_id IS NOT NULL THEN
	   v_attribute_id := im_dynfield_attribute__new_only_dynfield (
	       null,					-- attribute_id
	       ''im_dynfield_attribute'',		-- object_type
	       now(),					-- creation_date
	       null,					-- creation_user
	       null,					-- creation_ip
	       null,					-- context_id	
	       v_acs_attribute_id,			-- acs_attribute_id
	       ''numeric'',				-- widget
	       ''f'',					-- deprecated_p
	       ''t'',					-- already_existed_p
	       null,					-- pos_y
	       ''plain'',				-- label_style
	       ''f'',					-- also_hard_coded_p   
	       ''t''					-- include_in_search_p
	  );
	ELSE
	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''im_project'',				-- object_type
		 ''project_budget_hours'',		   	-- column_name
		 ''#intranet-core.Project_Budget_Hours#'', 	-- pretty_name
		 ''numeric'',					-- widget_name
		 ''float'',					-- acs_datatype
		 ''f'',						-- required_p   
		 13,					   	-- pos y
		 ''f'',						-- also_hard_coded
		 ''im_projects''				-- table_name
	  );

	END IF;


	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_id NOT IN (100,101) AND category_type = ''Intranet Project Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',''How many hours can be logged on this project (both internal and external resource)?'',null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;


	RETURN 0;
END;' language 'plpgsql';

SELECT inline_12 ();
DROP FUNCTION inline_12 ();


-- project_budget
CREATE OR REPLACE FUNCTION inline_13 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN


	SELECT attribute_id INTO v_acs_attribute_id FROM acs_attributes WHERE object_type = ''im_project'' AND attribute_name = ''project_budget'';
	
	IF v_acs_attribute_id IS NOT NULL THEN
	   v_attribute_id := im_dynfield_attribute__new_only_dynfield (
	       null,					-- attribute_id
	       ''im_dynfield_attribute'',		-- object_type
	       now(),					-- creation_date
	       null,					-- creation_user
	       null,					-- creation_ip
	       null,					-- context_id	
	       v_acs_attribute_id,			-- acs_attribute_id
	       ''numeric'',				-- widget
	       ''f'',					-- deprecated_p
	       ''t'',					-- already_existed_p
	       null,					-- pos_y
	       ''plain'',				-- label_style
	       ''f'',					-- also_hard_coded_p   
	       ''t''					-- include_in_search_p
	  );
	ELSE
	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''im_project'',			-- object_type
		 ''project_budget'',			-- column_name
		 ''#intranet-core.Project_Budget#'',	-- pretty_name
		 ''numeric'',				-- widget_name
		 ''float'',				-- acs_datatype
		 ''f'',					-- required_p   
		 14,					-- pos y
		 ''f'',					-- also_hard_coded
		 ''im_projects''			-- table_name
	  );

	END IF;


	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_id NOT IN (100,101) AND category_type = ''Intranet Project Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',''What is the financial budget of this project? Includes both external (invoices) and internal (timesheet) costs.'',null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;


	RETURN 0;
END;' language 'plpgsql';

SELECT inline_13 ();
DROP FUNCTION inline_13 ();

--project_budget_currency
CREATE OR REPLACE FUNCTION inline_14 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN


	SELECT attribute_id INTO v_acs_attribute_id FROM acs_attributes WHERE object_type = ''im_project'' AND attribute_name = ''project_budget_currency'';
	
	IF v_acs_attribute_id IS NOT NULL THEN
	   v_attribute_id := im_dynfield_attribute__new_only_dynfield (
	       null,					-- attribute_id
	       ''im_dynfield_attribute'',		-- object_type
	       now(),					-- creation_date
	       null,					-- creation_user
	       null,					-- creation_ip
	       null,					-- context_id	
	       v_acs_attribute_id,			-- acs_attribute_id
	       ''currencies'',				-- widget
	       ''f'',					-- deprecated_p
	       ''t'',					-- already_existed_p
	       null,					-- pos_y
	       ''plain'',				-- label_style
	       ''f'',					-- also_hard_coded_p   
	       ''t''					-- include_in_search_p
	  );
	ELSE
	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''im_project'',				-- object_type
		 ''project_budget_currency'',			-- column_name
		 ''#intranet-core.Project_Budget_Currency#'',	-- pretty_name
		 ''currencies'',				-- widget_name
		 ''string'',					-- acs_datatype
		 ''f'',						-- required_p   
		 15,						-- pos y
		 ''f'',						-- also_hard_coded
		 ''im_projects''				-- table_name
	  );
	END IF;


	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_id NOT IN (100,101) AND category_type = ''Intranet Project Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',null,null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;


	RETURN 0;
END;' language 'plpgsql';

SELECT inline_14 ();
DROP FUNCTION inline_14 ();

-- company_project_nr
CREATE OR REPLACE FUNCTION inline_15 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN


	SELECT attribute_id INTO v_acs_attribute_id FROM acs_attributes WHERE object_type = ''im_project'' AND attribute_name = ''company_project_nr'';
	
	IF v_acs_attribute_id IS NOT NULL THEN
	   v_attribute_id := im_dynfield_attribute__new_only_dynfield (
	       null,					-- attribute_id
	       ''im_dynfield_attribute'',		-- object_type
	       now(),					-- creation_date
	       null,					-- creation_user
	       null,					-- creation_ip
	       null,					-- context_id	
	       v_acs_attribute_id,			-- acs_attribute_id
	       ''textbox_medium'',			-- widget
	       ''f'',					-- deprecated_p
	       ''t'',					-- already_existed_p
	       null,					-- pos_y
	       ''plain'',				-- label_style
	       ''f'',					-- also_hard_coded_p   
	       ''t''					-- include_in_search_p
	  );
	ELSE
	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''im_project'',				-- object_type
		 ''company_project_nr'',			-- column_name
		 ''#intranet-core.Company_Project_Nr#'',	-- pretty_name
		 ''textbox_medium'',				-- widget_name
		 ''string'',					-- acs_datatype
		 ''f'',						-- required_p   
		 16,						-- pos y
		 ''f'',						-- also_hard_coded
		 ''im_projects''				-- table_name
	  );

	END IF;


	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_id NOT IN (100,101) AND category_type = ''Intranet Project Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',''The customers reference to this project. This number will appear in invoices of this project.'',null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;


	RETURN 0;
END;' language 'plpgsql';

SELECT inline_15 ();
DROP FUNCTION inline_15 ();

-- description
CREATE OR REPLACE FUNCTION inline_16 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN


	SELECT attribute_id INTO v_acs_attribute_id FROM acs_attributes WHERE object_type = ''im_project'' AND attribute_name = ''description'';
	
	IF v_acs_attribute_id IS NOT NULL THEN
	   v_attribute_id := im_dynfield_attribute__new_only_dynfield (
	       null,					-- attribute_id
	       ''im_dynfield_attribute'',		-- object_type
	       now(),					-- creation_date
	       null,					-- creation_user
	       null,					-- creation_ip
	       null,					-- context_id	
	       v_acs_attribute_id,			-- acs_attribute_id
	       ''richtext'',				-- widget
	       ''f'',					-- deprecated_p
	       ''t'',					-- already_existed_p
	       null,					-- pos_y
	       ''plain'',				-- label_style
	       ''f'',					-- also_hard_coded_p   
	       ''t''					-- include_in_search_p
	  );
	ELSE
	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''im_project'',			-- object_type
		 ''description'',			-- column_name
		 ''#intranet-core.Description#'',	-- pretty_name
		 ''richtext'',				-- widget_name
		 ''text'',				-- acs_datatype
		 ''f'',					-- required_p   
		 17,					-- pos y
		 ''f'',					-- also_hard_coded
		 ''im_projects''			-- table_name
	  );

	END IF;


	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_id NOT IN (100,101) AND category_type = ''Intranet Project Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',null,null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;


	RETURN 0;
END;' language 'plpgsql';

SELECT inline_16 ();
DROP FUNCTION inline_16 ();

alter table im_projects alter column description type text;
-- --------------------------------------------------------
-- Projects Trigger
-- --------------------------------------------------------

drop trigger im_projects_calendar_update_tr on im_projects;
drop function im_projects_calendar_update_tr();

create or replace function im_projects_calendar_update_tr () returns trigger as '
declare
	v_cal_item_id		integer;	

	v_timespan_id		integer;
	v_interval_id		integer;
	v_calendar_id		integer;
	v_activity_id		integer;
	v_recurrence_id		integer;
begin
	-- -------------- Skip if start or end date are null ------------
	IF new.start_date is null OR new.end_date is null THEN
		return new;
	END IF;

	-- -------------- Check if the entry already exists ------------
	v_cal_item_id := null;

	SELECT	event_id
	INTO	v_cal_item_id
	FROM	acs_events
	WHERE	related_object_id = new.project_id
		and related_object_type = ''im_project'';

	-- --------------------- Create entry if it isnt there -------------
	IF v_cal_item_id is null THEN

		v_timespan_id := timespan__new(new.end_date, new.end_date);
		RAISE NOTICE ''im_projects_calendar_update_tr: timespan_id=%'', v_timespan_id;
	
		v_activity_id := acs_activity__new(
			null, 
			new.project_name,
			new.description, 
			''f'', 
			'''', 
			''acs_activity'', now(), null, ''0.0.0.0'', null
		);
		RAISE NOTICE ''im_projects_calendar_update_tr: v_activity_id=%'', v_activity_id;
	
		SELECT	min(calendar_id)
		INTO 	v_calendar_id
		FROM	calendars
		WHERE	private_p = ''f'';
	
		v_recurrence_id := NULL;
		v_cal_item_id := cal_item__new (
			null,			-- cal_item_id
			v_calendar_id,		-- on_which_calendar
			new.project_name,	-- name
			new.description,	-- description
			''f'',			-- html_p
			'''',			-- status_summary
			v_timespan_id,		-- timespan_id
			v_activity_id,		-- activity_id
			v_recurrence_id,	-- recurrence_id
			''cal_item'', null, now(), null, ''0.0.0.0''	
		);
		RAISE NOTICE ''im_projects_calendar_update_tr: cal_id=%'', v_cal_item_id;

	END IF;

	-- --------------------- Update the entry --------------------
	SELECT	activity_id	INTO v_activity_id	FROM acs_events	WHERE	event_id = v_cal_item_id;
	SELECT	timespan_id	INTO v_timespan_id	FROM acs_events	WHERE	event_id = v_cal_item_id;
	SELECT	recurrence_id	INTO v_recurrence_id	FROM acs_events	WHERE	event_id = v_cal_item_id;

	-- Update the event
	UPDATE	acs_events 
	SET	name = new.project_name,
		description = new.description,
		related_object_id = new.project_id,
		related_object_type = ''im_project'',
		related_link_url = ''/intranet/projects/view?project_id=''||new.project_id,
		related_link_text = new.project_name || '' Project'',
		redirect_to_rel_link_p = ''t''
	WHERE	event_id = v_cal_item_id;

	-- Update the activity - same as event
	UPDATE	acs_activities
	SET	name = new.project_name,
		description = new.description
	WHERE	activity_id = v_activity_id;

	-- Update the timespan. Make sure there is only one interval
	-- in this timespan (there may be multiples)
	SELECT	interval_id	INTO v_interval_id	FROM timespans	WHERE	timespan_id = v_timespan_id;

	RAISE NOTICE ''cal_update_tr: cal_item:%, activity:%, timespan:%, recurrence:%, interval:%'', 
			v_cal_item_id, v_activity_id, v_timespan_id, v_recurrence_id, v_interval_id;

	UPDATE	time_intervals
	SET	start_date = new.end_date,
		end_date = new.end_date
	WHERE	interval_id = v_interval_id;

	return new;
end;' language 'plpgsql';

create trigger im_projects_calendar_update_tr after insert or update
on im_projects for each row
execute procedure im_projects_calendar_update_tr ();

-- Set the defaults for project dynfields
update im_dynfield_type_attribute_map set default_value = 76 where attribute_id = (select da.attribute_id from im_dynfield_attributes da, acs_attributes aa where da.acs_attribute_id = aa.attribute_id and aa.attribute_name = 'project_status_id' and object_type ='im_project');

update im_dynfield_type_attribute_map set default_value = 85 where attribute_id = (select da.attribute_id from im_dynfield_attributes da, acs_attributes aa where da.acs_attribute_id = aa.attribute_id and aa.attribute_name = 'project_type_id' and object_type ='im_project');

update im_dynfield_type_attribute_map set default_value = 'tcl im_project_on_track_status_green' where attribute_id = (select da.attribute_id from im_dynfield_attributes da, acs_attributes aa where da.acs_attribute_id = aa.attribute_id and aa.attribute_name = 'on_track_status_id' and object_type ='im_project');

update im_dynfield_type_attribute_map set default_value = 0 where attribute_id = (select da.attribute_id from im_dynfield_attributes da, acs_attributes aa where da.acs_attribute_id = aa.attribute_id and aa.attribute_name = 'percent_completed' and object_type ='im_project');

update im_dynfield_type_attribute_map set default_value = 'tcl {parameter::get -package_id [im_package_cost_id] -parameter "DefaultCurrency" -default "EUR"}' where attribute_id = (select da.attribute_id from im_dynfield_attributes da, acs_attributes aa where da.acs_attribute_id = aa.attribute_id and aa.attribute_name = 'project_budget_currency' and object_type ='im_project');

update im_dynfield_type_attribute_map set default_value = 'tcl {ad_conn user_id}' where attribute_id = (select da.attribute_id from im_dynfield_attributes da, acs_attributes aa where da.acs_attribute_id = aa.attribute_id and aa.attribute_name = 'project_lead_id' and object_type ='im_project');


-- update project_parent_options widget
CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE
	v_widget_id integer;

BEGIN                                                                                                                                                       

        SELECT widget_id INTO v_widget_id FROM im_dynfield_widgets where widget_name = ''project_parent_options'';

        UPDATE im_dynfield_widgets 
	SET parameters = ''{custom {tcl {im_project_options -exclude_subprojects_p 0 -exclude_status_id [im_project_status_closed] -exclude_tasks_p 1 -project_id $super_project_id} switch_p 1 global_var super_project_id}}'' 
	WHERE widget_id = v_widget_id;

	RETURN 0;                                                                                                                                           
END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();



-- update open_projects widget
create or replace FUNCTION inline_0 ()
returns integer as '
DECLARE
	v_widget_id integer;

BEGIN
	SELECT widget_id INTO v_widget_id FROM im_dynfield_widgets where widget_name = ''open_projects'';
	
	UPDATE im_dynfield_widgets 
	SET parameters = ''{custom {tcl {im_project_options -exclude_subprojects_p 0 -exclude_status_id [im_project_status_closed] -exclude_tasks_p 1} switch_p 1}}'', widget = ''generic_tcl'' WHERE widget_id = v_widget_id;

	RETURN 0;
END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();

-- User Components

-- User Basic Info Component                                                                                                                                
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'User Basic Information',
       'intranet-core',
       'left',
       '/intranet/users/view',
       null,
       0,
       'im_user_basic_info_component $user_id $return_url');

-- User Contact Infor Component
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'User Contact Information',
       'intranet-core',
       'left',
       '/intranet/users/view',
       null,
       0,
       'im_user_contact_info_component $user_id $return_url');

-- User Skin Component                                                                                                                                     
-- SELECT im_component_plugin__new (null, 'acs_object', now(), null, null, null, 'User Skin Information', 'intranet-core', 'left', '/intranet/users/view', null, 0, 'im_user_skin_info_component $user_id $return_url');                                                                                                 

SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'User Skin Information',
       'intranet-core',
       'left',
       '/intranet/users/view',
       null,
       0,
       'im_skin_select_html $user_id $return_url');

-- User Administration Component
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'User Admin Information',
       'intranet-core',
       'left',
       '/intranet/users/view',
       null,
       0,
       'im_user_admin_info_component $user_id $return_url');

-- User Localization Component
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'User Locale',
       'intranet-core',
       'left',
       '/intranet/users/view',
       null,
       0,
       'im_user_localization_component $user_id $return_url');

-- Make sure User Locale Component is readable for anybody
CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE
	row		RECORD;
	v_object_id	INTEGER;

BEGIN

 	SELECT o.object_id INTO v_object_id 
	FROM im_component_plugins c, acs_objects o
	WHERE o.object_id = c.plugin_id
	AND package_name = ''intranet-core''
	AND plugin_name = ''User Locale'';

	FOR row IN 
		SELECT DISTINCT g.group_id
		FROM acs_objects o, groups g, im_profiles p
		WHERE g.group_id = o.object_id
		AND g.group_id = p.profile_id
		AND o.object_type = ''im_profile''
	LOOP
	
		PERFORM im_grant_permission(v_object_id,row.group_id,''read'');

	END LOOP;

	RETURN 0;

END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();

-- User Portrait Component
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'User Portrait',
       'intranet-core',
       'right',
       '/intranet/users/view',
       null,
       0,
       'im_portrait_component $user_id_from_search $return_url $read $write $admin');


-- Company Components
-- Company Info
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'Company Information',
       'intranet-core',
       'left',
       '/intranet/companies/view',
       null,
       0,
       'im_company_info_component $company_id $return_url');

-- Company Projects
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'Company Projects',
       'intranet-core',
       'right',
       '/intranet/companies/view',
       null,
       0,
       'im_company_projects_component $company_id $return_url');


-- Company Members
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'Company Employees',
       'intranet-core',
       'right',
       '/intranet/companies/view',
       null,
       0,
       'im_company_employees_component $company_id $return_url');

-- Company Contacts
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'Company Contacts',
       'intranet-core',
       'right',
       '/intranet/companies/view',
       null,
       0,
       'im_company_contacts_component $company_id $return_url');


-- Add more html tags in the acs-kernel parameter
UPDATE apm_parameter_values SET attr_value = 'A ADDRESS B BLOCKQUOTE BR CODE DIV DD DL DT EM FONT HR I LI OL P PRE SPAN STRIKE STRONG SUB SUP TABLE TBODY TD TR TT U UL EMAIL FIRST_NAMES LAST_NAME GROUP_NAME H1 H2 H3 H4 H5 H6' WHERE parameter_id = (SELECT parameter_id FROM apm_parameters WHERE parameter_name = 'AllowedTag');

UPDATE apm_parameter_values SET attr_value = 'align alt border cellpadding cellspacing color face height href hspace id name size src style target title valign vspace width' WHERE parameter_id = (SELECT parameter_id FROM apm_parameters WHERE parameter_name = 'AllowedAttribute');

UPDATE apm_parameter_values SET attr_value = 1 WHERE parameter_id = (SELECT parameter_id FROM apm_parameters WHERE parameter_name = 'UseHtmlAreaForRichtextP');

-- New functions to return the correct values
create or replace function im_percent_from_number (float)
returns varchar as '
DECLARE                                                                                                                                                      
        p_percent        alias for $1;
		v_percent	varchar;
BEGIN                           
		select to_char(p_percent,''90D99'') || '' %'' into v_percent;
        return v_percent;
END;' language 'plpgsql';

create or replace function im_numeric_from_id(float)
returns varchar as '
DECLARE                                                                                                                                                      
        v_result        alias for $1;
BEGIN                                                                                                                                                        
        return v_result::varchar;
END;' language 'plpgsql';

update im_dynfield_widgets set deref_plpgsql_function = 'im_numeric_from_id' where widget_name ='numeric';
SELECT im_dynfield_attribute_new ('im_office', 'office_name', '#intranet-core.Office_Name#', 'textbox_medium', 'string', 't', 1, 't');
SELECT im_dynfield_attribute_new ('im_office', 'office_path', '#intranet-core.lt_Office_Directory_Path#', 'textbox_medium', 'string', 't', 2, 't');
SELECT im_dynfield_attribute_new ('im_office', 'office_type_id', '#intranet-core.Office_Type#', 'category_office_type', 'integer', 't', 3, 't');
SELECT im_dynfield_attribute_new ('im_office', 'office_status_id', '#intranet-core.Office_Status#', 'category_office_status', 'integer', 't', 4, 't');
SELECT im_dynfield_attribute_new ('im_office', 'phone', '#intranet-core.Phone#', 'textbox_medium', 'string', 'f', 5, 't');
SELECT im_dynfield_attribute_new ('im_office', 'fax', '#intranet-core.Fax#', 'textbox_medium', 'string', 'f', 6, 't');
SELECT im_dynfield_attribute_new ('im_office', 'address_line1', '#intranet-core.Address_1#', 'textbox_medium', 'string', 'f', 7, 't');
SELECT im_dynfield_attribute_new ('im_office', 'address_line2', '#intranet-core.Address_2#', 'textbox_medium', 'string', 'f', 8, 't');
SELECT im_dynfield_attribute_new ('im_office', 'address_postal_code', '#intranet-core.ZIP#', 'textbox_medium', 'string', 'f', 9, 't');
SELECT im_dynfield_attribute_new ('im_office', 'address_city', '#intranet-core.City#', 'textbox_medium', 'string', 'f', 10, 't');
SELECT im_dynfield_attribute_new ('im_office', 'address_country_code', '#intranet-core.Country#', 'country_codes', 'string', 'f', 10, 't');

-- Fix type
update im_dynfield_widgets set parameters='{custom {category_type "Intranet Company Status"}}' where widget_name = 'category_company_status';
update im_dynfield_widgets set parameters='{custom {category_type "Intranet Office Status"}}' where widget_name = 'category_office_status';
update im_dynfield_widgets set parameters='{custom {category_type "Intranet Office Type"}}' where widget_name = 'category_office_type';
update im_dynfield_widgets set parameters='{custom {category_type "Intranet Annual Revenue"}}' where widget_name = 'annual_revenue';
update im_dynfield_widgets set parameters='{custom {category_type "Intranet Person Status"}}' where widget_name = 'category_person_status';

-- Dealing with persons
-- Dynfields
SELECT im_dynfield_attribute_new ('person', 'first_names', '#acs-subsite.first_names#', 'textbox_medium', 'string', 't', 0, 't');
SELECT im_dynfield_attribute_new ('person', 'last_name', '#acs-subsite.last_name#', 'textbox_medium', 'string', 't', 1, 't');

-- email
CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN


	SELECT attribute_id INTO v_acs_attribute_id FROM acs_attributes WHERE object_type = ''person'' AND attribute_name = ''email'';
	
	IF v_acs_attribute_id IS NOT NULL THEN
	   v_attribute_id := im_dynfield_attribute__new_only_dynfield (
	       null,					-- attribute_id
	       ''im_dynfield_attribute'',		-- object_type
	       now(),					-- creation_date
	       null,					-- creation_user
	       null,					-- creation_ip
	       null,					-- context_id	
	       v_acs_attribute_id,			-- acs_attribute_id
	       ''textbox_medium'',			-- widget
	       ''f'',					-- deprecated_p
	       ''t'',					-- already_existed_p
	       null,					-- pos_y
	       ''plain'',				-- label_style
	       ''f'',					-- also_hard_coded_p   
	       ''t''					-- include_in_search_p
	  );
	ELSE
	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''person'',			-- object_type
		 ''email'',			-- column_name
		 ''#intranet-core.Email_address#'',	-- pretty_name
		 ''textbox_medium'',			-- widget_name
		 ''string'',				-- acs_datatype
		 ''t'',					-- required_p   
		 1,					-- pos y
		 ''f'',					-- also_hard_coded
		 ''parties''			-- table_name
	  );

	END IF;


	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_type = ''Intranet User Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',''Please enter a valid E-Mail for the user'',null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;


	RETURN 0;
END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();


-- Disable the also hard coded to allow fast entry of biz cards
update im_dynfield_attributes set also_hard_coded_p = 'f' where acs_attribute_id in (select attribute_id from acs_attributes where object_type = 'im_company');

CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE
	v_attribute_id	integer;
BEGIN
	select attribute_id into v_attribute_id from im_dynfield_attributes where acs_attribute_id = (select attribute_id from acs_attributes where attribute_name = ''main_office_id'');
	IF v_attribute_id IS NOT NULL THEN
	    perform im_dynfield_attribute__del(v_attribute_id);
        END IF;

	RETURN 0;
END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();


-- Rename Tax Classification into vat_type_id

create or replace function inline_0 ()
returns integer as $body$
declare
        v_count  integer;
	v_attribute_id integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = 'im_companies' and lower(column_name) = 'tax_classification';

        IF v_count = 1 THEN
	   select attribute_id into v_attribute_id from im_dynfield_attributes
           where acs_attribute_id = (select attribute_id from acs_attributes where attribute_name = 'tax_classification');

	      update im_companies set vat_type_id = tax_classification;
	         perform im_dynfield_attribute__del(v_attribute_id);
        END IF;

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as $body$
declare
        v_count  integer;
	v_attribute_id integer;
begin

        select attribute_id into v_attribute_id from im_dynfield_attributes
        where acs_attribute_id = (select attribute_id from acs_attributes where attribute_name = 'default_vat');
	   perform im_dynfield_attribute__del(v_attribute_id);

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

-- User Components

-- User Basic Info Component                                                                                                                                
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'User Basic Information',
       'intranet-core',
       'left',
       '/intranet/users/view',
       null,
       0,
       'im_user_basic_info_component $user_id $return_url');

-- User Contact Infor Component
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'User Contact Information',
       'intranet-core',
       'left',
       '/intranet/users/view',
       null,
       0,
       'im_user_contact_info_component $user_id $return_url');

-- User Skin Component                                                                                                                                     
-- SELECT im_component_plugin__new (null, 'acs_object', now(), null, null, null, 'User Skin Information', 'intranet-core', 'left', '/intranet/users/view', null, 0, 'im_user_skin_info_component $user_id $return_url');                                                                                                 

SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'User Skin Information',
       'intranet-core',
       'left',
       '/intranet/users/view',
       null,
       0,
       'im_skin_select_html $user_id $return_url');

-- User Administration Component
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'User Admin Information',
       'intranet-core',
       'left',
       '/intranet/users/view',
       null,
       0,
       'im_user_admin_info_component $user_id $return_url');

-- User Localization Component
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'User Locale',
       'intranet-core',
       'left',
       '/intranet/users/view',
       null,
       0,
       'im_user_localization_component $user_id $return_url');

-- Make sure User Locale Component is readable for anybody
CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE
	row		RECORD;
	v_object_id	INTEGER;

BEGIN

 	SELECT o.object_id INTO v_object_id 
	FROM im_component_plugins c, acs_objects o
	WHERE o.object_id = c.plugin_id
	AND package_name = ''intranet-core''
	AND plugin_name = ''User Locale'';

	FOR row IN 
		SELECT DISTINCT g.group_id
		FROM acs_objects o, groups g, im_profiles p
		WHERE g.group_id = o.object_id
		AND g.group_id = p.profile_id
		AND o.object_type = ''im_profile''
	LOOP
	
		PERFORM im_grant_permission(v_object_id,row.group_id,''read'');

	END LOOP;

	RETURN 0;

END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();

-- User Portrait Component
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'User Portrait',
       'intranet-core',
       'right',
       '/intranet/users/view',
       null,
       0,
       'im_portrait_component $user_id_from_search $return_url $read $write $admin');


-- Company Components
-- Company Info
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'Company Information',
       'intranet-core',
       'left',
       '/intranet/companies/view',
       null,
       0,
       'im_company_info_component $company_id $return_url');

-- Company Projects
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'Company Projects',
       'intranet-core',
       'right',
       '/intranet/companies/view',
       null,
       0,
       'im_company_projects_component $company_id $return_url');


-- Company Members
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'Company Employees',
       'intranet-core',
       'right',
       '/intranet/companies/view',
       null,
       0,
       'im_company_employees_component $company_id $return_url');

-- Company Contacts
SELECT im_component_plugin__new (
       null,
       'acs_object',
       now(),
       null,
       null,
       null,
       'Company Contacts',
       'intranet-core',
       'right',
       '/intranet/companies/view',
       null,
       0,
       'im_company_contacts_component $company_id $return_url');


-- Add more html tags in the acs-kernel parameter
UPDATE apm_parameter_values SET attr_value = 'A ADDRESS B BLOCKQUOTE BR CODE DIV DD DL DT EM FONT HR I LI OL P PRE SPAN STRIKE STRONG SUB SUP TABLE TBODY TD TR TT U UL EMAIL FIRST_NAMES LAST_NAME GROUP_NAME H1 H2 H3 H4 H5 H6' WHERE parameter_id = (SELECT parameter_id FROM apm_parameters WHERE parameter_name = 'AllowedTag');

UPDATE apm_parameter_values SET attr_value = 'align alt border cellpadding cellspacing color face height href hspace id name size src style target title valign vspace width' WHERE parameter_id = (SELECT parameter_id FROM apm_parameters WHERE parameter_name = 'AllowedAttribute');

UPDATE apm_parameter_values SET attr_value = 1 WHERE parameter_id = (SELECT parameter_id FROM apm_parameters WHERE parameter_name = 'UseHtmlAreaForRichtextP');

-- New functions to return the correct values
create or replace function im_percent_from_number (float)
returns varchar as '
DECLARE                                                                                                                                                      
        p_percent        alias for $1;
		v_percent	varchar;
BEGIN                           
		select to_char(p_percent,''90D99'') || '' %'' into v_percent;
        return v_percent;
END;' language 'plpgsql';

create or replace function im_numeric_from_id(float)
returns varchar as '
DECLARE                                                                                                                                                      
        v_result        alias for $1;
BEGIN                                                                                                                                                        
        return v_result::varchar;
END;' language 'plpgsql';

update im_dynfield_widgets set deref_plpgsql_function = 'im_numeric_from_id' where widget_name ='numeric';
SELECT im_dynfield_attribute_new ('im_office', 'office_name', '#intranet-core.Office_Name#', 'textbox_medium', 'string', 't', 1, 't');
SELECT im_dynfield_attribute_new ('im_office', 'office_path', '#intranet-core.lt_Office_Directory_Path#', 'textbox_medium', 'string', 't', 2, 't');
SELECT im_dynfield_attribute_new ('im_office', 'office_type_id', '#intranet-core.Office_Type#', 'category_office_type', 'integer', 't', 3, 't');
SELECT im_dynfield_attribute_new ('im_office', 'office_status_id', '#intranet-core.Office_Status#', 'category_office_status', 'integer', 't', 4, 't');
SELECT im_dynfield_attribute_new ('im_office', 'phone', '#intranet-core.Phone#', 'textbox_medium', 'string', 'f', 5, 't');
SELECT im_dynfield_attribute_new ('im_office', 'fax', '#intranet-core.Fax#', 'textbox_medium', 'string', 'f', 6, 't');
SELECT im_dynfield_attribute_new ('im_office', 'address_line1', '#intranet-core.Address_1#', 'textbox_medium', 'string', 'f', 7, 't');
SELECT im_dynfield_attribute_new ('im_office', 'address_line2', '#intranet-core.Address_2#', 'textbox_medium', 'string', 'f', 8, 't');
SELECT im_dynfield_attribute_new ('im_office', 'address_postal_code', '#intranet-core.ZIP#', 'textbox_medium', 'string', 'f', 9, 't');
SELECT im_dynfield_attribute_new ('im_office', 'address_city', '#intranet-core.City#', 'textbox_medium', 'string', 'f', 10, 't');
SELECT im_dynfield_attribute_new ('im_office', 'address_country_code', '#intranet-core.Country#', 'country_codes', 'string', 'f', 10, 't');

-- Fix type
update im_dynfield_widgets set parameters='{custom {category_type "Intranet Company Status"}}' where widget_name = 'category_company_status';
update im_dynfield_widgets set parameters='{custom {category_type "Intranet Office Status"}}' where widget_name = 'category_office_status';
update im_dynfield_widgets set parameters='{custom {category_type "Intranet Office Type"}}' where widget_name = 'category_office_type';
update im_dynfield_widgets set parameters='{custom {category_type "Intranet Annual Revenue"}}' where widget_name = 'annual_revenue';
update im_dynfield_widgets set parameters='{custom {category_type "Intranet Person Status"}}' where widget_name = 'category_person_status';

-- Dealing with persons
-- Dynfields
SELECT im_dynfield_attribute_new ('person', 'first_names', '#acs-subsite.first_names#', 'textbox_medium', 'string', 't', 0, 't');
SELECT im_dynfield_attribute_new ('person', 'last_name', '#acs-subsite.last_name#', 'textbox_medium', 'string', 't', 1, 't');

-- email
CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN


	SELECT attribute_id INTO v_acs_attribute_id FROM acs_attributes WHERE object_type = ''person'' AND attribute_name = ''email'';
	
	IF v_acs_attribute_id IS NOT NULL THEN
	   v_attribute_id := im_dynfield_attribute__new_only_dynfield (
	       null,					-- attribute_id
	       ''im_dynfield_attribute'',		-- object_type
	       now(),					-- creation_date
	       null,					-- creation_user
	       null,					-- creation_ip
	       null,					-- context_id	
	       v_acs_attribute_id,			-- acs_attribute_id
	       ''textbox_medium'',			-- widget
	       ''f'',					-- deprecated_p
	       ''t'',					-- already_existed_p
	       null,					-- pos_y
	       ''plain'',				-- label_style
	       ''f'',					-- also_hard_coded_p   
	       ''t''					-- include_in_search_p
	  );
	ELSE
	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''person'',			-- object_type
		 ''email'',			-- column_name
		 ''#intranet-core.Email_address#'',	-- pretty_name
		 ''textbox_medium'',			-- widget_name
		 ''string'',				-- acs_datatype
		 ''t'',					-- required_p   
		 1,					-- pos y
		 ''f'',					-- also_hard_coded
		 ''parties''			-- table_name
	  );

	END IF;


	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_type = ''Intranet User Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',''Please enter a valid E-Mail for the user'',null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;


	RETURN 0;
END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();


-- Disable the also hard coded to allow fast entry of biz cards
update im_dynfield_attributes set also_hard_coded_p = 'f' where acs_attribute_id in (select attribute_id from acs_attributes where object_type = 'im_company');

CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE
	v_attribute_id	integer;
BEGIN
	select attribute_id into v_attribute_id from im_dynfield_attributes where acs_attribute_id = (select attribute_id from acs_attributes where attribute_name = ''main_office_id'');
	IF v_attribute_id IS NOT NULL THEN
	    perform im_dynfield_attribute__del(v_attribute_id);
        END IF;

	RETURN 0;
END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();


SELECT im_dynfield_widget__new (
                null,                   -- widget_id
                'im_dynfield_widget',   -- object_type
                now(),                  -- creation_date
                null,                   -- creation_user
                null,                   -- creation_ip
                null,                   -- context_id
                'vat_type',              -- widget_name
                '#intranet-core.VAT#',      -- pretty_name
                '#intranet-core.VAT#',      -- pretty_plural
                10007,                  -- storage_type_id
                'integer',              -- acs_datatype
                'im_category_tree',             -- widget
                'integer',              -- sql_datatype
                '{custom {category_type "Intranet VAT Type"}}', 
                'im_name_from_id'
);

create or replace function inline_0 ()
returns integer as $body$
declare
        v_count  integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = 'im_companies' and lower(column_name) = 'vat_type_id';

        IF v_count = 0 THEN
  	      alter table im_companies add column vat_type_id integer;
        END IF;

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


-- tax classification
CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN

	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''im_company'',			-- object_type
		 ''vat_type_id'',			-- column_name
		 ''#intranet-core.Tax_classification#'',	-- pretty_name
		 ''vat_type'',			-- widget_name
		 ''integer'',				-- acs_datatype
		 ''t'',					-- required_p   
		 90,					-- pos y
		 ''f'',					-- also_hard_coded
		 ''im_companies''			-- table_name
	  );

	  

	IF v_attribute_id != 1 THEN
	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_type = ''Intranet Company Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',''Choose the appropriate Tax Classification'',null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;
        END IF;

	RETURN 0;
END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();




-- fix missing image on menus
update im_menus 
set    menu_gif_small = 'arrow_right'
where  menu_gif_small is null and
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
'project_lead_id', 
'project_name', 
'project_nr', 
'project_path', 
'project_status_id', 
'project_type_id'
		)
	)
;

