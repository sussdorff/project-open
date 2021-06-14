-- upgrade-4.0.3.1.0-4.0.3.1.1.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-4.0.3.1.0-4.0.3.1.1.sql','');



create or replace function inline_0()
returns integer as $body$
DECLARE
	v_count		integer;
BEGIN
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_projects' and lower(column_name) = 'project_cost_center_id';
	IF v_count > 0 THEN return 1; END IF;

	alter table im_projects
	add project_cost_center_id integer
	constraint im_projects_cost_center_fk references im_cost_centers;

	update im_projects                                                                           
	set project_cost_center_id = (select e.department_id from im_employees e where e.employee_id = im_projects.project_lead_id)
	where parent_id is null and project_cost_center_id is null;

	return 0;
END;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();






create or replace function im_user_cost_centers (integer) 
returns setof integer as $body$
declare
	p_user_id		alias for $1;
	v_cc_code		varchar;
	row			RECORD;
BEGIN
	select	cc.cost_center_code into v_cc_code
	from	im_employees e, im_cost_centers cc
	where	e.employee_id = p_user_id and
		e.department_id = cc.cost_center_id;

	-- Return the list of all cost centers below the one to which the user belongs to
	FOR row IN
		select	cc.*
		from	im_cost_centers cc
		where	substring(cc.cost_center_code for length(v_cc_code)) = v_cc_code
	LOOP
		RETURN NEXT row.cost_center_id;
	END LOOP;

	RETURN;
end;$body$ language 'plpgsql';



