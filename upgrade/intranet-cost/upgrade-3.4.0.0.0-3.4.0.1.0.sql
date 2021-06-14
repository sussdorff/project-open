-- /packages/intranet-cost/sql/postgres/upgrade/upgrade-3.4.0.0.0-3.4.0.1.0.sql
--
-- ]project-open[ Cost Core Upgrade
-- 040207 frank.bergmann@project-open.com
--
-- Copyright (C) 2004 - 2009 ]project-open[
--
-- All rights including reserved. To inquire license terms please
-- refer to http://www.project-open.com/modules/<module-key>

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-3.4.0.0.0-3.4.0.1.0.sql','');



update im_categories 
set category = 'Expense Bundle'
where category_id = 3722;


select acs_privilege__create_privilege('fi_read_expense_bundles','Read Expense Bundles','Read Expense Bundles');
select acs_privilege__create_privilege('fi_write_expense_bundles','Write Expense Bundles','Write Expense Bundles');
select acs_privilege__add_child('fi_read_all', 'fi_read_expense_bundles');
select acs_privilege__add_child('fi_write_all', 'fi_write_expense_bundles');



create or replace function im_cost__name (integer)
returns varchar as '
DECLARE
        p_cost_id  alias for $1;        -- cost_id
        v_name  varchar;
    begin
        select  cost_name
        into    v_name
        from    im_costs
        where   cost_id = p_cost_id;

        return v_name;
end;' language 'plpgsql';


update acs_object_types set name_method = 'im_cost__name' where object_type = 'im_cost';

