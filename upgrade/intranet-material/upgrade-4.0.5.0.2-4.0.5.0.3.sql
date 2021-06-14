-- upgrade-4.0.5.0.2-4.0.5.0.3.sql

SELECT acs_log__debug('/packages/intranet-material/sql/postgresql/upgrade/upgrade-4.0.5.0.2-4.0.5.0.3.sql','');



create or replace view im_material_types as 
select	category_id as material_type_id, 
	category as material_type
from	im_categories 
where	category_type = 'Intranet Material Type' and
	(enabled_p is null or enabled_p = 't');

