--
-- packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.1.0.1.1-4.1.0.1.2.sql
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

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.1.0.1.1-4.1.0.1.2.sql','');

SELECT im_dynfield_widget__new (
       null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null, 'cost_templates', '#intranet-core.Templates#', '#intranet-core.Templates#',
       10007, 'integer', 'im_category_tree', 'integer',
       '{custom {category_type "Intranet Cost Template"}}'
);

-- Cost Center Templates

create or replace function inline_0 ()
returns integer as $body$
declare
        v_count  integer;
begin
        select count(*) into v_count from user_tab_columns
    where lower(table_name) = 'im_cost_centers' and lower(column_name) = 'default_quote_template_id';

        IF v_count = 0 THEN
               alter table im_cost_centers add column default_quote_template_id integer
              constraint im_cc_quote_template_fk references im_categories;
	      perform im_dynfield_attribute_new(
	          'im_cost_center',
		  'default_quote_template_id',
    		  'Template for Quote',
    		  'cost_templates',
    		  'integer',
    		  'f',
    		  '10',
    		  'f',
    		  'im_cost_centers'
		  );
        END IF;

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

create or replace function inline_0 ()
returns integer as $body$
declare
        v_count  integer;
begin
        select count(*) into v_count from user_tab_columns
    where lower(table_name) = 'im_cost_centers' and lower(column_name) = 'default_invoice_template_id';

        IF v_count = 0 THEN
               alter table im_cost_centers add column default_invoice_template_id integer
              constraint im_cc_invoice_template_fk references im_categories;
	      perform im_dynfield_attribute_new(
	          'im_cost_center',
		  'default_invoice_template_id',
    		  'Template for Invoice',
    		  'cost_templates',
    		  'integer',
    		  'f',
    		  '10',
    		  'f',
    		  'im_cost_centers'
		  );
        END IF;

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

create or replace function inline_0 ()
returns integer as $body$
declare
        v_count  integer;
begin
        select count(*) into v_count from user_tab_columns
    where lower(table_name) = 'im_cost_centers' and lower(column_name) = 'default_po_template_id';

        IF v_count = 0 THEN
               alter table im_cost_centers add column default_po_template_id integer
              constraint im_cc_po_template_fk references im_categories;
	      perform im_dynfield_attribute_new(
	          'im_cost_center',
		  'default_po_template_id',
    		  'Template for Po',
    		  'cost_templates',
    		  'integer',
    		  'f',
    		  '10',
    		  'f',
    		  'im_cost_centers'
		  );
        END IF;

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

create or replace function inline_0 ()
returns integer as $body$
declare
        v_count  integer;
begin
        select count(*) into v_count from user_tab_columns
    where lower(table_name) = 'im_cost_centers' and lower(column_name) = 'default_bill_template_id';

        IF v_count = 0 THEN
               alter table im_cost_centers add column default_bill_template_id integer
              constraint im_cc_bill_template_fk references im_categories;
	      perform im_dynfield_attribute_new(
	          'im_cost_center',
		  'default_bill_template_id',
    		  'Template for Bill',
    		  'cost_templates',
    		  'integer',
    		  'f',
    		  '10',
    		  'f',
    		  'im_cost_centers'
		  );
        END IF;

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

create or replace function inline_0 ()
returns integer as $body$
declare
        v_count  integer;
begin
        select count(*) into v_count from user_tab_columns
    where lower(table_name) = 'im_cost_centers' and lower(column_name) = 'default_correction_template_id';

        IF v_count = 0 THEN
               alter table im_cost_centers add column default_correction_template_id integer
              constraint im_cc_correction_template_fk references im_categories;
	      perform im_dynfield_attribute_new(
	          'im_cost_center',
		  'default_correction_template_id',
    		  'Template for Correction Invoice',
    		  'cost_templates',
    		  'integer',
    		  'f',
    		  '10',
    		  'f',
    		  'im_cost_centers'
		  );
        END IF;
        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();
