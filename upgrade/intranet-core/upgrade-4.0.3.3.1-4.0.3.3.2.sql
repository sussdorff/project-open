-- upgrade-4.0.3.3.1-4.0.3.3.2.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.3.1-4.0.3.3.2.sql','');


create or replace function im_project_id_parent_list(int4) returns varchar as '
    DECLARE
	p_project_id		alias for $1;
    BEGIN
	RETURN im_project_id_parent_list(p_project_id, '''', 0);
    END; ' language 'plpgsql';


create or replace function im_project_id_parent_list(int4,varchar,int4) returns varchar as '

    DECLARE
	p_project_id		alias for $1;
    	p_parent_id_list      	alias for $2;
	p_counter		alias for $3; 
    
	v_result		varchar;
    	v_parent_id		integer;
	v_counter		integer;
	v_parent_id_list	varchar; 

    BEGIN
   
	-- Avoid infinite loops
   	IF p_counter > 50 THEN RETURN ''Infinite loop with project_id='' || p_project_id; END IF;
   
	-- Get parent_id
   	select p.parent_id
   	into   v_parent_id
   	from   im_projects p 
   	where  p.project_id = p_project_id;

	-- RAISE NOTICE ''im_project_id_parent_list found parent_id: %'', v_parent_id;

    	IF v_parent_id is null THEN 
	   RETURN p_parent_id_list; 
	ELSE   	
	   v_parent_id_list := p_parent_id_list || '' '' || v_parent_id;
	   v_result = im_project_id_parent_list(v_parent_id, v_parent_id_list, p_counter+1);	   
	   RETURN v_result;
	END IF;
   END; ' language 'plpgsql';