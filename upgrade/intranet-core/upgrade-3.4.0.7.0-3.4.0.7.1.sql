-- upgrade-3.4.0.7.0-3.4.0.7.1.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.7.0-3.4.0.7.1.sql','');



create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = ''im_projects_audit'';
	IF v_count = 0 THEN RETURN 1; END IF;

	drop table im_projects_audit;

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



create table im_projects_audit (
        modifying_action		varchar(20),
        last_modified			timestamptz,
        last_modifying_user		integer,
	last_modifying_ip		varchar(50),

	project_id			integer,
	project_name			text,
	project_nr			text,
	project_path			text,
	parent_id			integer,
	company_id			integer,
	project_type_id			integer,
	project_status_id		integer,
	description			text,
	billing_type_id			integer,
	note				text,
	project_lead_id			integer,
	supervisor_id			integer,
	project_budget			float,
	corporate_sponsor		integer,
	percent_completed		float,
	on_track_status_id		integer,
	project_budget_currency		character(3),
	project_budget_hours		float,
	end_date			timestamptz,
	start_date			timestamptz,
	company_contact_id		integer,
	company_project_nr		text,
	cost_invoices_cache		float,	
	cost_quotes_cache		float,		
	cost_delivery_notes_cache	float,
	cost_bills_cache		float,	
	cost_purchase_orders_cache	float,	
	cost_timesheet_planned_cache	float,	
	cost_timesheet_logged_cache	float,
	cost_expense_planned_cache	float,	
	cost_expense_logged_cache	float,
	reported_hours_cache		float
);

create index im_projects_audit_project_id_idx on im_projects_audit(project_id);

