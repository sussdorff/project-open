-- upgrade-3.4.0.7.1-3.4.0.7.2.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-3.4.0.7.1-3.4.0.7.2.sql','');


-- 42000-42999  Intranet VAT Type (1000)
--
-- Simple VAT setup for service company.
-- The setup defines three areas (Domestic = transactions within
-- the same country, EU and Internatinal) plus the different types
-- of VAT applicable to each of the areas.
-- These tax types are each associated with a numeric value in the
-- im_categories.aux_int1 field that specifies the applicable tax
-- (0, 7 or 19 in this case).

SELECT im_category_new(42000, 'Domestic 0%', 'Intranet VAT Type');
SELECT im_category_new(42010, 'Domestic 7%', 'Intranet VAT Type');
SELECT im_category_new(42020, 'Domestic 16%', 'Intranet VAT Type');
SELECT im_category_new(42030, 'Europe 0%', 'Intranet VAT Type');
SELECT im_category_new(42040, 'Europe 16%', 'Intranet VAT Type');
SELECT im_category_new(42050, 'Internat. 0%', 'Intranet VAT Type');


update im_categories set aux_int1 = 0 where category_id = 42000;
update im_categories set aux_int1 = 7 where category_id = 42010;
update im_categories set aux_int1 = 16 where category_id = 42020;
update im_categories set aux_int1 = 0 where category_id = 42030;
update im_categories set aux_int1 = 16 where category_id = 42040;
update im_categories set aux_int1 = 0 where category_id = 42050;



create or replace view im_vat_types as
select	category_id as vat_type_id,
	category as vat_type,
	aux_int1 as vat
from	im_categories
where	category_type = 'Intranet VAT Type';



create or replace function inline_0()
returns integer as '
DECLARE
        v_count			integer;
BEGIN
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = ''im_costs'' and lower(column_name) = ''vat_type_id'';
	IF v_count > 0 THEN return 1; END IF;

	alter table im_costs 
	add column vat_type_id	integer
				constraint im_cost_vat_type_fk
				references im_categories;


        return 0;
END;' language 'plpgsql';
select inline_0();
drop function inline_0();

