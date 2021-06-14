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

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.3.8-4.0.3.3.9.sql','');

SELECT im_dynfield_widget__new (
                null,                   -- widget_id
                'im_dynfield_widget',   -- object_type
                now(),                  -- creation_date
                null,                   -- creation_user
                null,                   -- creation_ip
                null,                   -- context_id
                'vat_type',              -- widget_name
                '#intranet-core.VAT#',      -- pretty_name
                '#intranet-core.VAT#',      -- pretty_plural
                10007,                  -- storage_type_id
                'integer',              -- acs_datatype
                'im_category_tree',             -- widget
                'integer',              -- sql_datatype
                '{custom {category_type "Intranet VAT Type"}}', 
                'im_name_from_id'
);

-- Widget for the payment terms
SELECT im_dynfield_widget__new (
                null,                   -- widget_id
                'im_dynfield_widget',   -- object_type
                now(),                  -- creation_date
                null,                   -- creation_user
                null,                   -- creation_ip
                null,                   -- context_id
                'payment_term',              -- widget_name
                '#intranet-core.Payment_Term#',      -- pretty_name
                '#intranet-core.Payment_Term#',      -- pretty_plural
                10007,                  -- storage_type_id
                'integer',              -- acs_datatype
                'im_category_tree',             -- widget
                'integer',              -- sql_datatype
                '{custom {category_type "Intranet Payment Term"}}', 
                'im_name_from_id'
);

create or replace function inline_0 ()
returns integer as $body$
declare
        v_count  integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = 'im_companies' and lower(column_name) = 'payment_term_id';

        IF v_count = 0 THEN
  	      alter table im_companies add column payment_term_id integer;
        END IF;

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN

	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''im_company'',			-- object_type
		 ''payment_term_id'',			-- column_name
		 ''#intranet-core.Payment_Term#'',	-- pretty_name
		 ''payment_term'',			-- widget_name
		 ''integer'',				-- acs_datatype
		 ''t'',					-- required_p   
		 100,					-- pos y
		 ''f'',					-- also_hard_coded
		 ''im_companies''			-- table_name
	  );

	  

	IF v_attribute_id != 1 THEN
	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_type = ''Intranet Company Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',''Choose the appropriate Payment Terms'',null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;
        END IF;

	RETURN 0;
END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();

-- Add the categories for the default payment days
create or replace function inline_0 ()
returns integer as $body$
declare
        row     	record;
	v_category_id   integer;
begin
	FOR row IN 
	        select distinct(default_payment_days) from im_companies where default_payment_days is not null union
	        select distinct(payment_days) as default_payment_days from im_costs where payment_days is not null                
	LOOP
		select 80100 + row.default_payment_days into v_category_id;
		perform im_category_new (v_category_id, row.default_payment_days ::varchar || ' days', 'Intranet Payment Term');		
		update im_categories set aux_int1 = row.default_payment_days where category_id = v_category_id;
	END LOOP;

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
	   select company_id, default_payment_days from im_companies where default_payment_days is not null
        LOOP
	   select category_id into v_category_id from im_categories where aux_int1 = row.default_payment_days and category_type = 'Intranet Payment Term';
	   update im_companies set payment_term_id = v_category_id where company_id = row.company_id;
        END LOOP;

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
        where lower(table_name) = 'im_companies' and lower(column_name) = 'vat_type_id';

        IF v_count = 0 THEN
  	      alter table im_companies add column vat_type_id integer;
        END IF;

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


-- tax classification
CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE
	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_count			integer;
	row			record;
BEGIN

	  v_attribute_id := im_dynfield_attribute_new (
	  	 ''im_company'',			-- object_type
		 ''vat_type_id'',			-- column_name
		 ''#intranet-core.Tax_classification#'',	-- pretty_name
		 ''vat_type'',			-- widget_name
		 ''integer'',				-- acs_datatype
		 ''t'',					-- required_p   
		 90,					-- pos y
		 ''f'',					-- also_hard_coded
		 ''im_companies''			-- table_name
	  );

	  

	IF v_attribute_id != 1 THEN
	FOR row IN 
		SELECT category_id FROM im_categories WHERE category_type = ''Intranet Company Type''
	LOOP
			
		SELECT count(*) INTO v_count FROM im_dynfield_type_attribute_map WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		IF v_count = 0 THEN
		   INSERT INTO im_dynfield_type_attribute_map
		   	  (attribute_id, object_type_id, display_mode, help_text,section_heading,default_value,required_p)
		   VALUES
			  (v_attribute_id, row.category_id,''edit'',''Choose the appropriate Tax Classification'',null,null,''f'');
		ELSE
		   UPDATE im_dynfield_type_attribute_map SET display_mode = ''edit'', required_p = ''f'' WHERE attribute_id = v_attribute_id AND object_type_id = row.category_id;
		END IF;

	END LOOP;
        END IF;

	RETURN 0;
END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();

alter table im_companies add constraint im_companies_payment_term_id_fk foreign key (payment_term_id) references im_categories(category_id);
alter table im_companies add constraint im_companies_vat_type_id_fk foreign key (vat_type_id) references im_categories(category_id);

-- Remove the dynfield for payment_days
create or replace function inline_0 ()
returns integer as $body$
declare
        v_count  integer;
	v_attribute_id integer;
begin

        select attribute_id into v_attribute_id from im_dynfield_attributes
        where acs_attribute_id = (select attribute_id from acs_attributes where attribute_name = 'default_payment_days' and object_type = 'im_company');
	   perform im_dynfield_attribute__del(v_attribute_id);

        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();
