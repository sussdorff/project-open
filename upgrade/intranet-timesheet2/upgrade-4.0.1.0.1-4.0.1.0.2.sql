-- upgrade-4.0.1.0.1-4.0.1.0.2.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.0.1.0.1-4.0.1.0.2.sql','');

-- -------------------------------------------------------
-- View should only show enabled absence types 
-- -------------------------------------------------------

create or replace view im_user_absence_types as
select 	category_id as absence_type_id, 
	category as absence_type
from 	im_categories
where	category_type = 'Intranet Absence Type' and 
	(enabled_p = 't' OR enabled_p is NULL);
;
