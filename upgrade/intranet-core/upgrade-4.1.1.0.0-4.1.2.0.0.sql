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

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.1.0.0-4.1.2.0.0.sql','');

-- Widget for the salutation
SELECT im_dynfield_widget__new (
                null,                   -- widget_id
                'im_dynfield_widget',   -- object_type
                now(),                  -- creation_date
                null,                   -- creation_user
                null,                   -- creation_ip
                null,                   -- context_id
                'salutation',              -- widget_name
                '#intranet-core.Salutation#',      -- pretty_name
                '#intranet-core.Salutation#',      -- pretty_plural
                10007,                  -- storage_type_id
                'integer',              -- acs_datatype
                'im_category_tree',             -- widget
                'integer',              -- sql_datatype
                '{custom {category_type "Intranet Salutation"}}', 
                'im_name_from_id'
);



create or replace function inline_0 ()
returns integer as $body$
declare
        v_count  integer;
begin
        select count(*) into v_count from user_tab_columns
    where lower(table_name) = 'persons' and lower(column_name) = 'salutation_id';

        IF v_count = 0 THEN
            alter table persons add column salutation_id integer;
        END IF;

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE
    v_acs_attribute_id    integer;
    v_attribute_id        integer;
    v_count            integer;
    row            record;
BEGIN

      v_attribute_id := im_dynfield_attribute_new (
           ''person'',            -- object_type
         ''salutation_id'',            -- column_name
         ''#intranet-core.Salutation#'',    -- pretty_name
         ''salutation'',            -- widget_name
         ''integer'',                -- acs_datatype
         ''t'',                    -- required_p   
         100,                    -- pos y
         ''f'',                    -- also_hard_coded
         ''persons''            -- table_name
      );



    IF v_attribute_id != 1 THEN
    FOR row IN 
        SELECT category_id FROM im_categories WHERE category_type = ''Intranet User Type''
    LOOP

        SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
        IF v_count = 0 THEN
           INSERT INTO im_dynfield_type_attribute_map
                 (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
           VALUES
          (v_attribute_id, row.category_id,''edit'',''Choose the appropriate Salutation'',null,null,''f'');
        ELSE
           UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
        END IF;

    END LOOP;
        END IF;

    RETURN 0;
END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();

-- Create new final_company type
create or replace function inline_0 ()
returns varchar as $body$
DECLARE
    v_exists_p    integer;
BEGIN
    select count(*) into v_exists_p from im_categories
    where category_id = 10247;
    IF v_exists_p = 0 THEN
        insert into im_categories (
            category_id, category, category_type, 
            category_gif, category_description) 
        values (10247, 'Final Company', 'Intranet Company Type', 
        'company', 'Final Company');
    END IF;

    return 0;
end;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();


-- Widget for the final_company
SELECT im_dynfield_widget__new (
                null,                   -- widget_id
                'im_dynfield_widget',   -- object_type
                now(),                  -- creation_date
                null,                   -- creation_user
                null,                   -- creation_ip
                null,                   -- context_id
                'final_company',              -- widget_name
                '#intranet-core.Final_Company#',      -- pretty_name
                '#intranet-core.Final_Company#',      -- pretty_plural
                10007,                  -- storage_type_id
                'integer',              -- acs_datatype
                'generic_sql',             -- widget
                'integer',              -- sql_datatype
            '{custom {sql {select company_id, company_name from im_companies where company_type_id in (select * from im_sub_categories(10247)) and company_status_id in (select * from im_sub_categories(46)) order by lower(company_name) }}}', 
                'im_name_from_id'
);
    
-- Column for the final company
create or replace function inline_0 ()
returns integer as $body$
declare
        v_count  integer;
begin
        select count(*) into v_count from user_tab_columns
    where lower(table_name) = 'im_projects' and lower(column_name) = 'final_company_id';

        IF v_count = 0 THEN
            alter table im_projects add column final_company_id integer 
            constraint im_project_final_company_fk references im_companies;
        END IF;

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

-- Add the final company widget
CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE
    v_acs_attribute_id    integer;
    v_attribute_id        integer;
    v_count            integer;
    row            record;
BEGIN

      v_attribute_id := im_dynfield_attribute_new (
           ''im_project'',            -- object_type
         ''final_company_id'',            -- column_name
         ''#intranet-core.Final_Company#'',    -- pretty_name
         ''final_company'',            -- widget_name
         ''integer'',                -- acs_datatype
         ''f'',                    -- required_p   
         105,                    -- pos y
         ''f'',                    -- also_hard_coded
         ''im_projects''            -- table_name
      );



    IF v_attribute_id != 1 THEN
    FOR row IN 
        SELECT category_id FROM im_categories WHERE category_type = ''Intranet Project Type''
    LOOP

        SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
        IF v_count = 0 THEN
           INSERT INTO im_dynfield_type_attribute_map
                 (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
           VALUES
          (v_attribute_id, row.category_id,''edit'',''Choose the final company for the project'',null,null,''f'');
        ELSE
           UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
        END IF;

    END LOOP;
        END IF;

    RETURN 0;
END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();



-- Add support for internal error reporting
update apm_parameter_values set attr_value = '/intranet/report-bug-on-page-2' where parameter_id = (select parameter_id from apm_parameters where parameter_name = 'ErrorReportURL');



SELECT  im_component_plugin__new (
    null,               -- plugin_id
    'acs_object',           -- object_type
    now(),              -- creation_date
    null,               -- creation_user
    null,               -- creation_ip
    null,               -- context_id
    'User Project Portlet',     -- plugin_name
    'intranet-core',        -- package_name
    'right',                -- location
    '/intranet/users/view',     -- page_url
    null,               -- view_name
    15,             -- sort_order
    'im_project_personal_active_projects_component -user_id $user_id'   -- component_tcl
);


