-- 
-- packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.1.0.0-4.0.1.0.1.sql
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
-- @creation-date 2011-03-28
-- @cvs-id $Id$
--

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.1.0.0-4.0.1.0.1.sql','');

-- Introduce variable_name field
create or replace function inline_0 ()
returns integer as $body$
DECLARE
	v_count			integer;
BEGIN
	select	count(*) into v_count from user_tab_columns
	where	lower(table_name) = 'im_view_columns' and lower(column_name) = 'variable_name';
        IF v_count > 0 THEN return 0; END IF;

	alter table im_view_columns add variable_name varchar(100);

        return 0;
end; $body$ language 'plpgsql';
select inline_0();
drop function inline_0();

-- Introduce variable_name field
create or replace function inline_0 ()
returns integer as $body$
DECLARE
	v_count			integer;
BEGIN
	select	count(*) into v_count from user_tab_columns
	where	lower(table_name) = 'im_view_columns' and lower(column_name) = 'datatype';
        IF v_count > 0 THEN return 0; END IF;

	alter table im_view_columns add datatype varchar(100);

        return 0;
end; $body$ language 'plpgsql';
select inline_0();
drop function inline_0();

-- Create the default variable_names and datatypes
--

-- project_list
update im_view_columns set variable_name = 'percent_completed', datatype = 'percentage' where column_id = 2002;
update im_view_columns set variable_name = 'project_nr', datatype = 'string' where column_id = 2005;
update im_view_columns set variable_name = 'project_name', datatype = 'textarea' where column_id = 2010;
update im_view_columns set variable_name = 'company_name', datatype = 'string' where column_id = 2015;
update im_view_columns set variable_name = 'project_type', datatype = 'string' where column_id = 2020;
update im_view_columns set variable_name = 'lead_name', datatype = 'string' where column_id = 2025;
update im_view_columns set variable_name = 'start_date', datatype = 'date' where column_id = 2030;
update im_view_columns set variable_name = 'end_date', datatype = 'date' where column_id = 2035;
update im_view_columns set variable_name = 'project_status', datatype = 'string' where column_id = 2040;

-- employees_list
update im_view_columns set variable_name = 'name', datatype = 'string' where column_id = 5500;
update im_view_columns set variable_name = 'email', datatype = 'string' where column_id = 5501;
update im_view_columns set variable_name = 'supervisor_name', datatype = 'string' where column_id = 5502;
update im_view_columns set variable_name = 'work_phone', datatype = 'string' where column_id = 5504;
update im_view_columns set variable_name = 'cell_phone', datatype = 'string' where column_id = 5505;
update im_view_columns set variable_name = 'home_phone', datatype = 'string' where column_id = 5506;

-- im_timesheet_task_list
update im_view_columns set variable_name = 'project_lead', datatype = 'string' where column_id = 1001;
update im_view_columns set variable_name = 'task_name', datatype = 'textarea' where column_id = 91002;
update im_view_columns set variable_name = 'cost_center_code', datatype = 'string' where column_id = 91006;
update im_view_columns set variable_name = 'start_date', datatype = 'date' where column_id = 91007;
update im_view_columns set variable_name = 'end_date', datatype = 'date' where column_id = 91008;
update im_view_columns set variable_name = 'planned_units', datatype = 'float' where column_id = 91010;
update im_view_columns set variable_name = 'reported_hours_cache', datatype = 'float' where column_id = 91014;
update im_view_columns set variable_name = 'task_status', datatype = 'string' where column_id = 91018;
update im_view_columns set variable_name = 'percent_completed', datatype = 'percentage' where column_id = 91021;

