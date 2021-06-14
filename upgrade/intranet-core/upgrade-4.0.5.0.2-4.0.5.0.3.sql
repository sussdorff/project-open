-- upgrade-4.0.5.0.2-4.0.5.0.3.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.5.0.2-4.0.5.0.3.sql','');



create or replace function im_boolean_from_id(varchar)
returns varchar as $$
DECLARE
	p_boolean	alias for $1;
	v_result	varchar;
BEGIN
	v_result := p_boolean;
	IF 't' = lower(p_boolean) THEN v_result := 'true'; END IF;
	IF 'f' = lower(p_boolean) THEN v_result := 'false'; END IF;
	IF '1' = lower(p_boolean) THEN v_result := 'true'; END IF;
	IF '0' = lower(p_boolean) THEN v_result := 'false'; END IF;
	return v_result;
END;$$ language 'plpgsql';


create or replace function im_boolean_from_id(integer)
returns varchar as $$
DECLARE
	p_boolean	alias for $1;
	v_result	varchar;
BEGIN
	v_result := p_boolean;
	IF 1 = p_boolean THEN v_result := 'true'; END IF;
	IF 0 = p_boolean THEN v_result := 'false'; END IF;
	return v_result;
END;$$ language 'plpgsql';



create or replace function im_boolean_from_id(boolean)
returns varchar as $$
DECLARE
	p_boolean	alias for $1;
	v_result	varchar;
BEGIN
	v_result := p_boolean;
	IF true = p_boolean THEN v_result := 'true'; END IF;
	IF false = p_boolean THEN v_result := 'false'; END IF;
	return v_result;
END;$$ language 'plpgsql';




