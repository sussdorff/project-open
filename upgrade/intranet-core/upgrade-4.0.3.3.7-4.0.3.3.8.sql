-- 
-- 
-- 
-- Copyright (c) 2013, cognovís GmbH, Hamburg, Germany
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

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.3.7-4.0.3.3.8.sql','');

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


-- Add a checkbox column to the ProjectHiearchyPortlet.
-- The column is only visible if $bulk_actions_p=1

delete from im_view_columns where column_id = 2500;

insert into im_view_columns (view_id, column_id, sort_order, column_name, column_render_tcl, visible_for)
values (25,2500,0,'<input type=checkbox name=_dummy onclick="acs_ListCheckAll(''hierarchy_project_id'',this.checked)">','$select_checkbox', 'expr $bulk_actions_p');


