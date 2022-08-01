-- 
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

SELECT acs_log__debug('/packages/intranet-openoffice/sql/postgresql/upgrade/upgrade-4.0.2.0.0-4.1.0.0.0.sql','');

------------------------------------------------------
-- Download Permissions
--

SELECT acs_privilege__create_privilege('oo_download_projects','OpenOffice Download Projects','OpenOffice Download Projects');
SELECT acs_privilege__add_child('admin', 'oo_download_projects');
SELECT im_priv_create('oo_download_projects', 'Senior Managers');

SELECT acs_privilege__create_privilege('oo_download_companies','OpenOffice Download Companies','OpenOffice Download Companies');
SELECT acs_privilege__add_child('admin', 'oo_download_companies');
SELECT im_priv_create('oo_download_companies', 'Senior Managers');

SELECT acs_privilege__create_privilege('oo_download_tasks','OpenOffice Download Tasks','OpenOffice Download Tasks');
SELECT acs_privilege__add_child('admin', 'oo_download_tasks');
SELECT im_priv_create('oo_download_tasks', 'Senior Managers');

SELECT acs_privilege__create_privilege('oo_download_invoices','OpenOffice Download Invoices','OpenOffice Download Invoices');
SELECT acs_privilege__add_child('admin', 'oo_download_invoices');
SELECT im_priv_create('oo_download_invoices', 'Senior Managers');

SELECT acs_privilege__create_privilege('oo_download_timesheets','OpenOffice Download Timesheets','OpenOffice Download Timesheets');
SELECT acs_privilege__add_child('admin', 'oo_download_timesheets');
SELECT im_priv_create('oo_download_timesheets', 'Senior Managers');

SELECT acs_privilege__create_privilege('oo_download_users','OpenOffice Download Users','OpenOffice Download Users');
SELECT acs_privilege__add_child('admin', 'oo_download_users');
SELECT im_priv_create('oo_download_users', 'Senior Managers');