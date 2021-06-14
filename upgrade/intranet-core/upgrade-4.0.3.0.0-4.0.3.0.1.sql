-- upgrade-4.0.3.0.0-4.0.3.0.0.1.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.0.0-4.0.3.0.1.sql','');

create or replace function im_name_from_user_id(int4, int4) returns varchar as $body$
        DECLARE
        	v_user_id	alias for $1;
		v_name_order	alias for $2;
        	v_full_name	varchar(8000);
	BEGIN
		IF 2 = v_name_order THEN
			select 	last_name || ' ' || first_names
			into 	v_full_name 
			from 	persons 
			where person_id = v_user_id;
		ELSEIF 3 = v_name_order THEN
			select 	last_name || ', ' || first_names 
			into 	v_full_name 
			from 	persons 
			where person_id = v_user_id;
		ELSE
			select 	first_names || ' ' || last_name 
			into 	v_full_name 
			from 	persons 
			where person_id = v_user_id;
		END IF;
        	return v_full_name;
        END;$body$ language 'plpgsql';
