-- upgrade-4.0.2.0.3-4.0.2.0.4.sql
SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-4.0.2.0.3-4.0.2.0.4.sql','');


-- Return a list of all cost centers below and including the specified cost center
create or replace function im_sub_cost_centers (integer)
returns setof integer as $body$
DECLARE
	p_cc_id			alias for $1;
	v_cc_id			integer;
	v_len			integer;
	v_super_cc_code		varchar;
	row			RECORD;
BEGIN
	-- Extract len and code from the super cc
	select	length(cost_center_code), cost_center_code
	into	v_len, v_super_cc_code
	from	im_cost_centers
	where	cost_center_id = p_cc_id;

	-- Return all ids of the sub ccs
	FOR row IN
		select	cc.cost_center_id
		from	im_cost_centers cc
		where	substring(cost_center_code for v_len) = v_super_cc_code
	LOOP
		RETURN NEXT row.cost_center_id;
	END LOOP;

	RETURN;
end;$body$ language 'plpgsql';


