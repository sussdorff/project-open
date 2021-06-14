-- upgrade-3.4.0.8.5-3.4.0.8.6.sql

SELECT acs_log__debug('/packages/intranet-material/sql/postgresql/upgrade/upgrade-3.4.0.8.5-3.4.0.8.6.sql','');

alter table im_materials alter column material_name type text;
alter table im_materials alter column material_nr type text;
alter table im_materials alter column description type text;


-- We need to recompile the function after changing the columns...


create or replace function im_material__new (
	integer, varchar, timestamptz, integer, varchar, integer,
	varchar, varchar, integer, integer, integer, varchar
) returns integer as '
declare
	p_material_id		alias for $1;		-- material_id default null
	p_object_type		alias for $2;		-- object_type default ''im_material''
	p_creation_date		alias for $3;		-- creation_date default now()
	p_creation_user		alias for $4;		-- creation_user
	p_creation_ip		alias for $5;		-- creation_ip default null
	p_context_id		alias for $6;		-- context_id default null

	p_material_name		alias for $7;	
	p_material_nr		alias for $8;	
	p_material_type_id	alias for $9;
	p_material_status_id	alias for $10;
	p_material_uom_id	alias for $11;
	p_description		alias for $12;

	v_material_id		integer;
    begin
 	v_material_id := acs_object__new (
                p_material_id,            -- object_id
                p_object_type,            -- object_type
                p_creation_date,          -- creation_date
                p_creation_user,          -- creation_user
                p_creation_ip,            -- creation_ip
                p_context_id,             -- context_id
                ''t''                     -- security_inherit_p
        );

	insert into im_materials (
		material_id,
		material_name, material_nr,
		material_type_id, material_status_id,
		material_uom_id, description
	) values (
		p_material_id,
		p_material_name, p_material_nr,
		p_material_type_id, p_material_status_id,
		p_material_uom_id, p_description
	);

	return v_material_id;
end;' language 'plpgsql';



-- Delete a single material (if we know its ID...)
create or replace function  im_material__delete (integer)
returns integer as '
declare
	p_material_id alias for $1;	-- material_id
begin
	-- Erase the material
	delete from 	im_materials
	where		material_id = p_material_id;

        -- Erase the object
        PERFORM acs_object__delete(p_material_id);
        return 0;
end;' language 'plpgsql';


create or replace function im_material__name (integer)
returns varchar as '
declare
	p_material_id alias for $1;	-- material_id
	v_name	varchar;
begin
	select	material_nr
	into	v_name
	from	im_materials
	where	material_id = p_material_id;
	return v_name;
end;' language 'plpgsql';


