-- upgrade-4.0.3.2.1-4.0.3.2.2.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.2.1-4.0.3.2.2.sql','');

CREATE OR REPLACE FUNCTION im_project_change_company_id_of_childs(integer)
returns integer as '

declare
        v_project_id            alias for $1;
        v_company_id_root_node  integer;
        r                       record;
begin
        -- get company_id from root node
        select company_id into v_company_id_root_node from im_projects where project_id = v_project_id;

        -- Set company_id of all childs of root node to company_id of root node
        FOR r IN
                select
                    p_child.project_id
                from
                    im_projects p_parent,
                    im_projects p_child
                where
                    p_child.tree_sortkey between p_parent.tree_sortkey and tree_right(p_parent.tree_sortkey)
                    and p_parent.project_id = v_project_id
        LOOP
                update im_projects
                        set company_id = v_company_id_root_node
                where project_id = r.project_id;
        END LOOP;
        return 0;
end;' language 'plpgsql' VOLATILE;


CREATE OR REPLACE FUNCTION im_project_change_company_id_of_childs_all()
returns integer as '

declare
        r                       record;
begin

        -- Set company_id of all childs of root node to company_id of root node
        FOR r IN

        select distinct
                parent.project_id
        from
                im_projects parent,
                im_projects child,
                im_companies parent_cust,
                im_companies child_cust
        where
                parent.company_id != child.company_id and
                child.tree_sortkey between parent.tree_sortkey and tree_right(parent.tree_sortkey) and
                parent.parent_id is null and
                child.parent_id is not null and
                parent.company_id = parent_cust.company_id and
                child.company_id = child_cust.company_id
        LOOP
                perform im_project_change_company_id_of_childs(r.project_id);
        END LOOP;
        return 0;
end;' language 'plpgsql' VOLATILE;
