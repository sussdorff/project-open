-- upgrade-3.2.8.0.0-3.2.9.0.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-3.2.8.0.0-3.2.9.0.0.sql','');


-- Update all im_hours logged hours with the
-- current hourly rate of employees
--
create or replace function inline_0 () returns integer as '
DECLARE
        row             RECORD;
BEGIN
        for row in
		select	employee_id,
			hourly_cost,
			currency
		from	im_employees
		where	hourly_cost is not null

        loop

		update	im_hours
		set
			billing_rate = row.hourly_cost,
			billing_currency = row.currency
		where
			user_id = row.employee_id
			and billing_rate is null;

        end loop;

        return 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();

