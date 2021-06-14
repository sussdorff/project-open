-- 
-- packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.0.1.0.2-4.0.1.0.3.sql
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
-- @creation-date 2011-04-18
-- @cvs-id $Id$
--

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.0.1.0.2-4.0.1.0.3.sql','');

update im_view_columns set column_name = '#intranet-timesheet2-tasks.CC#' where column_id = 91006;
update im_view_columns set column_name = '#intranet-timesheet2-tasks.Start#' where column_id = 91007;
update im_view_columns set column_name = '#intranet-timesheet2-tasks.End#' where column_id = 91008;
update im_view_columns set column_name = '#intranet-timesheet2-tasks.Plan#' where column_id = 91010;
update im_view_columns set column_name = '#intranet-timesheet2-tasks.Status#' where column_id = 91018;
update im_view_columns set column_name = '#intranet-timesheet2-tasks.Log#' where column_id = 91014;
update im_view_columns set column_name = '#intranet-timesheet2-tasks.Done#' where column_id = 91021