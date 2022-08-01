-- 
-- packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.1.0.0.1-4.1.0.0.2.sql
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
-- @author <yourname> (<your email>)
-- @creation-date 2012-01-06
-- @cvs-id $Id$
--

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.1.0.0.1-4.1.0.0.2.sql','');

select im_dynfield_attribute_new(
    'im_company',
    'default_quote_template_id',
    'Default Quote Template',
    'category_invoice_template',
    'integer',
    'f',
    '10',
    'f'
);

