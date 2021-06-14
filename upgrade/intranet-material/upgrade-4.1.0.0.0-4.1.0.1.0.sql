
SELECT acs_log__debug('/packages/intranet-material/sql/postgresql/upgrade/upgrade-4.1.0.0.0-4.1.0.1.0.sql','');

-- Cleanup automatically generated materials, renaming them without Translation in front
-- as we can generate more than Translation Materials automatically
SELECT im_category_new(9016, 'Automatically Created', 'Intranet Material Type');
update im_materials set material_type_id = 9016 where material_type_id = 9014 and description = 'Automatically generated';
update im_materials set material_nr = overlay (material_nr placing '' from 1 for 12) where material_type_id = 9016;
update im_materials set material_name = overlay (material_name placing '' from 1 for 13) where material_type_id = 9016;
