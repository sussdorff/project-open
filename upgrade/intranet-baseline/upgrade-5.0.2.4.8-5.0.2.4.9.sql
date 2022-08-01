-- upgrade-5.0.2.4.8-5.0.2.4.9.sql
SELECT acs_log__debug('/packages/intranet-baseline/sql/postgresql/upgrade/upgrade-5.0.2.4.8-5.0.2.4.9.sql','');


create or replace function inline_0 () 
returns integer as $body$
DECLARE
	v_count			integer;
BEGIN
	-- Check if colum exists in the database
	select	count(*) into v_count from user_tab_columns 
	where	lower(table_name) = 'im_audits' and
		lower(column_name) = 'audit_baseline_id';
	IF v_count > 0  THEN return 1; END IF; 

	alter table im_audits drop constraint if exists im_audits_baseline_fk;
	drop index if exists im_audits_baselines_idx;

	alter table im_audits add audit_baseline_id integer;
	alter table im_audits add constraint im_audits_baseline_fk
		foreign key (audit_baseline_id)
		references im_baselines;
		
	-- Speedup lookup for baselines
	create index im_audits_baselines_idx on im_audits(audit_baseline_id);

	return 0;
END;$body$ language 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();


