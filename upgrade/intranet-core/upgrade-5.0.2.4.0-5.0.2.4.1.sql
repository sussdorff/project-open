-- upgrade-5.0.2.4.0-5.0.2.4.1.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.2.4.0-5.0.2.4.1.sql','');



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

	alter table im_audits
		add audit_baseline_id integer;


-- fraber 180312: leave this for if its actually used...
--		constraint im_audits_baseline_fk
--		references im_baselines;	
	-- Speedup lookup for baselines
--	create index im_auditsbaselines_idx on im_audits(audit_baseline_id);

	return 0;
END;$body$ language 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();

