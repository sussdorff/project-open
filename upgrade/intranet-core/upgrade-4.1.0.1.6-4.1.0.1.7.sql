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

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.0.1.6-4.1.0.1.7.sql','');


-- Widget for the final_company
SELECT im_dynfield_widget__new (
                null,                   -- widget_id
                'im_dynfield_widget',   -- object_type
                now(),                  -- creation_date
                null,                   -- creation_user
                null,                   -- creation_ip
                null,                   -- context_id
                'cost_templates',              -- widget_name
                '#intranet-core.Templates#',      -- pretty_name
                '#intranet-core.Templates#',      -- pretty_plural
                10007,                  -- storage_type_id
                'integer',              -- acs_datatype
                'im_category_tree',             -- widget
                'integer',              -- sql_datatype
                '{custom {category_type "Intranet Cost Template"}}', 
                'im_name_from_id'
);
