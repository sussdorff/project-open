-- upgrade-3.4.0.1.0-3.4.0.2.0.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-3.4.0.1.0-3.4.0.2.0.sql','');



-- Make sure there are no cost centers with empty context_id
-- (not inheriting permissions)

update acs_objects 
set context_id = cc.parent_id 
from im_cost_centers cc 
where context_id is null and object_id = cc.cost_center_id;

