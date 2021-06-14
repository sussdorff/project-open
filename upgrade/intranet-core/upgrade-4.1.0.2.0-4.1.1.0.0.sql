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

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.0.2.0-4.1.1.0.0.sql','');

alter table im_offices alter column address_line1 type text;
alter table im_offices alter column address_line2 type text;
alter table im_offices alter column address_city type text;
alter table im_offices alter column address_state type text;
alter table im_offices alter column address_postal_code type text;
