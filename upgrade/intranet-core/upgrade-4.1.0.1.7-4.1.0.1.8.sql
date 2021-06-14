-- 
-- 
-- 
-- Copyright (c) 2015, cognovís GmbH, Hamburg, Germany
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
-- @author <yourname> (<your email>)
-- @creation-date 2013-01-19
-- @cvs-id $Id$
--

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.0.1.7-4.1.0.1.8.sql','');

-- Signatures
alter table parties add column signature text;

CREATE OR REPLACE FUNCTION inline_16 ()
RETURNS integer AS '
DECLARE
    v_acs_attribute_id	integer;
    v_attribute_id		integer;
    v_count			integer;
    row			record;
BEGIN


    SELECT attribute_id INTO v_acs_attribute_id FROM acs_attributes WHERE object_type = ''person'' AND attribute_name = ''signature'';

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
         ''person'',			-- object_type
         ''signature'',			-- column_name
         ''#intranet-core.Signature#'',	-- pretty_name
         ''richtext'',				-- widget_name
         ''text'',				-- acs_datatype
         ''f'',					-- required_p   
         17,					-- pos y
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
              (v_attribute_id, row.category_id,''edit'',null,null,null,''f'');
        ELSE
           UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
        END IF;

    END LOOP;

    RETURN 0;
END;' language 'plpgsql';

SELECT inline_16 ();
DROP FUNCTION inline_16 ();

alter table parties alter column signature type text;