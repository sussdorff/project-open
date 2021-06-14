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

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-4.0.3.3.3-4.0.3.3.4.sql','');

create or replace function inline_0 ()
returns integer as $body$
declare
        v_count  integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = 'im_costs' and lower(column_name) = 'payment_term_id';

        IF v_count = 0 THEN
  	      alter table im_costs add column payment_term_id integer;
        END IF;

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

-- Update the payment_term_id accordingly for companies
create or replace function inline_0 ()
returns integer as $body$
declare
        v_count  integer;
	v_category_id integer;
	row record;
begin
	FOR row IN 
	   select cost_id, payment_days from im_costs where payment_days is not null
        LOOP
	   select category_id into v_category_id from im_categories where aux_int1 = row.payment_days and category_type = 'Intranet Payment Term';
	   update im_costs set payment_term_id = v_category_id where cost_id = row.cost_id;
        END LOOP;

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

alter table im_costs add constraint im_costs_payment_term_id_fk foreign key (payment_term_id) references im_categories(category_id);
alter table im_costs add constraint im_costs_vat_type_id_fk foreign key (vat_type_id) references im_categories(category_id);
