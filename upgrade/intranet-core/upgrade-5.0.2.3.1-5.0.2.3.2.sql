-- 5.0.2.3.1-5.0.2.3.2.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.2.3.1-5.0.2.3.2.sql','');




select define_function_args('acs_attribute__create_attribute','object_type,attribute_name,datatype,pretty_name,pretty_plural;null,table_name;null,column_name;null,default_value;null,min_n_values;1,max_n_values;1,sort_order;null,storage;type_specific,static_p;f,create_column_p;f,database_type;null,size;null,null_p;t,references;null,check_expr;null,column_spec;null');


--
-- procedure acs_attribute__create_attribute/20
--
CREATE OR REPLACE FUNCTION acs_attribute__create_attribute(
   p_object_type varchar,
   p_attribute_name varchar,
   p_datatype varchar,
   p_pretty_name varchar,
   p_pretty_plural varchar,   -- default null
   p_table_name varchar,      -- default null
   p_column_name varchar,     -- default null
   p_default_value varchar,   -- default null
   p_min_n_values integer,    -- default 1 -- default '1'
   p_max_n_values integer,    -- default 1 -- default '1'
   p_sort_order integer,      -- default null
   p_storage varchar,         -- default 'type_specific'
   p_static_p boolean,        -- default 'f'
   p_create_column_p boolean, -- default 'f'
   p_database_type varchar,   -- default null
   p_size varchar,            -- default null
   p_null_p boolean,          -- default 't'
   p_references varchar,      -- default null
   p_check_expr varchar,      -- default null
   p_column_spec varchar      -- default null

) RETURNS integer AS $$
DECLARE

  v_sort_order            acs_attributes.sort_order%TYPE;
  v_attribute_id          acs_attributes.attribute_id%TYPE;
  v_column_spec           text;
  v_table_name            text;
  v_constraint_stub       text;
  v_column_name           text;
  v_datatype              record;

BEGIN

  if not exists (select 1
                 from acs_object_types
                 where object_type = p_object_type) then
    raise exception 'Object type % does not exist', p_object_type;
  end if; 

  if p_sort_order is null then
    select coalesce(max(sort_order), 1) into v_sort_order
    from acs_attributes
    where object_type = p_object_type
    and attribute_name = p_attribute_name;
  else
    v_sort_order := p_sort_order;
  end if;

  select nextval('t_acs_attribute_id_seq') into v_attribute_id;

  insert into acs_attributes
    (attribute_id, object_type, table_name, column_name, attribute_name,
     pretty_name, pretty_plural, sort_order, datatype, default_value,
     min_n_values, max_n_values, storage, static_p)
  values
    (v_attribute_id, p_object_type, 
     p_table_name, p_column_name, 
     p_attribute_name, p_pretty_name,
     p_pretty_plural, v_sort_order, 
     p_datatype, p_default_value,
     p_min_n_values, p_max_n_values, 
     p_storage, p_static_p);

  if p_create_column_p then

    select table_name into v_table_name from acs_object_types
    where object_type = p_object_type;

    if not exists (select 1
                   from pg_class
                   where relname = lower(v_table_name)) then
      raise exception 'Table % for object type % does not exist', v_table_name, p_object_type;
    end if;

    -- Add the appropriate column to the table

    -- We can only create the table column if
    -- 1. the attribute is declared type_specific (generic storage uses an auxillary table)
    -- 2. the attribute is not declared static
    -- 3. it does not already exist in the table

    if p_storage <> 'type_specific' then
      raise exception 'Attribute % for object type % must be declared with type_specific storage',
        p_attribute_name, p_object_type;
    end if;

    if p_static_p then
      raise exception 'Attribute % for object type % can not be declared static',
        p_attribute_name, p_object_type;
    end if;

    if p_table_name is not null then
      raise exception 'Attribute % for object type % can not specify a table for storage', p_attribute_name, p_object_type;
    end if;

    if exists (select 1
               from pg_class c, pg_attribute a
               where c.relname::varchar = v_table_name
                 and c.oid = a.attrelid
                 and a.attname = lower(p_attribute_name)) then
      raise exception 'Column % for object type % already exists',
        p_attribute_name, p_object_type;
    end if;

    -- all conditions for creating this column have been met, now let's see if the type
    -- spec is OK

    if p_column_spec is not null then
      if p_database_type is not null
        or p_size is not null
        or p_null_p is not null
        or p_references is not null
        or p_check_expr is not null then
      raise exception 'Attribute % for object type % is being created with an explicit column_spec, but not all of the type modification fields are null',
        p_attribute_name, p_object_type;
      end if;
      v_column_spec := p_column_spec;
    else
      select coalesce(p_database_type, database_type) as database_type,
        coalesce(p_size, column_size) as column_size,
        coalesce(p_check_expr, column_check_expr) as check_expr
      into v_datatype
      from acs_datatypes
      where datatype = p_datatype;
  
      v_column_spec := v_datatype.database_type;

      if v_datatype.column_size is not null then
        v_column_spec := v_column_spec || '(' || v_datatype.column_size || ')';
      end if;

      v_constraint_stub := ' constraint ' || p_object_type || '_' ||
        p_attribute_name || '_';

      if v_datatype.check_expr is not null then
        v_column_spec := v_column_spec || v_constraint_stub || 'ck check(' ||
          p_attribute_name || v_datatype.check_expr || ')';
      end if;

      if not p_null_p then
        v_column_spec := v_column_spec || v_constraint_stub || 'nn not null';
      end if;

      if p_references is not null then
        v_column_spec := v_column_spec || v_constraint_stub || 'fk references ' ||
          p_references || ' on delete';
        if p_null_p then
          v_column_spec := v_column_spec || ' set null';
        else
          v_column_spec := v_column_spec || ' cascade';
        end if;
      end if;

    end if;
        
    execute 'alter table ' || v_table_name || ' add ' || p_attribute_name || ' ' ||
            v_column_spec;

  end if;

  return v_attribute_id;

END;
$$ LANGUAGE plpgsql;



--
-- procedure acs_attribute__create_attribute/13
--
CREATE OR REPLACE FUNCTION acs_attribute__create_attribute(
   p_object_type varchar,
   p_attribute_name varchar,
   p_datatype varchar,
   p_pretty_name varchar,
   p_pretty_plural varchar, -- default null
   p_table_name varchar,    -- default null
   p_column_name varchar,   -- default null
   p_default_value varchar, -- default null
   p_min_n_values integer,  -- default 1
   p_max_n_values integer,  -- default 1
   p_sort_order integer,    -- default null
   p_storage varchar,       -- default 'type_specific'
   p_static_p boolean       -- default 'f'

) RETURNS integer AS $$
--
-- acs_attribute__create_attribute/13 maybe obsolete, when we define proper defaults for /20
--
DECLARE
BEGIN
  return acs_attribute__create_attribute(p_object_type,
    p_attribute_name, p_datatype, p_pretty_name,
    p_pretty_plural, p_table_name, p_column_name,
    p_default_value, p_min_n_values,
    p_max_n_values, p_sort_order, p_storage,
    p_static_p, 'f', null, null, null, null, null, null);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION acs_attribute__create_attribute (varchar,varchar,varchar,varchar,varchar,varchar,varchar,integer,integer,integer,integer,varchar,boolean) RETURNS integer AS $$
BEGIN
    return acs_attribute__create_attribute ($1, $2, $3, $4, $5, $6, $7, cast ($8 as varchar), $9, $10, $11, $12, $13);
END;
$$ LANGUAGE plpgsql;

-- procedure drop_attribute
select define_function_args('acs_attribute__drop_attribute','object_type,attribute_name,drop_column_p;f');

