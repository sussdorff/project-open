-- upgrade-4.1.0.0.5-4.1.0.0.6.sql
SELECT acs_log__debug('/packages/intranet-dynfield/sql/postgresql/upgrade/upgrade-4.1.0.0.5-4.1.0.0.6.sql','');


create or replace function inline_0 () 
returns integer as $body$
DECLARE
	v_count		    integer;
	row		    RECORD;
BEGIN
	select	count(*) into v_count
	from	pg_proc
	where	proname = 'im_dynfield_widget__del';
	IF v_count = 0 THEN return 1; END IF;

	drop function im_dynfield_widget__del(integer);

	RETURN 0;
END;
$body$ language 'plpgsql';
select inline_0();
drop function inline_0();




create or replace function im_dynfield_widget__delete (integer) 
returns integer as $body$
DECLARE
	p_widget_id		alias for $1;
BEGIN
	-- Erase the im_dynfield_widgets item associated with the id
	delete from im_dynfield_widgets
	where widget_id = p_widget_id;

	-- Erase all the privileges
	delete from acs_permissions
	where object_id = p_widget_id;

	PERFORM acs_object__delete(p_widget_id);
	return 0;
end;$body$ language 'plpgsql';


