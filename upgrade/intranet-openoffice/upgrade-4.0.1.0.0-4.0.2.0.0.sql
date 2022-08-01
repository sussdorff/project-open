-- 
-- packages/intranet-openoffice/sql/postgresql/intranet-openoffice-create.sql
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
-- @creation-date 2011-11-14
-- @cvs-id $Id$
--

SELECT acs_log__debug('/packages/intranet-openoffice/sql/postgresql/upgrade/upgrade-4.0.1.0.0-4.0.2.0.0.sql','');

update im_view_columns set datatype = 'date' where column_render_tcl like '%_date%';
update im_view_columns set datatype = 'string' where datatype is null;
update im_view_columns set datatype = 'percentage' where column_render_tcl like '%percent_%';