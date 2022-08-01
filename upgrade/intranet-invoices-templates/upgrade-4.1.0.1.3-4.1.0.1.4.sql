--
-- packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.1.0.1.3-4.1.0.1.4.sql
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

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.1.0.1.3-4.1.0.1.4.sql','');

-- Update mails
update im_categories set aux_string1 = (select message from lang_messages where message_key like 'invoice_email_subject_3700' and locale='de_DE') where aux_int1=3700 and category like '%.de%';
update im_categories set aux_string1 = (select message from lang_messages where message_key like 'invoice_email_subject_3700' and locale='en_US') where aux_int1=3700 and category like '%.en%';
update im_categories set aux_string1 = (select message from lang_messages where message_key like 'invoice_email_subject_3702' and locale='de_DE') where aux_int1=3702 and category like '%.de%';
update im_categories set aux_string1 = (select message from lang_messages where message_key like 'invoice_email_subject_3702' and locale='en_US') where aux_int1=3702 and category like '%.en%';
update im_categories set aux_string1 = (select message from lang_messages where message_key like 'invoice_email_subject_3704' and locale='de_DE') where aux_int1=3704 and category like '%.de%';
update im_categories set aux_string1 = (select message from lang_messages where message_key like 'invoice_email_subject_3704' and locale='en_US') where aux_int1=3704 and category like '%.en%';
update im_categories set aux_string1 = (select message from lang_messages where message_key like 'invoice_email_subject_3706' and locale='de_DE') where aux_int1=3706 and category like '%.de%';
update im_categories set aux_string1 = (select message from lang_messages where message_key like 'invoice_email_subject_3706' and locale='en_US') where aux_int1=3706 and category like '%.en%';
update im_categories set aux_string1 = (select message from lang_messages where message_key like 'invoice_email_subject_3725' and locale='de_DE') where aux_int1=3725 and category like '%.de%';
update im_categories set aux_string1 = (select message from lang_messages where message_key like 'invoice_email_subject_3725' and locale='en_US') where aux_int1=3725 and category like '%.en%';
update im_categories set aux_string1 = (select message from lang_messages where message_key like 'invoice_email_subject_3724' and locale='de_DE') where aux_int1=3724 and category like '%.de%';
update im_categories set aux_string1 = (select message from lang_messages where message_key like 'invoice_email_subject_3724' and locale='en_US') where aux_int1=3724 and category like '%.en%';
update im_categories set aux_string1 = (select message from lang_messages where message_key like 'invoice_email_subject_3734' and locale='de_DE') where aux_int1=3734 and category like '%.de%';
update im_categories set aux_string1 = (select message from lang_messages where message_key like 'invoice_email_subject_3734' and locale='en_US') where aux_int1=3734 and category like '%.en%';
update im_categories set aux_string1 = (select message from lang_messages where message_key like 'invoice_email_subject_3735' and locale='de_DE') where aux_int1=3735 and category like '%.de%';
update im_categories set aux_string1 = (select message from lang_messages where message_key like 'invoice_email_subject_3735' and locale='en_US') where aux_int1=3735 and category like '%.en%';


update im_categories set aux_html1 = (select message from lang_messages where message_key like 'invoice_email_body_3700' and locale='de_DE') where aux_int1=3700 and category like '%.de%';
update im_categories set aux_html1 = (select message from lang_messages where message_key like 'invoice_email_body_3700' and locale='en_US') where aux_int1=3700 and category like '%.en%';
update im_categories set aux_html1 = (select message from lang_messages where message_key like 'invoice_email_body_3702' and locale='de_DE') where aux_int1=3702 and category like '%.de%';
update im_categories set aux_html1 = (select message from lang_messages where message_key like 'invoice_email_body_3702' and locale='en_US') where aux_int1=3702 and category like '%.en%';
update im_categories set aux_html1 = (select message from lang_messages where message_key like 'invoice_email_body_3704' and locale='de_DE') where aux_int1=3704 and category like '%.de%';
update im_categories set aux_html1 = (select message from lang_messages where message_key like 'invoice_email_body_3704' and locale='en_US') where aux_int1=3704 and category like '%.en%';
update im_categories set aux_html1 = (select message from lang_messages where message_key like 'invoice_email_body_3706' and locale='de_DE') where aux_int1=3706 and category like '%.de%';
update im_categories set aux_html1 = (select message from lang_messages where message_key like 'invoice_email_body_3706' and locale='en_US') where aux_int1=3706 and category like '%.en%';
update im_categories set aux_html1 = (select message from lang_messages where message_key like 'invoice_email_body_3725' and locale='de_DE') where aux_int1=3725 and category like '%.de%';
update im_categories set aux_html1 = (select message from lang_messages where message_key like 'invoice_email_body_3725' and locale='en_US') where aux_int1=3725 and category like '%.en%';
update im_categories set aux_html1 = (select message from lang_messages where message_key like 'invoice_email_body_3724' and locale='de_DE') where aux_int1=3724 and category like '%.de%';
update im_categories set aux_html1 = (select message from lang_messages where message_key like 'invoice_email_body_3724' and locale='en_US') where aux_int1=3724 and category like '%.en%';
update im_categories set aux_html1 = (select message from lang_messages where message_key like 'invoice_email_body_3734' and locale='de_DE') where aux_int1=3734 and category like '%.de%';
update im_categories set aux_html1 = (select message from lang_messages where message_key like 'invoice_email_body_3734' and locale='en_US') where aux_int1=3734 and category like '%.en%';
update im_categories set aux_html1 = (select message from lang_messages where message_key like 'invoice_email_body_3735' and locale='de_DE') where aux_int1=3735 and category like '%.de%';
update im_categories set aux_html1 = (select message from lang_messages where message_key like 'invoice_email_body_3735' and locale='en_US') where aux_int1=3735 and category like '%.en%';
