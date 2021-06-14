-- 4.1.0.1.0-4.1.0.1.1.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.0.1.0-4.1.0.1.1.sql','');


create or replace function inline_0 () 
returns integer as $body$
DECLARE
	v_count			integer;
BEGIN
	select	count(*) into v_count 
	from	pg_constraint
	where	conname = 'im_projects_parent_ck';

	IF v_count > 0  THEN return 1; END IF; 

	-- Remove any offending entries.
	-- These entries will appear as main projects
	UPDATE im_projects
	SET parent_id = NULL
	WHERE parent_id = project_id;

	ALTER TABLE im_projects
	ADD CONSTRAINT im_projects_parent_ck
	CHECK (parent_id != project_id);

	return 0;
END;$body$ language 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();


