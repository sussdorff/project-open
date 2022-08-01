-- 
-- packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.0.1.0.1-4.0.1.0.2.sql
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
-- @creation-date 2012-01-27
-- @cvs-id $Id$
--

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-4.0.1.0.1-4.0.1.0.2.sql','');

create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from acs_rel_types where 
              rel_type = ''im_invoice_invoice_rel'' ;

        IF v_count > 0 THEN return 1; END IF;

	create table im_invoice_rels (
	rel_id			integer
				constraint im_invoice_rel_fk
				references acs_rels (rel_id)
				constraint im_invoice_rel_pk
				primary key,
	rel_type_id		integer not null
				constraint im_invioce_rel_type_fk
				references im_categories
	);

	perform acs_rel_type__create_type (
        ''im_invoice_invoice_rel'',         -- relationship (object) name
        ''Invoice Relation'',          -- pretty name
        ''Invoice Relations'',         -- pretty plural
        ''relationship'',                 -- supertype
        ''im_invoice_rels'',        -- table_name
        ''rel_id'',                       -- id_column
        ''im_invoice_invoice_rel'',         -- package_name
        ''im_invoice'',                   -- object_type_one
        ''member'',                       -- role_one
        0,                              -- min_n_rels_one
        null,                           -- max_n_rels_one
        ''im_invoice'',                       -- object_type_two
        ''member'',                       -- role_two
        0,                              -- min_n_rels_two
        null                            -- max_n_rels_two
       	);

        RETURN 0;

end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();
