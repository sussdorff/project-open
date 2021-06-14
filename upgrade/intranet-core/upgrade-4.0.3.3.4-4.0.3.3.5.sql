-- upgrade-4.0.3.3.4-4.0.3.3.5.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.3.4-4.0.3.3.5.sql','');

CREATE OR REPLACE FUNCTION im_project_sub_project_name_path(integer, boolean, boolean)
  RETURNS character varying AS $BODY$
declare

    -- Returns a path of project_names -> bottom-up 
    -- Output of subproject-name itself and top parent project can be surpressed 

    p_sub_project_id            alias for $1;
    p_exlude_main_project_p     alias for $2;
    p_exlude_sub_project_p      alias for $3;
 
    v_subproject_id		integer;
    v_parent_id             	integer;
    v_project_name          	varchar;
    v_ctr           		integer;
    v_path          		varchar;
    v_slash         		varchar; 
 
begin
    v_subproject_id := p_sub_project_id;
    v_ctr := 0; 
    v_path := '';

    WHILE v_ctr < 10  LOOP
        select  parent_id, project_name 
        into    v_parent_id, v_project_name
        from    im_projects p
        where   project_id = v_subproject_id;
        
        IF      
            v_parent_id is not null OR NOT p_exlude_main_project_p 
        THEN
            v_slash := '/';
            IF      '' = v_project_name
            THEN    
                    v_slash := '';
                    RAISE NOTICE 'v_project_name is empty';
            END IF; 

            IF      (v_ctr = 0 AND NOT p_exlude_sub_project_p) OR v_ctr != 0
            THEN    v_path := v_project_name || v_slash || v_path; 
            END IF; 

            v_subproject_id := v_parent_id;
        END IF;

        IF      v_parent_id is null 
        THEN    EXIT;
        ELSE 	v_ctr := v_ctr +1;
        END IF;     

    END LOOP;
    return v_path; 
 
end;$BODY$
  LANGUAGE 'plpgsql'