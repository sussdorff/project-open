-- upgrade-3.3.1.2.0-3.3.1.2.1.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-3.3.1.2.0-3.3.1.2.1.sql','');

-- -----------------------------------------------------------------------------
-- Fix the timesheet localization isse
-- -----------------------------------------------------------------------------


update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-timesheet2.Timesheet "Timesheet"' 
where title_tcl = 'lang::message::lookup "" intranet-timesheet.Timesheet "Timesheet"'
;


-- -----------------------------------------------------------------------------
-- Delete invalide acs_rels between costs and groups
-- -----------------------------------------------------------------------------


-- Delete all invalid links between cost items and groups.
delete	from acs_rels
where	rel_id in (

		select	rel_id
		from	acs_rels
		where	object_id_two in (select cost_id from im_costs) and
			object_id_one in (select group_id from groups)
	);


-- Delete all acs_object (parents) where the entry in acs_rels has been deleted.
delete	from acs_objects 
where	object_type = 'relationship' and 
	object_id in (
		select	object_id 
		from	acs_objects 
		where	object_type = 'relationship' and 
			object_id not in (
				select rel_id 
				from acs_rels
			)
);

-- Reset all wrong references to parties from im_cost
update	im_costs
set	project_id = null
where	project_id in (
		select	party_id
		from	parties
	);

-- Reset references to projects that got deleted
update	im_costs
set	project_id = null
where	project_id not in (
		select	project_id
		from	im_projects
	);



-- -----------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------

-- drop constraint if exists...
create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from pg_constraint
	where lower(conname) = ''im_costs_project_fk'';
	IF v_count = 0 THEN return 0; END IF;

	ALTER TABLE im_costs drop constraint im_costs_project_fk;

	return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();



ALTER TABLE im_costs
ADD constraint im_costs_project_fk foreign key (project_id) references im_projects;


-- -----------------------------------------------------------------------------
-- Fix issue in V33 because there we already used "expense_bundle" instead of
-- "expense_report"
-- -----------------------------------------------------------------------------

create or replace view im_cost_types as
select  category_id as cost_type_id,
        category as cost_type,
        CASE
            WHEN category_id = 3700 THEN 'fi_read_invoices'
            WHEN category_id = 3702 THEN 'fi_read_quotes'
            WHEN category_id = 3704 THEN 'fi_read_bills'
            WHEN category_id = 3706 THEN 'fi_read_pos'
            WHEN category_id = 3716 THEN 'fi_read_repeatings'
            WHEN category_id = 3718 THEN 'fi_read_timesheets'
            WHEN category_id = 3720 THEN 'fi_read_expense_items'
            WHEN category_id = 3722 THEN 'fi_read_expense_reports'
            WHEN category_id = 3724 THEN 'fi_read_delivery_notes'
            ELSE 'fi_read_all'
        END as read_privilege,
        CASE
            WHEN category_id = 3700 THEN 'fi_write_invoices'
            WHEN category_id = 3702 THEN 'fi_write_quotes'
            WHEN category_id = 3704 THEN 'fi_write_bills'
            WHEN category_id = 3706 THEN 'fi_write_pos'
            WHEN category_id = 3716 THEN 'fi_write_repeatings'
            WHEN category_id = 3718 THEN 'fi_write_timesheets'
            WHEN category_id = 3720 THEN 'fi_write_expense_items'
            WHEN category_id = 3722 THEN 'fi_write_expense_reports'
            WHEN category_id = 3724 THEN 'fi_write_delivery_notes'
            ELSE 'fi_write_all'
        END as write_privilege,
        CASE
            WHEN category_id = 3700 THEN 'invoice'
            WHEN category_id = 3702 THEN 'quote'
            WHEN category_id = 3704 THEN 'bill'
            WHEN category_id = 3706 THEN 'po'
            WHEN category_id = 3716 THEN 'repcost'
            WHEN category_id = 3718 THEN 'timesheet'
            WHEN category_id = 3720 THEN 'expitem'
            WHEN category_id = 3722 THEN 'expbundle'
            WHEN category_id = 3724 THEN 'delnote'
            ELSE 'unknown'
        END as short_name
from    im_categories
where   category_type = 'Intranet Cost Type';




-- drop constraint if exists...
create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from pg_trigger
	where lower(tgname) = ''im_payments_audit_tr'';
	IF v_count = 0 THEN return 0; END IF;

	drop trigger im_payments_audit_tr on im_payments;

	return v_count;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();


create trigger im_payments_audit_tr
after update or delete
on im_payments
for each row execute procedure im_payments_audit_tr();

