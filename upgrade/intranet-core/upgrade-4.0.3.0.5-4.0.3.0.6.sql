-- 
-- packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.0.5-4.0.3.0.6.sql
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

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.0.5-4.0.3.0.6.sql','');


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
