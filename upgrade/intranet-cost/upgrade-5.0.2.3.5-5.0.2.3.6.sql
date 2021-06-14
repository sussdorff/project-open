-- 5.0.2.3.5-5.0.2.3.6.sql
SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-5.0.2.3.5-5.0.2.3.6.sql','');


-- Delete a single cost (if we know its ID...)
create or replace function im_cost__delete (integer)
returns integer as $$
DECLARE
	p_cost_id alias for $1;
begin
	-- Update im_hours relationship
	update	im_hours
	set	cost_id = null
	where	cost_id = p_cost_id;

	-- Erase payments related to this cost item
	delete from im_payments
	where cost_id = p_cost_id;

	-- Erase the im_cost
	delete from im_costs
	where cost_id = p_cost_id;

	-- Erase the im_cost
	delete from im_biz_objects
	where object_id = p_cost_id;

	-- Erase the acs_rels entries pointing to this cost item
	delete	from acs_rels
	where	object_id_two = p_cost_id;
	delete	from acs_rels
	where	object_id_one = p_cost_id;

	delete from acs_permissions 
	where object_id = p_cost_id;

	-- Erase the object
	PERFORM acs_object__delete(p_cost_id);
	return 0;
end;$$ language 'plpgsql';

