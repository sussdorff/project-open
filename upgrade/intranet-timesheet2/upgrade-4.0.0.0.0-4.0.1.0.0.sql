-- upgrade-4.0.0.0.0-4.0.1.0.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.0.0.0.0-4.0.1.0.0.sql','');


-- ------------------------------------------------------
-- Make duration days a required field with default value = 1
-- ------------------------------------------------------


-- Add a NOT NULL constraint to im_user_absences.duration_days
update im_user_absences set duration_days=1.0 where duration_days is null;

-- Never NULL again...
-- Its OK to run this command multiple times...
ALTER TABLE im_user_absences ALTER COLUMN duration_days SET NOT NULL;

-- Set the default value for the column
-- Its OK to run this command multiple times...
ALTER TABLE im_user_absences ALTER COLUMN duration_days SET default 1.0;
