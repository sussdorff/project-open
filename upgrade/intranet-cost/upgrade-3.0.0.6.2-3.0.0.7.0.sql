-- upgrade-3.0.0.6.2-3.0.0.7.0.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-3.0.0.6.2-3.0.0.7.0.sql','');


--
-- Fix the ID column of the im_repeating_cost
-- datatype. Before it was "cost_id"...
--

update acs_object_types 
set id_column = 'rep_cost_id' 
where object_type = 'im_repeating_cost';


--
-- Define delete and name functions for repeating_costs.
-- This is needed in order to be able to delete costs
-- orderly for /users/nuke.tcl
--

-- Delete a single cost (if we know its ID...)
create or replace function im_repeating_cost__delete (integer)
returns integer as '
DECLARE
        p_cost_id alias for $1;
begin
        -- Erase the im_repeating_costs entry
        delete from     im_repeating_costs
        where           rep_cost_id = p_cost_id;

        -- Erase the object
        PERFORM im_cost__delete(p_cost_id);
        return 0;
end' language 'plpgsql';


create or replace function im_repeating_cost__name (integer)
returns varchar as '
DECLARE
        p_cost_id  alias for $1;        -- cost_id
        v_name  varchar(40);
    begin
        select  cost_name
        into    v_name
        from    im_costs
        where   cost_id = p_cost_id;

        return v_name;
end;' language 'plpgsql';


