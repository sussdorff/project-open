-- upgrade-4.0.5.0.2-4.0.5.0.3.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.0.5.0.2-4.0.5.0.3.sql','');

-- -------------------------------------------------------
-- View should only show enabled absence types 
-- -------------------------------------------------------

create or replace view im_user_absence_types as
select	category_id as absence_type_id, 
	category as absence_type
from	im_categories
where	category_type = 'Intranet Absence Type' and 
	(enabled_p = 't' OR enabled_p is NULL);
;


-- Somebody has created the wrong view im_absence_types...
CREATE OR REPLACE FUNCTION inline_0 () 
RETURNS INTEGER AS $$
declare
        v_count                 integer;
begin
        select count(*) into v_count from pg_views
	where lower(viewname) = 'im_absence_types';

	IF v_count = 0 THEN
		return 1;
        END IF;

	drop view im_absence_types;
        return 0;
end;$$ LANGUAGE 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();
