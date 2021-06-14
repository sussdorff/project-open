-- upgrade-4.1.0.1.4-4.1.0.1.5.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.0.1.4-4.1.0.1.5.sql','');

CREATE OR REPLACE FUNCTION inline_0()
RETURNS integer AS $BODY$
DECLARE
	row		RECORD;
	v_count		integer;
BEGIN
	select	count(*) into v_count
	from	pg_class
	where	lower(relname) = 'im_bizo_rmap_un';
	IF v_count = 0 THEN return 1; END IF;

	alter table im_biz_object_role_map 
	drop constraint im_bizo_rmap_un;

        return 0;
end;$BODY$ LANGUAGE plpgsql;
select inline_0();
drop function inline_0();





-- Eliminate duplicate entries before adding a unique index
CREATE OR REPLACE FUNCTION inline_0()
RETURNS integer AS $BODY$
DECLARE
	row		RECORD;
	v_count		integer;
BEGIN
	FOR row IN
	    	SELECT	* FROM (
	    	SELECT	count(*) as cnt,
			coalesce(acs_object_type,'') as acs_object_type,
			coalesce(object_type_id,0) as object_type_id,
			coalesce(object_role_id,0) as object_role_id
		FROM	im_biz_object_role_map
		GROUP BY acs_object_type, object_type_id, object_role_id
		) t
		WHERE cnt > 1
	LOOP
	    DELETE FROM im_biz_object_role_map
	    WHERE oid IN (
		SELECT	oid
		FROM	im_biz_object_role_map
		WHERE	coalesce(acs_object_type,'') = row.acs_object_type and
			coalesce(object_type_id,0) = row.object_type_id and
			coalesce(object_role_id,0) = row.object_role_id
		LIMIT (row.cnt - 1)
	    );
	END LOOP;

        return 0;
end;$BODY$ LANGUAGE plpgsql;
select inline_0();
drop function inline_0();


-- Create a unique index that allows to use coalesce(...)
CREATE OR REPLACE FUNCTION inline_0()
RETURNS integer AS $BODY$
DECLARE
	row		RECORD;
	v_count		integer;
BEGIN
	select	count(*) into v_count
	from	pg_class
	where	lower(relname) = 'im_biz_object_role_map_un';
	IF v_count > 0 THEN return 1; END IF;

	create unique index im_biz_object_role_map_un
	on im_biz_object_role_map
	(coalesce(acs_object_type,''), coalesce(object_type_id,0), coalesce(object_role_id,0));

        return 0;
end;$BODY$ LANGUAGE plpgsql;
select inline_0();
drop function inline_0();





