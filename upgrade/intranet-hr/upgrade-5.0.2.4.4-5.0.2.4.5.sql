-- upgrade-5.0.2.4.4-5.0.2.4.5.sql
SELECT acs_log__debug('/packages/intranet-hr/sql/postgresql/upgrade/upgrade-5.0.2.4.4-5.0.2.4.5.sql','');


create or replace view im_employee_pipeline_states as
select category_id as state_id, category as state
from im_categories
where category_type = 'Intranet Employee Pipeline State' and 
(enabled_p is null OR enabled_p = 't');

