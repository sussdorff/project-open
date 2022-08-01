-- 
-- packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.1.0.0.0-4.1.0.0.1.sql
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

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.1.0.0.0-4.1.0.0.1.sql','');

-- Absolute value of the tax in case we have penny deviations between our calculation and the accounting system
-- due to rounding issues

create or replace function inline_0() returns varchar as $body$
        DECLARE
                v_count         integer;
        BEGIN
                select count(*) into v_count from user_tab_columns
                where lower(table_name) = 'im_costs' and lower(column_name) = 'tax_amount';
                IF v_count > 0 THEN return 1; END IF;

		alter table im_costs add column tax_amount numeric(12,3);
               	return 0;
        END;
$body$ language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();

create or replace function inline_0() returns varchar as $body$
        DECLARE
                v_count         integer;
        BEGIN
                select count(*) into v_count from user_tab_columns
                where lower(table_name) = 'im_costs' and lower(column_name) = 'vat_amount';
                IF v_count > 0 THEN return 1; END IF;

		alter table im_costs add column vat_amount numeric(12,3);
               	return 0;
        END;
$body$ language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();

-- Calculate the tax amount for every cost item which is not of material based tax calculation
create or replace function inline_1 (integer)
returns integer as $body$
declare
	p_offset	alias for $1;
	row		record;
begin
	FOR row IN
		select	cost_id
		from	im_costs
		order by cost_id
		OFFSET p_offset
		LIMIT 5000
	LOOP
	     update im_costs set vat_amount = amount * (100+ vat) / 100 - amount, tax_amount = amount * (100+ tax) / 100 - amount where cost_id = row.cost_id;
	END LOOP;

	return 0;
end;$body$ language 'plpgsql';
select inline_1 (0);
select inline_1 (5000);
select inline_1 (10000);
select inline_1 (15000);
select inline_1 (20000);
select inline_1 (25000);
select inline_1 (30000);
select inline_1 (35000);
select inline_1 (40000);
select inline_1 (45000);
select inline_1 (50000);
select inline_1 (55000);
select inline_1 (60000);
select inline_1 (65000);
select inline_1 (70000);
select inline_1 (75000);
select inline_1 (80000);
select inline_1 (85000);
select inline_1 (90000);
select inline_1 (95000);
drop function inline_1 (integer);
