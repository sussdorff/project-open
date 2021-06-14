-- upgrade-4.0.3.0.3-4.0.3.0.4.sql

SELECT acs_log__debug('/packages/intranet-planning/sql/postgresql/upgrade/upgrade-4.0.3.0.3-4.0.3.0.4.sql','');

-- Sequence to create fake object_ids for im_planning_items
create or replace function inline_0 ()
returns integer as $body$
declare
	v_count		integer;
begin
	select count(*) into v_count from pg_class
	where  lower(relname) = 'im_planning_items_seq';
	IF v_count = 0 THEN 
		create sequence im_planning_items_seq;
	END IF;

	return 0;
end;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();


-- Sequence to create fake object_ids for im_planning_items
create or replace function inline_0 ()
returns integer as $body$
declare
	v_count		integer;
begin
	select count(*) into v_count from user_tab_columns
	where  lower(table_name) = 'im_planning_items' and lower(column_name) = 'item_id';
	IF v_count = 0 THEN 
		alter table im_planning_items
		add column item_id integer default nextval('im_planning_items_seq') 
		constraint im_planning_item_id_pk primary key;
	END IF;

	return 0;
end;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();



-- Sequence to create fake object_ids for im_planning_items
create or replace function inline_0 ()
returns integer as $body$
declare
	v_count		integer;
begin
	select count(*) into v_count from user_tab_columns
	where  lower(table_name) = 'im_planning_items' and lower(column_name) = 'item_project_member_hourly_cost';
	IF v_count = 0 THEN 
		-- Only for planning hourly costs:
		-- Contains the hourly_cost of the resource in order
		-- to keep budgets from changing when changing the
		-- im_employees.hourly_cost of a resource.
		alter table im_planning_items
		add column item_project_member_hourly_cost numeric(12,3);
	END IF;

	return 0;
end;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();




-- Update all planning items with a project_member_id
-- to contain the current employee's hourly rate
create or replace function inline_0 ()
returns integer as $body$
declare
	row		RECORD;
begin
	FOR row IN
		select	*
		from	im_planning_items
		where	item_project_member_id is not null and
			item_cost_type_id = 3736 and
			item_project_member_hourly_cost is null
	LOOP
		update im_planning_items
		set item_project_member_hourly_cost = (
			select hourly_cost
			from   im_employees
			where  employee_id = row.item_project_member_id
		    )
		where item_id = row.item_id;
	END LOOP;

	return 0;
end;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();



-- Create a new planning item
-- The first 6 parameters are common for all ]po[ business objects
-- with metadata such as the creation_user etc. Context_id 
-- is always disabled (NULL) for ]po[ objects (inherit permissions
-- from a super object...).
-- The following parameters specify the content of a item with
-- the required fields of the im_planning table.
create or replace function im_planning_item__new (
	integer, varchar, timestamptz,
	integer, varchar, integer,
	integer, integer, integer,
	numeric, varchar,
	integer, integer, integer, timestamptz
) returns integer as $body$
DECLARE
	-- Default 6 parameters that go into the acs_objects table
	p_item_id		alias for $1;		-- item_id  default null
	p_object_type   	alias for $2;		-- object_type default im_planning_item
	p_creation_date		alias for $3;		-- creation_date default now()
	p_creation_user		alias for $4;		-- creation_user default null
	p_creation_ip   	alias for $5;		-- creation_ip default null
	p_context_id		alias for $6;		-- context_id default null

	-- Standard parameters
	p_item_object_id	alias for $7;		-- associated object (project, user, ...)
	p_item_type_id		alias for $8;		-- type (email, http, text comment, ...)
	p_item_status_id	alias for $9;		-- status ("active" or "deleted").

	-- Value parameters
	p_item_value		alias for $10;		-- the actual numeric value
	p_item_note		alias for $11;		-- A note per entry.

	-- Dimension parameter
	p_item_project_phase_id	alias for $12;
	p_item_project_member_id alias for $13;
	p_item_cost_type_id	alias for $14;
	p_item_date		alias for $15;

	v_item_id		integer;
BEGIN
	select	nextval('im_planning_items_seq')
	into	v_item_id from dual;

	-- Create an entry in the im_planning table with the same
	-- v_item_id from acs_objects.object_id
	insert into im_planning_items (
		item_id,
		item_object_id,
		item_project_phase_id,
		item_project_member_id,
		item_cost_type_id,
		item_date,
		item_value,
		item_note
	) values (
		v_item_id,
		p_item_object_id,
		p_item_project_phase_id,
		p_item_project_member_id,
		p_item_cost_type_id,
		p_item_date,
		p_item_value,
		p_item_note
	);

	-- Store the current hourly_rate with planning items.
	IF p_item_cost_type_id = 3736 AND p_item_project_member_id is not null THEN
		update im_planning_items
		set item_project_member_hourly_cost = (
			select hourly_cost
			from   im_employees
			where  employee_id = p_item_project_member_id
		    )
		where item_id = v_item_id;
	END IF;

	return 0;
END; $body$ language 'plpgsql';

