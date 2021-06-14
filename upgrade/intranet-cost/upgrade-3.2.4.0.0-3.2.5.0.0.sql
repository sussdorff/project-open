-- /packages/intranet-cost/sql/postgres/upgrade/upgrade-3.2.4.0.0-3.2.5.0.0.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-3.2.4.0.0-3.2.5.0.0.sql','');


-- Delete a single cost_center (if we know its ID...)
create or replace function im_cost_center__delete (integer)
returns integer as '
DECLARE
        p_cost_center_id alias for $1;  -- cost_center_id
        v_cost_center_id        integer;
begin
        -- copy the variable to desambiguate the var name
        v_cost_center_id := p_cost_center_id;

        -- Erase the im_cost_centers item associated with the id
        delete from     im_cost_centers
        where           cost_center_id = v_cost_center_id;

        -- Erase all the priviledges
        delete from     acs_permissions
        where           object_id = v_cost_center_id;

        -- Finally delete the object iself
        PERFORM acs_object__delete(v_cost_center_id);
        return 0;
end;' language 'plpgsql';
