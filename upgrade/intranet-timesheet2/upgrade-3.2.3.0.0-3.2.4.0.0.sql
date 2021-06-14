-- upgrade-3.2.3.0.0-3.2.4.0.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-3.2.3.0.0-3.2.4.0.0.sql','');


-- Add a new column "cost_id" to im_hours, in order
-- to store the associated cost item:



create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = ''im_hours'' and lower(column_name) = ''cost_id'';
        IF v_count > 0 THEN return 0; END IF;

	alter table im_hours add cost_id integer;
	alter table im_hours add constraint im_hours_cost_fk
		foreign key (cost_id) references im_costs;

        return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();



-- Set the "cause_object_id" of all existing timesheet
-- cost items to the objects creation_user. That works
-- only with the "old" timesheet costs that have been
-- created by the user itself.
update im_costs set cause_object_id = (
	select creation_user
	from acs_objects
	where object_id = cost_id
)
where cost_type_id = 3718;


-- Try to associate im_cost elements to the corresponding
-- im_hours entries.
update im_hours set cost_id = (
	select	c.cost_id
	from	im_costs c
	where
		c.cost_type_id = 3718
		and c.effective_date::date = im_hours.day::date
		and c.cause_object_id = im_hours.user_id
		and c.project_id = im_hours.project_id
)
where cost_id is null;
