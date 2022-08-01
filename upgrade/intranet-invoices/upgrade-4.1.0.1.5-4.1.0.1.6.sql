--
-- packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.1.0.1.4-4.1.0.1.5.sql
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

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.1.0.1.5-4.1.0.1.6.sql','');

-- Update names for dynfields to differentiate in I18N
update acs_attributes set pretty_name = 'Correction Bill Template', pretty_plural = 'Correction Bill Templates' where pretty_name = 'Template for Correction Bill';
update acs_attributes set pretty_name = 'Cancellation Bill Template', pretty_plural = 'Cancellation Bill Templates' where pretty_name = 'Template for Cancellation Bill';
update acs_attributes set pretty_name = 'Correction Invoice Template', pretty_plural = 'Correction Invoice Templates' where pretty_name = 'Template for Correction Invoice';
update acs_attributes set pretty_name = 'Cancellation Invoice Template', pretty_plural = 'Cancellation Invoice Templates' where pretty_name = 'Template for Cancellation Invoice';


update im_dynfield_attributes set widget_name = 'cost_templates' where widget_name = 'category_invoice_template';


