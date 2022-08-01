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
-- @author Malte Sussdorff (malte.sussdorff@cognovis.de)
-- @creation-date 2013-01-18
-- @cvs-id $Id$
--

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.0.3.0.3-4.0.3.0.4.sql','');

-- Add a new DynView Type for the invoice list page.
SELECT im_category_new ('1450', 'List - Invoice', 'Intranet DynView Type');

-- Update the existing list type
update im_views set view_type_id = 1450 where view_name like 'invoice%' and view_type_id is null;
update im_views set view_type_id = null where view_name in ('invoice_new','invoice_select','invoice_list_subtotal');
update im_views set view_label = 'Provider List' where view_name = 'invoice_provider_list';
update im_views set view_label = 'Customer List' where view_name = 'invoice_customer_list';
update im_views set view_label = 'Invoice List' where view_name = 'invoice_list';

