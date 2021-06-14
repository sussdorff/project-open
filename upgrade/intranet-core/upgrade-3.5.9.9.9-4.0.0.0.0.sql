-- upgrade-3.5.9.9.9-4.0.0.0.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.5.9.9.9-4.0.0.0.0.sql','');




create or replace function inline_0 ()
returns integer as $body$
declare
        v_count                 integer;
begin
        select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'apm_package_types' and lower(column_name) = 'inherit_templates_p';
        IF v_count = 0 THEN
		alter table apm_package_types
		add column inherit_templates_p boolean default 't'
			constraint inherit_templates_p_nn
			not null;
	END IF;

        select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'apm_package_types' and lower(column_name) = 'implements_subsite_p';
        IF v_count = 0 THEN
		alter table apm_package_types
		add column implements_subsite_p boolean default 'f'
			constraint apm_packages_impl_subs_p_nn
			not null;
	END IF;

        select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'apm_package_types' and lower(column_name) = 'implements_subsite_p';
        IF v_count = 0 THEN
		alter table apm_parameters
		add column scope varchar(10) default 'instance'
			constraint apm_parameters_scope_ck
			check (scope in ('global','instance'))
			constraint apm_parameters_scope_nn
			not null;
	END IF;


        return 0;
end;$body$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




--------------------------------------------------------------------------------
-- Excerpts from OpenACS 5.6 APM package creation
--------------------------------------------------------------------------------


create or replace function apm__register_package (varchar,varchar,varchar,varchar,varchar,boolean,boolean,boolean,boolean,varchar,integer)
returns integer as '
declare
  package_key            alias for $1;  
  pretty_name            alias for $2;  
  pretty_plural          alias for $3;  
  package_uri            alias for $4;  
  package_type           alias for $5;  
  initial_install_p      alias for $6;  -- default ''f''  
  singleton_p            alias for $7;  -- default ''f''  
  implements_subsite_p   alias for $8;  -- default ''f''  
  inherit_templates_p    alias for $9;  -- default ''f''  
  spec_file_path         alias for $10;  -- default null
  spec_file_mtime        alias for $11;  -- default null
begin
    PERFORM apm_package_type__create_type(
    	package_key,
	pretty_name,
	pretty_plural,
	package_uri,
	package_type,
	initial_install_p,
	singleton_p,
        implements_subsite_p,
        inherit_templates_p,
	spec_file_path,
	spec_file_mtime
    );

    return 0; 
end;' language 'plpgsql';

-- function update_package
create or replace function apm__update_package (varchar,varchar,varchar,varchar,varchar,boolean,boolean,boolean,boolean,varchar,integer)
returns varchar as '
declare
  package_key            alias for $1;  
  pretty_name            alias for $2;  -- default null
  pretty_plural          alias for $3;  -- default null  
  package_uri            alias for $4;  -- default null  
  package_type           alias for $5;  -- default null  
  initial_install_p      alias for $6;  -- default null  
  singleton_p            alias for $7;  -- default null  
  implements_subsite_p   alias for $8;  -- default ''f''  
  inherit_templates_p    alias for $9;  -- default ''f''  
  spec_file_path         alias for $10;  -- default null
  spec_file_mtime        alias for $11;  -- default null
begin
 
    return apm_package_type__update_type(
    	package_key,
	pretty_name,
	pretty_plural,
	package_uri,
	package_type,
	initial_install_p,
	singleton_p,
        implements_subsite_p,
        inherit_templates_p,
	spec_file_path,
	spec_file_mtime
    );
end;' language 'plpgsql';

-- procedure unregister_package
create or replace function apm__unregister_package (varchar,boolean)
returns integer as '
declare
  package_key            alias for $1;  
  p_cascade_p            alias for $2;  -- default ''t''  
  v_cascade_p            boolean;
begin
   if cascade_p is null then 
	v_cascade_p := ''t'';
   else 
       v_cascade_p := p_cascade_p;
   end if;

   PERFORM apm_package_type__drop_type(
	package_key,
	v_cascade_p
   );

   return 0; 
end;' language 'plpgsql';


-- function register_p
create or replace function apm__register_p (varchar)
returns integer as '
declare
  register_p__package_key            alias for $1;  
  v_register_p                       integer;       
begin
    select case when count(*) = 0 then 0 else 1 end into v_register_p 
    from apm_package_types 
    where package_key = register_p__package_key;

    return v_register_p;
   
end;' language 'plpgsql' stable;


-- procedure register_application
create or replace function apm__register_application (varchar,varchar,varchar,varchar,boolean,boolean,boolean,boolean,varchar,integer)
returns integer as '
declare
  package_key            alias for $1;  
  pretty_name            alias for $2;  
  pretty_plural          alias for $3;  
  package_uri            alias for $4;  
  initial_install_p      alias for $5;  -- default ''f'' 
  singleton_p            alias for $6;  -- default ''f'' 
  implements_subsite_p   alias for $7;  -- default ''f''  
  inherit_templates_p    alias for $8;  -- default ''f''  
  spec_file_path         alias for $9;  -- default null
  spec_file_mtime        alias for $10;  -- default null
begin
   PERFORM apm__register_package(
	package_key,
	pretty_name,
	pretty_plural,
	package_uri,
	''apm_application'',
	initial_install_p,
	singleton_p,
        implements_subsite_p,
        inherit_templates_p,
	spec_file_path,
	spec_file_mtime
   ); 

   return 0; 
end;' language 'plpgsql';


-- procedure unregister_application
create or replace function apm__unregister_application (varchar,boolean)
returns integer as '
declare
  package_key            alias for $1;  
  p_cascade_p              alias for $2;  -- default ''f''  
  v_cascade_p            boolean;
begin
   if p_cascade_p is null then 
	v_cascade_p := ''f'';
   else 
       v_cascade_p := p_cascade_p;
   end if;

   PERFORM apm__unregister_package (
        package_key,
        v_cascade_p
   );

   return 0; 
end;' language 'plpgsql';


-- procedure register_service
create or replace function apm__register_service (varchar,varchar,varchar,varchar,boolean,boolean,boolean,boolean,varchar,integer)
returns integer as '
declare
  package_key            alias for $1;  
  pretty_name            alias for $2;  
  pretty_plural          alias for $3;  
  package_uri            alias for $4;  
  initial_install_p      alias for $5;  -- default ''f''  
  singleton_p            alias for $6;  -- default ''f''  
  implements_subsite_p   alias for $7;  -- default ''f''  
  inherit_templates_p    alias for $8;  -- default ''f''  
  spec_file_path         alias for $9;  -- default null
  spec_file_mtime        alias for $10;  -- default null
begin
   PERFORM apm__register_package(
	package_key,
	pretty_name,
	pretty_plural,
	package_uri,
	''apm_service'',
	initial_install_p,
	singleton_p,
        implements_subsite_p,
        inherit_templates_p,
	spec_file_path,
	spec_file_mtime
   );  
 
   return 0; 
end;' language 'plpgsql';


-- procedure unregister_service
create or replace function apm__unregister_service (varchar,boolean)
returns integer as '
declare
  package_key           alias for $1;  
  p_cascade_p           alias for $2;  -- default ''f''  
  v_cascade_p           boolean;
begin
   if p_cascade_p is null then 
	v_cascade_p := ''f'';
   else 
	v_cascade_p := p_cascade_p;
   end if;

   PERFORM apm__unregister_package (
	package_key,
	v_cascade_p
   );

   return 0; 
end;' language 'plpgsql';

create or replace function apm__register_parameter (integer,varchar,varchar,varchar,varchar,varchar,varchar,varchar,integer,integer)
returns integer as '
declare
  register_parameter__parameter_id           alias for $1;  -- default null  
  register_parameter__package_key            alias for $2;  
  register_parameter__parameter_name         alias for $3;  
  register_parameter__description            alias for $4;  -- default null  
  register_parameter__scope                  alias for $5;  
  register_parameter__datatype               alias for $6;  -- default ''string''  
  register_parameter__default_value          alias for $7;  -- default null  
  register_parameter__section_name           alias for $8;  -- default null 
  register_parameter__min_n_values           alias for $9;  -- default 1
  register_parameter__max_n_values           alias for $10;  -- default 1

  v_parameter_id         apm_parameters.parameter_id%TYPE;
  v_value_id             apm_parameter_values.value_id%TYPE;
  v_pkg                  record;

begin
    -- Create the new parameter.    
    v_parameter_id := acs_object__new(
       register_parameter__parameter_id,
       ''apm_parameter'',
       now(),
       null,
       null,
       null,
       ''t'',
       register_parameter__package_key || '' - '' || register_parameter__parameter_name,
       null
    );
    
    insert into apm_parameters 
    (parameter_id, parameter_name, scope, description, package_key, datatype, 
    default_value, section_name, min_n_values, max_n_values)
    values
    (v_parameter_id, register_parameter__parameter_name, register_parameter__scope,
     register_parameter__description, register_parameter__package_key, 
     register_parameter__datatype, register_parameter__default_value, 
     register_parameter__section_name, register_parameter__min_n_values, 
     register_parameter__max_n_values);

    -- Propagate parameter to new instances.	
    if register_parameter__scope = ''instance'' then
      for v_pkg in
          select package_id
  	from apm_packages
  	where package_key = register_parameter__package_key
        loop
          v_value_id := apm_parameter_value__new(
  	    null,
  	    v_pkg.package_id,
  	    v_parameter_id, 
  	    register_parameter__default_value); 	
        end loop;		
     else
       v_value_id := apm_parameter_value__new(
  	 null,
  	 null,
  	 v_parameter_id, 
  	 register_parameter__default_value); 	
     end if;
	
    return v_parameter_id;
   
end;' language 'plpgsql';

-- For backwards compatibility, register a parameter with "instance" scope.

create or replace function apm__register_parameter (integer,varchar,varchar,varchar,varchar,varchar,varchar,integer,integer)
returns integer as '
declare
  register_parameter__parameter_id           alias for $1;  -- default null  
  register_parameter__package_key            alias for $2;  
  register_parameter__parameter_name         alias for $3;  
  register_parameter__description            alias for $4;  -- default null  
  register_parameter__datatype               alias for $5;  -- default ''string''  
  register_parameter__default_value          alias for $6;  -- default null  
  register_parameter__section_name           alias for $7;  -- default null 
  register_parameter__min_n_values           alias for $8;  -- default 1
  register_parameter__max_n_values           alias for $9;  -- default 1

begin
  return
    apm__register_parameter(register_parameter__parameter_id, register_parameter__package_key,
                           register_parameter__parameter_name, register_parameter__description,
                           ''instance'',  register_parameter__datatype,
                           register_parameter__default_value, register_parameter__section_name,
                           register_parameter__min_n_values, register_parameter__max_n_values);
end;' language 'plpgsql';

-- function update_parameter
create or replace function apm__update_parameter (integer,varchar,varchar,varchar,varchar,varchar,integer,integer)
returns varchar as '
declare
  update_parameter__parameter_id           alias for $1;  
  update_parameter__parameter_name         alias for $2;  -- default null  
  update_parameter__description            alias for $3;  -- default null
  update_parameter__datatype               alias for $4;  -- default ''string''
  update_parameter__default_value          alias for $5;  -- default null
  update_parameter__section_name           alias for $6;  -- default null
  update_parameter__min_n_values           alias for $7;  -- default 1
  update_parameter__max_n_values           alias for $8;  -- default 1
begin
    update apm_parameters 
	set parameter_name = coalesce(update_parameter__parameter_name, parameter_name),
            default_value  = coalesce(update_parameter__default_value, default_value),
            datatype       = coalesce(update_parameter__datatype, datatype), 
	    description	   = coalesce(update_parameter__description, description),
	    section_name   = coalesce(update_parameter__section_name, section_name),
            min_n_values   = coalesce(update_parameter__min_n_values, min_n_values),
            max_n_values   = coalesce(update_parameter__max_n_values, max_n_values)
      where parameter_id = update_parameter__parameter_id;

    update acs_objects
       set title = (select package_key || '': Parameter '' || parameter_name
                    from apm_parameters
                    where parameter_id = update_parameter__parameter_id)
     where object_id = update_parameter__parameter_id;

    return parameter_id;
     
end;' language 'plpgsql';


-- function parameter_p
create or replace function apm__parameter_p (varchar,varchar)
returns integer as '
declare
  parameter_p__package_key            alias for $1;  
  parameter_p__parameter_name         alias for $2;  
  v_parameter_p                       integer;       
begin
    select case when count(*) = 0 then 0 else 1 end into v_parameter_p 
    from apm_parameters
    where package_key = parameter_p__package_key
    and parameter_name = parameter_p__parameter_name;

    return v_parameter_p;
   
end;' language 'plpgsql' stable;


-- procedure unregister_parameter
create or replace function apm__unregister_parameter (integer)
returns integer as '
declare
  unregister_parameter__parameter_id           alias for $1;  -- default null
begin
    delete from apm_parameter_values 
    where parameter_id = unregister_parameter__parameter_id;
    delete from apm_parameters 
    where parameter_id = unregister_parameter__parameter_id;
    PERFORM acs_object__delete(unregister_parameter__parameter_id);

    return 0; 
end;' language 'plpgsql';

create or replace function apm__id_for_name (integer,varchar)
returns integer as '
declare
  id_for_name__package_id             alias for $1;  
  id_for_name__parameter_name         alias for $2;  
  a_parameter_id                      apm_parameters.parameter_id%TYPE;
begin
    select parameter_id into a_parameter_id 
    from apm_parameters 
    where parameter_name = id_for_name__parameter_name
      and package_key = (select package_key from apm_packages
                         where package_id = id_for_name__package_id);

    if NOT FOUND
      then
      	raise EXCEPTION ''-20000: The specified package % AND/OR parameter % do not exist in the system'', id_for_name__package_id, id_for_name__parameter_name;
    end if;

    return a_parameter_id;
   
end;' language 'plpgsql' stable strict;

create or replace function apm__id_for_name (varchar,varchar)
returns integer as '
declare
  id_for_name__package_key            alias for $1;  
  id_for_name__parameter_name         alias for $2;  
  a_parameter_id                      apm_parameters.parameter_id%TYPE;
begin
    select parameter_id into a_parameter_id
    from apm_parameters p
    where p.parameter_name = id_for_name__parameter_name and
          p.package_key = id_for_name__package_key;

    if NOT FOUND
      then
      	raise EXCEPTION ''-20000: The specified package % AND/OR parameter % do not exist in the system'', id_for_name__package_key, id_for_name__parameter_name;
    end if;

    return a_parameter_id;
   
end;' language 'plpgsql' stable strict;

create or replace function apm__set_value (integer,varchar,varchar)
returns integer as '
declare
  set_value__package_id             alias for $1;  
  set_value__parameter_name         alias for $2;  
  set_value__attr_value             alias for $3;  
  v_parameter_id                    apm_parameter_values.parameter_id%TYPE;
  v_value_id                        apm_parameter_values.value_id%TYPE;
begin
    v_parameter_id := apm__id_for_name (set_value__package_id, set_value__parameter_name);

    -- Determine if the value exists
    select value_id into v_value_id from apm_parameter_values 
     where parameter_id = v_parameter_id 
     and package_id = set_value__package_id;
    update apm_parameter_values set attr_value = set_value__attr_value
     where value_id = v_value_id;
    update acs_objects set last_modified = now() 
     where object_id = v_value_id;
   --  exception 
     if NOT FOUND
       then
         v_value_id := apm_parameter_value__new(
            null,
            set_value__package_id,
            v_parameter_id,
            set_value__attr_value
         );
     end if;

    return 0; 
end;' language 'plpgsql';

create or replace function apm__set_value (varchar,varchar,varchar)
returns integer as '
declare
  set_value__package_key            alias for $1;  
  set_value__parameter_name         alias for $2;  
  set_value__attr_value             alias for $3;  
  v_parameter_id                    apm_parameter_values.parameter_id%TYPE;
  v_value_id                        apm_parameter_values.value_id%TYPE;
begin
    v_parameter_id := apm__id_for_name (set_value__package_key, set_value__parameter_name);

    -- Determine if the value exists
    select value_id into v_value_id from apm_parameter_values 
     where parameter_id = v_parameter_id 
     and package_id is null;
    update apm_parameter_values set attr_value = set_value__attr_value
     where value_id = v_value_id;
    update acs_objects set last_modified = now() 
     where object_id = v_value_id;
   --  exception 
     if NOT FOUND
       then
         v_value_id := apm_parameter_value__new(
            null,
            null,
            v_parameter_id,
            set_value__attr_value
         );
     end if;

    return 0; 
end;' language 'plpgsql';

create or replace function apm_package__is_child(varchar, varchar) returns boolean as '
declare
  parent_package_key       alias for $1;
  child_package_key        alias for $2;
  dependency               record;
begin

  if parent_package_key = child_package_key then
    return ''t'';
  end if;

  for dependency in 
    select apd.service_uri
    from apm_package_versions apv, apm_package_dependencies apd
    where apd.version_id = apv.version_id
      and apv.enabled_p
      and apd.dependency_type in (''embeds'', ''extends'')
      and apv.package_key = child_package_key
  loop
    if dependency.service_uri = parent_package_key or
      apm_package__is_child(parent_package_key, dependency.service_uri) then
      return ''t'';
    end if;
  end loop;
      
  return ''f'';
end;' language 'plpgsql';

create or replace function apm_package__initialize_parameters (integer,varchar)
returns integer as '
declare
  ip__package_id             alias for $1;  
  ip__package_key            alias for $2;  
  v_value_id                 apm_parameter_values.value_id%TYPE;
  cur_val                    record;
begin
    -- need to initialize all params for this type
    for cur_val in select parameter_id, default_value
       from apm_parameters
       where package_key = ip__package_key
         and scope = ''instance''
      loop
        v_value_id := apm_parameter_value__new(
          null,
          ip__package_id,
          cur_val.parameter_id,
          cur_val.default_value
        ); 
      end loop;   

      return 0; 
end;' language 'plpgsql';


-- function new
create or replace function apm_package__new (integer,varchar,varchar,varchar,timestamptz,integer,varchar,integer)
returns integer as '
declare
  new__package_id             alias for $1;  -- default null  
  new__instance_name          alias for $2;  -- default null
  new__package_key            alias for $3;  
  new__object_type            alias for $4;  -- default ''apm_package''
  new__creation_date          alias for $5;  -- default now()
  new__creation_user          alias for $6;  -- default null
  new__creation_ip            alias for $7;  -- default null
  new__context_id             alias for $8;  -- default null
  v_singleton_p               integer;       
  v_package_type              apm_package_types.package_type%TYPE;
  v_num_instances             integer;       
  v_package_id                apm_packages.package_id%TYPE;
  v_instance_name             apm_packages.instance_name%TYPE;
begin
   v_singleton_p := apm_package__singleton_p(
			new__package_key
		    );
   v_num_instances := apm_package__num_instances(
			new__package_key
		    );
  
   if v_singleton_p = 1 and v_num_instances >= 1 then
       select package_id into v_package_id 
       from apm_packages
       where package_key = new__package_key;

       return v_package_id;
   else
       v_package_id := acs_object__new(
          new__package_id,
          new__object_type,
          new__creation_date,
          new__creation_user,
	  new__creation_ip,
	  new__context_id
	 );
       if new__instance_name is null or new__instance_name = '''' then 
	 v_instance_name := new__package_key || '' '' || v_package_id;
       else
	 v_instance_name := new__instance_name;
       end if;

       select package_type into v_package_type
       from apm_package_types
       where package_key = new__package_key;

       insert into apm_packages
       (package_id, package_key, instance_name)
       values
       (v_package_id, new__package_key, v_instance_name);

       update acs_objects
       set title = v_instance_name,
           package_id = v_package_id
       where object_id = v_package_id;

       if v_package_type = ''apm_application'' then
	   insert into apm_applications
	   (application_id)
	   values
	   (v_package_id);
       else
	   insert into apm_services
	   (service_id)
	   values
	   (v_package_id);
       end if;

       PERFORM apm_package__initialize_parameters(
	   v_package_id,
	   new__package_key
       );

       return v_package_id;

  end if;
end;' language 'plpgsql';
  
create or replace function apm_package__delete (integer) returns integer as '
declare
   delete__package_id   alias for $1;
   cur_val              record;
   v_folder_row         record;
begin
    -- Delete all parameters.
    for cur_val in select value_id from apm_parameter_values
	where package_id = delete__package_id loop
    	PERFORM apm_parameter_value__delete(cur_val.value_id);
    end loop;    

   -- Delete the folders
    for v_folder_row in select
        folder_id
        from cr_folders
        where package_id = delete__package_id
    loop
        perform content_folder__del(v_folder_row.folder_id,''t'');
    end loop;

    delete from apm_applications where application_id = delete__package_id;
    delete from apm_services where service_id = delete__package_id;
    delete from apm_packages where package_id = delete__package_id;
    -- Delete the site nodes for the objects.
    for cur_val in select node_id from site_nodes
	where object_id = delete__package_id loop
    	PERFORM site_node__delete(cur_val.node_id);
    end loop;

    -- Delete the object.
    PERFORM acs_object__delete (
       delete__package_id
    );   

    return 0;
end;' language 'plpgsql';

create or replace function apm_package__initial_install_p (varchar) returns integer as '
declare
	initial_install_p__package_key  alias for $1;
        v_initial_install_p             integer;
begin
        select 1 into v_initial_install_p
	from apm_package_types
	where package_key = initial_install_p__package_key
        and initial_install_p = ''t'';
	
        if NOT FOUND then 
           return 0;
        else
           return v_initial_install_p;
        end if;
end;' language 'plpgsql' stable;

create or replace function apm_package__singleton_p (varchar) returns integer as '
declare
	singleton_p__package_key        alias for $1;
        v_singleton_p                   integer;
begin
        select count(*) into v_singleton_p
	from apm_package_types
	where package_key = singleton_p__package_key
        and singleton_p = ''t'';

        return v_singleton_p;
end;' language 'plpgsql' stable;

create or replace function apm_package__num_instances (varchar) returns integer as '
declare
        num_instances__package_key     alias for $1;
        v_num_instances                integer;
begin
        select count(*) into v_num_instances
	from apm_packages
	where package_key = num_instances__package_key;

        return v_num_instances;

end;' language 'plpgsql' stable;

create or replace function apm_package__name (integer) returns varchar as '
declare
    name__package_id       alias for $1;
    v_result               apm_packages.instance_name%TYPE;
begin
    select instance_name into v_result
    from apm_packages
    where package_id = name__package_id;

    return v_result;

end;' language 'plpgsql' stable strict;

create or replace function apm_package__highest_version (varchar) returns integer as '
declare
     highest_version__package_key    alias for $1;
     v_version_id                    apm_package_versions.version_id%TYPE;
     v_max_version                   varchar;
begin
     select max(apm_package_version__sortable_version_name(v.version_name)) into v_max_version 
       from apm_package_version_info v where v.package_key = highest_version__package_key;

     select version_id into v_version_id from apm_package_version_info i 
	where apm_package_version__sortable_version_name(version_name) = v_max_version and i.package_key = highest_version__package_key;

      if NOT FOUND then 
         return 0;
      else
         return v_version_id;
      end if;
end;' language 'plpgsql' stable;

create or replace function apm_package__parent_id (integer) returns integer as '
declare
    apm_package__parent_id__package_id alias for $1;
    v_package_id apm_packages.package_id%TYPE;
begin
    select sn1.object_id
    into v_package_id
    from site_nodes sn1
    where sn1.node_id = (select sn2.parent_id
                         from site_nodes sn2
                         where sn2.object_id = apm_package__parent_id__package_id);

    return v_package_id;

end;' language 'plpgsql' stable strict;

-- create or replace package body apm_package_version 
create or replace function apm_package_version__new (integer,varchar,varchar,varchar,varchar,varchar,varchar,timestamptz,varchar,varchar,varchar,boolean,boolean) returns integer as '
declare
      apm_pkg_ver__version_id           alias for $1;  -- default null
      apm_pkg_ver__package_key		alias for $2;
      apm_pkg_ver__version_name		alias for $3;  -- default null
      apm_pkg_ver__version_uri		alias for $4;
      apm_pkg_ver__summary              alias for $5;
      apm_pkg_ver__description_format	alias for $6;
      apm_pkg_ver__description		alias for $7;
      apm_pkg_ver__release_date		alias for $8;
      apm_pkg_ver__vendor               alias for $9;
      apm_pkg_ver__vendor_uri		alias for $10;
      apm_pkg_ver__auto_mount           alias for $11;
      apm_pkg_ver__installed_p		alias for $12; -- default ''f''		
      apm_pkg_ver__data_model_loaded_p	alias for $13; -- default ''f''
      v_version_id                      apm_package_versions.version_id%TYPE;
begin
      if apm_pkg_ver__version_id is null then
         select nextval(''t_acs_object_id_seq'')
	 into v_version_id
	 from dual;
      else
         v_version_id := apm_pkg_ver__version_id;
      end if;

      v_version_id := acs_object__new(
		v_version_id,
		''apm_package_version'',
                now(),
                null,
                null,
                null,
                ''t'',
                apm_pkg_ver__package_key || '', Version '' || apm_pkg_ver__version_name,
                null
        );

      insert into apm_package_versions
      (version_id, package_key, version_name, version_uri, summary, description_format, description,
      release_date, vendor, vendor_uri, auto_mount, installed_p, data_model_loaded_p)
      values
      (v_version_id, apm_pkg_ver__package_key, apm_pkg_ver__version_name, 
       apm_pkg_ver__version_uri, apm_pkg_ver__summary, 
       apm_pkg_ver__description_format, apm_pkg_ver__description,
       apm_pkg_ver__release_date, apm_pkg_ver__vendor, apm_pkg_ver__vendor_uri, apm_pkg_ver__auto_mount,
       apm_pkg_ver__installed_p, apm_pkg_ver__data_model_loaded_p);

      return v_version_id;		
  
end;' language 'plpgsql';


-- procedure delete
create or replace function apm_package_version__delete (integer)
returns integer as '
declare
  delete__version_id             alias for $1;  
begin
      delete from apm_package_owners 
      where version_id = delete__version_id; 

      delete from apm_package_dependencies
      where version_id = delete__version_id;

      delete from apm_package_versions 
	where version_id = delete__version_id;

      PERFORM acs_object__delete(delete__version_id);

      return 0; 
end;' language 'plpgsql';


-- procedure enable
create or replace function apm_package_version__enable (integer)
returns integer as '
declare
  enable__version_id             alias for $1;  
begin
      update apm_package_versions set enabled_p = ''t''
      where version_id = enable__version_id;	

      return 0; 
end;' language 'plpgsql';


-- procedure disable
create or replace function apm_package_version__disable (integer)
returns integer as '
declare
  disable__version_id             alias for $1;  
begin
      update apm_package_versions 
      set enabled_p = ''f''
      where version_id = disable__version_id;	

      return 0; 
end;' language 'plpgsql';


-- function copy
create or replace function apm_package_version__copy (integer,integer,varchar,varchar,boolean)
returns integer as '
declare
  copy__version_id             alias for $1;  
  copy__new_version_id         alias for $2;  -- default null  
  copy__new_version_name       alias for $3;  
  copy__new_version_uri        alias for $4;  
  copy__copy_owners_p          alias for $5;
  v_version_id                 integer;       
begin
	v_version_id := acs_object__new(
		copy__new_version_id,
		''apm_package_version'',
                now(),
                null,
                null,
                null
        );    

	insert into apm_package_versions(version_id, package_key, version_name,
					version_uri, summary, description_format, description,
					release_date, vendor, vendor_uri, auto_mount)
	    select v_version_id, package_key, copy__new_version_name,
		   copy__new_version_uri, summary, description_format, description,
		   release_date, vendor, vendor_uri, auto_mount
	    from apm_package_versions
	    where version_id = copy__version_id;
    
        update acs_objects
        set title = (select v.package_key || '', Version '' || v.version_name
                     from apm_package_versions v
                     where v.version_id = copy__version_id)
        where object_id = copy__version_id;

	insert into apm_package_dependencies(dependency_id, version_id, dependency_type, service_uri, service_version)
	    select nextval(''t_acs_object_id_seq''), v_version_id, dependency_type, service_uri, service_version
	    from apm_package_dependencies
	    where version_id = copy__version_id;
    
        insert into apm_package_callbacks (version_id, type, proc)
                select v_version_id, type, proc
                from apm_package_callbacks
                where version_id = copy__version_id;
    
        if copy__copy_owners_p then
            insert into apm_package_owners(version_id, owner_uri, owner_name, sort_key)
                select v_version_id, owner_uri, owner_name, sort_key
                from apm_package_owners
                where version_id = copy__version_id;
        end if;
    
	return v_version_id;
   
end;' language 'plpgsql';


-- function edit
create or replace function apm_package_version__edit (integer,integer,varchar,varchar,varchar,varchar,varchar,timestamptz,varchar,varchar,varchar,boolean,boolean)
returns integer as '
declare
  edit__new_version_id         alias for $1;  -- default null  
  edit__version_id             alias for $2;  
  edit__version_name           alias for $3;  -- default null
  edit__version_uri            alias for $4;  
  edit__summary                alias for $5;  
  edit__description_format     alias for $6;  
  edit__description            alias for $7;  
  edit__release_date           alias for $8;  
  edit__vendor                 alias for $9;  
  edit__vendor_uri             alias for $10; 
  edit__auto_mount             alias for $11;
  edit__installed_p            alias for $12; -- default ''f''
  edit__data_model_loaded_p    alias for $13; -- default ''f''
  v_version_id                 apm_package_versions.version_id%TYPE;
  version_unchanged_p          integer;       
begin
       -- Determine if version has changed.
       select case when count(*) = 0 then 0 else 1 end into version_unchanged_p
       from apm_package_versions
       where version_id = edit__version_id
       and version_name = edit__version_name;
       if version_unchanged_p <> 1 then
         v_version_id := apm_package_version__copy(
			 edit__version_id,
			 edit__new_version_id,
			 edit__version_name,
			 edit__version_uri,
                         ''f''
			);
         else 
	   v_version_id := edit__version_id;			
       end if;
       
       update apm_package_versions 
		set version_uri = edit__version_uri,
		summary = edit__summary,
		description_format = edit__description_format,
		description = edit__description,
		release_date = date_trunc(''days'',now()),
		vendor = edit__vendor,
		vendor_uri = edit__vendor_uri,
                auto_mount = edit__auto_mount,
		installed_p = edit__installed_p,
		data_model_loaded_p = edit__data_model_loaded_p
	    where version_id = v_version_id;

	return v_version_id;
     
end;' language 'plpgsql';

-- function add_interface
create or replace function apm_package_version__add_interface (integer,integer,varchar,varchar)
returns integer as '
declare
  add_interface__interface_id         alias for $1;  -- default null  
  add_interface__version_id           alias for $2;  
  add_interface__interface_uri        alias for $3;  
  add_interface__interface_version    alias for $4;  
  v_dep_id                            apm_package_dependencies.dependency_id%TYPE;
begin
      if add_interface__interface_id is null then
          select nextval(''t_acs_object_id_seq'') into v_dep_id from dual;
      else
          v_dep_id := add_interface__interface_id;
      end if;
  
      insert into apm_package_dependencies
      (dependency_id, version_id, dependency_type, service_uri, service_version)
      values
      (v_dep_id, add_interface__version_id, ''provides'', add_interface__interface_uri,
	add_interface__interface_version);

      return v_dep_id;
   
end;' language 'plpgsql';


-- procedure remove_interface
create or replace function apm_package_version__remove_interface (integer)
returns integer as '
declare
  remove_interface__interface_id           alias for $1;  
begin
    delete from apm_package_dependencies 
    where dependency_id = remove_interface__interface_id;

    return 0; 
end;' language 'plpgsql';


-- procedure remove_interface
create or replace function apm_package_version__remove_interface (varchar,varchar,integer)
returns integer as '
declare
  remove_interface__interface_uri          alias for $1;  
  remove_interface__interface_version      alias for $2;  
  remove_interface__version_id             alias for $3;  
  v_dep_id                           apm_package_dependencies.dependency_id%TYPE;
begin
      select dependency_id into v_dep_id from apm_package_dependencies
      where service_uri = remove_interface__interface_uri 
      and interface_version = remove_interface__interface_version;
      PERFORM apm_package_version__remove_interface(v_dep_id);

      return 0; 
end;' language 'plpgsql';


-- function add_dependency
create or replace function apm_package_version__add_dependency (varchar,integer,integer,varchar,varchar)
returns integer as '
declare
  add_dependency__dependency_type        alias for $1;
  add_dependency__dependency_id          alias for $2;  -- default null  
  add_dependency__version_id             alias for $3;  
  add_dependency__dependency_uri         alias for $4;  
  add_dependency__dependency_version     alias for $5;  
  v_dep_id                            apm_package_dependencies.dependency_id%TYPE;
begin
      if add_dependency__dependency_id is null then
          select nextval(''t_acs_object_id_seq'') into v_dep_id from dual;
      else
          v_dep_id := add_dependency__dependency_id;
      end if;
  
      insert into apm_package_dependencies
      (dependency_id, version_id, dependency_type, service_uri, service_version)
      values
      (v_dep_id, add_dependency__version_id, add_dependency__dependency_type,
        add_dependency__dependency_uri, add_dependency__dependency_version);

      return v_dep_id;
   
end;' language 'plpgsql';


-- procedure remove_dependency
create or replace function apm_package_version__remove_dependency (integer)
returns integer as '
declare
  remove_dependency__dependency_id          alias for $1;  
begin
    delete from apm_package_dependencies 
    where dependency_id = remove_dependency__dependency_id;

    return 0; 
end;' language 'plpgsql';


-- procedure remove_dependency
create or replace function apm_package_version__remove_dependency (varchar,varchar,integer)
returns integer as '
declare
  remove_dependency__dependency_uri         alias for $1;  
  remove_dependency__dependency_version     alias for $2;  
  remove_dependency__version_id             alias for $3;  
  v_dep_id                           apm_package_dependencies.dependency_id%TYPE;
begin
      select dependency_id into v_dep_id from apm_package_dependencies 
      where service_uri = remove_dependency__dependency_uri 
      and service_version = remove_dependency__dependency_version;
      PERFORM apm_package_version__remove_dependency(v_dep_id);

      return 0; 
end;' language 'plpgsql';


-- function sortable_version_name
create or replace function apm_package_version__sortable_version_name (varchar)
returns varchar as '
declare
  version_name           alias for $1;  
  a_fields               integer;       
  a_start                integer;       
  a_end                  integer;       
  a_order                varchar(1000) default ''''; 
  a_char                 char(1);       
  a_seen_letter          boolean default ''f'';        
begin
        a_fields := 0;
	a_start := 1;
	loop
	    a_end := a_start;
    
	    -- keep incrementing a_end until we run into a non-number        
	    while substr(version_name, a_end, 1) >= ''0'' and substr(version_name, a_end, 1) <= ''9'' loop
		a_end := a_end + 1;
	    end loop;
	    if a_end = a_start then
	    	return -1;
		-- raise_application_error(-20000, ''Expected number at position '' || a_start);
	    end if;
	    if a_end - a_start > 4 then
	    	return -1;
		-- raise_application_error(-20000, ''Numbers within versions can only be up to 4 digits long'');
	    end if;
    
	    -- zero-pad and append the number
	    a_order := a_order || substr(''0000'', 1, 4 - (a_end - a_start)) ||
		substr(version_name, a_start, a_end - a_start) || ''.'';
            a_fields := a_fields + 1;                                
	    if a_end > length(version_name) then
		-- end of string - we''re outta here
		if a_seen_letter = ''f'' then
		    -- append the "final" suffix if there haven''t been any letters
		    -- so far (i.e., not development/alpha/beta)
		    a_order := a_order || repeat(''0000.'',7 - a_fields) || ''  3F.'';
		end if;
		return a_order;
	    end if;
    
	    -- what''s the next character? if a period, just skip it
	    a_char := substr(version_name, a_end, 1);
	    if a_char = ''.'' then
	    else
		-- if the next character was a letter, append the appropriate characters
		if a_char = ''d'' then
		    a_order := a_order || repeat(''0000.'',7 - a_fields) || ''  0D.'';
		else if a_char = ''a'' then
		    a_order := a_order || repeat(''0000.'',7 - a_fields) || ''  1A.'';
		else if a_char = ''b'' then
		    a_order := a_order || repeat(''0000.'',7 - a_fields) || ''  2B.'';
		end if; end if; end if;
    
		-- can''t have something like 3.3a1b2 - just one letter allowed!
		if a_seen_letter = ''t'' then
		    return -1;
		    -- raise_application_error(-20000, ''Not allowed to have two letters in version name ''''''
		    --	|| version_name || '''''''');
		end if;
		a_seen_letter := ''t'';
    
		-- end of string - we''re done!
		if a_end = length(version_name) then
		    return a_order;
		end if;
	    end if;
	    a_start := a_end + 1;
	end loop;
    
end;' language 'plpgsql' immutable;

-- function version_name_greater
create or replace function apm_package_version__version_name_greater (varchar,varchar)
returns integer as '
declare
  version_name_one       alias for $1;  
  version_name_two       alias for $2;
  a_order_a		 varchar(250);
  a_order_b		 varchar(250);  
begin
	a_order_a := apm_package_version__sortable_version_name(version_name_one);
	a_order_b := apm_package_version__sortable_version_name(version_name_two);
	if a_order_a < a_order_b then
	    return -1;
	else if a_order_a > a_order_b then
	    return 1;
	end if; end if;

	return 0;   
end;' language 'plpgsql' immutable;

-- function upgrade_p
create or replace function apm_package_version__upgrade_p (varchar,varchar,varchar)
returns integer as '
declare
  upgrade_p__path                   alias for $1;  
  upgrade_p__initial_version_name   alias for $2;  
  upgrade_p__final_version_name     alias for $3;  
  v_pos1                            integer;       
  v_pos2                            integer;       
  v_tmp                             varchar(1500);
  v_path                            varchar(1500);
  v_version_from                    apm_package_versions.version_name%TYPE;
  v_version_to                      apm_package_versions.version_name%TYPE;
begin

	-- Set v_path to the tail of the path (the file name).        
	v_path := substr(upgrade_p__path, instr(upgrade_p__path, ''/'', -1) + 1);

	-- Remove the extension, if it is .sql.
	v_pos1 := position(''.sql'' in v_path);
	if v_pos1 > 0 then
	    v_path := substr(v_path, 1, v_pos1 - 1);
	end if;

	-- Figure out the from/to version numbers for the individual file.
	v_pos1 := instr(v_path, ''-'', -1, 2);
	v_pos2 := instr(v_path, ''-'', -1);
	if v_pos1 = 0 or v_pos2 = 0 then
	    -- There aren''t two hyphens in the file name. Bail.
	    return 0;
	end if;

	v_version_from := substr(v_path, v_pos1 + 1, v_pos2 - v_pos1 - 1);
	v_version_to := substr(v_path, v_pos2 + 1);

	if apm_package_version__version_name_greater(upgrade_p__initial_version_name, v_version_from) <= 0 and
	   apm_package_version__version_name_greater(upgrade_p__final_version_name, v_version_to) >= 0 then
	    return 1;
	end if;

	return 0;
        -- exception when others then
	-- Invalid version number.
	-- return 0;
   
end;' language 'plpgsql' immutable;


-- procedure upgrade
create or replace function apm_package_version__upgrade (integer)
returns integer as '
declare
  upgrade__version_id             alias for $1;  
begin
    update apm_package_versions
    	set enabled_p = ''f'',
	    installed_p = ''f''
	where package_key = (select package_key from apm_package_versions
	    	    	     where version_id = upgrade__version_id);
    update apm_package_versions
    	set enabled_p = ''t'',
	    installed_p = ''t''
	where version_id = upgrade__version_id;			  
    
    return 0; 
end;' language 'plpgsql';



-- show errors

-- create or replace package body apm_package_type
-- procedure create_type
create or replace function apm_package_type__create_type (varchar,varchar,varchar,varchar,varchar,boolean,boolean,boolean,boolean,varchar,integer)
returns integer as '
declare
  create_type__package_key            alias for $1;  
  create_type__pretty_name            alias for $2;  
  create_type__pretty_plural          alias for $3;  
  create_type__package_uri            alias for $4;  
  create_type__package_type           alias for $5;  
  create_type__initial_install_p      alias for $6;  
  create_type__singleton_p            alias for $7;  
  create_type__implements_subsite_p   alias for $8;
  create_type__inherit_templates_p    alias for $9;
  create_type__spec_file_path         alias for $10;  -- default null  
  create_type__spec_file_mtime        alias for $11;  -- default null
begin
   insert into apm_package_types
    (package_key, pretty_name, pretty_plural, package_uri, package_type,
    spec_file_path, spec_file_mtime, initial_install_p, singleton_p,
    implements_subsite_p, inherit_templates_p)
   values
    (create_type__package_key, create_type__pretty_name, create_type__pretty_plural,
     create_type__package_uri, create_type__package_type, create_type__spec_file_path, 
     create_type__spec_file_mtime, create_type__initial_install_p, create_type__singleton_p,
     create_type__implements_subsite_p, create_type__inherit_templates_p);

   return 0; 
end;' language 'plpgsql';


-- function update_type
create or replace function apm_package_type__update_type (varchar,varchar,varchar,varchar,varchar,boolean,boolean,boolean,boolean,varchar,integer)
returns varchar as '
declare
  update_type__package_key            alias for $1;  
  update_type__pretty_name            alias for $2;  -- default null  
  update_type__pretty_plural          alias for $3;  -- default null
  update_type__package_uri            alias for $4;  -- default null
  update_type__package_type           alias for $5;  -- default null  
  update_type__initial_install_p      alias for $6;  -- default null  
  update_type__singleton_p            alias for $7;  -- default null  
  update_type__implements_subsite_p   alias for $8;  -- default null  
  update_type__inherit_templates_p    alias for $9;  -- default null  
  update_type__spec_file_path         alias for $10;  -- default null  
  update_type__spec_file_mtime        alias for $11;  -- default null  
begin
      UPDATE apm_package_types SET
      	pretty_name = coalesce(update_type__pretty_name, pretty_name),
    	pretty_plural = coalesce(update_type__pretty_plural, pretty_plural),
    	package_uri = coalesce(update_type__package_uri, package_uri),
    	package_type = coalesce(update_type__package_type, package_type),
    	spec_file_path = coalesce(update_type__spec_file_path, spec_file_path),
    	spec_file_mtime = coalesce(update_type__spec_file_mtime, spec_file_mtime),
    	singleton_p = coalesce(update_type__singleton_p, singleton_p),
    	initial_install_p = coalesce(update_type__initial_install_p, initial_install_p),
    	implements_subsite_p = coalesce(update_type__implements_subsite_p, implements_subsite_p),
    	inherit_templates_p = coalesce(update_type__inherit_templates_p, inherit_templates_p)
      where package_key = update_type__package_key;

      return update_type__package_key;
   
end;' language 'plpgsql';


-- procedure drop_type
create or replace function apm_package_type__drop_type (varchar,boolean)
returns integer as '
declare
  drop_type__package_key            alias for $1;  
  drop_type__cascade_p              alias for $2;  -- default ''f''
  cur_val                           record; 
begin
    if drop_type__cascade_p = ''t'' then
        for cur_val in select package_id
       from apm_packages
       where package_key = drop_type__package_key
        loop
            PERFORM apm_package__delete(
	        cur_val.package_id
	    );
        end loop;
	-- Unregister all parameters.
        for cur_val in select parameter_id from apm_parameters
       where package_key = drop_type__package_key
	loop
	    PERFORM apm__unregister_parameter(cur_val.parameter_id);
	end loop;
  
        -- Unregister all versions
	for cur_val in select version_id from apm_package_versions
       where package_key = drop_type__package_key
	loop
	    PERFORM apm_package_version__delete(cur_val.version_id);
        end loop;
    end if;
    delete from apm_package_types
    where package_key = drop_type__package_key;

    return 0; 
end;' language 'plpgsql';


-- function num_parameters
create or replace function apm_package_type__num_parameters (varchar)
returns integer as '
declare
  num_parameters__package_key            alias for $1;  
  v_count                                integer;       
begin
    select count(*) into v_count
    from apm_parameters
    where package_key = num_parameters__package_key;

    return v_count;
   
end;' language 'plpgsql' stable;





-- show errors

-- create or replace package body apm_parameter_value
-- function new
create or replace function apm_parameter_value__new (integer,integer,integer,varchar)
returns integer as '
declare
  new__value_id               alias for $1;  -- default null  
  new__package_id             alias for $2;  
  new__parameter_id           alias for $3;  
  new__attr_value             alias for $4;  
  v_value_id                  apm_parameter_values.value_id%TYPE;
  v_title                     acs_objects.title%TYPE;
begin
   select pkg.package_key || '': '' || pkg.instance_name || '' - '' || par.parameter_name into v_title from apm_packages pkg, apm_parameters par where pkg.package_id = new__package_id and par.parameter_id = new__parameter_id;

   v_value_id := acs_object__new(
     new__value_id,
     ''apm_parameter_value'',
     now(),
     null,
     null,
     null,
     ''t'',
     v_title,
     new__package_id
   );

   insert into apm_parameter_values
    (value_id, package_id, parameter_id, attr_value)
     values
    (v_value_id, new__package_id, new__parameter_id, new__attr_value);

   return v_value_id;

end;' language 'plpgsql';


-- procedure delete
create or replace function apm_parameter_value__delete (integer)
returns integer as '
declare
  delete__value_id               alias for $1;  -- default null
begin
    delete from apm_parameter_values 
    where value_id = delete__value_id;
    PERFORM acs_object__delete(delete__value_id);

    return 0; 
end;' language 'plpgsql';


-- function new
create or replace function apm_application__new (integer,varchar,varchar,varchar,timestamptz,integer,varchar,integer)
returns integer as '
declare
  application_id         alias for $1;  -- default null  
  instance_name          alias for $2;  -- default null
  package_key            alias for $3;  
  object_type            alias for $4;  -- default ''apm_application''
  creation_date          alias for $5;  -- default now()
  creation_user          alias for $6;  -- default null
  creation_ip            alias for $7;  -- default null
  context_id             alias for $8;  -- default null
  v_application_id       integer;       
begin
    v_application_id := apm_package__new (
      application_id,
      instance_name,
      package_key,
      object_type,
      creation_date,
      creation_user,
      creation_ip,
      context_id
    );

    return v_application_id;
   
end;' language 'plpgsql';


-- procedure delete
create or replace function apm_application__delete (integer)
returns integer as '
declare
  delete__application_id         alias for $1;  
begin
    delete from apm_applications
    where application_id = delete__application_id;
    PERFORM apm_package__delete(
        delete__application_id
    );

    return 0; 
end;' language 'plpgsql';



-- show errors

-- create or replace package body apm_service
-- function new
create or replace function apm_service__new (integer,varchar,varchar,varchar,timestamptz,integer,varchar,integer)
returns integer as '
declare
  service_id             alias for $1;  -- default null  
  instance_name          alias for $2;  -- default null
  package_key            alias for $3;  
  object_type            alias for $4;  -- default ''apm_service''
  creation_date          alias for $5;  -- default now()
  creation_user          alias for $6;  -- default null
  creation_ip            alias for $7;  -- default null
  context_id             alias for $8;  -- default null
  v_service_id           integer;       
begin
    v_service_id := apm_package__new (
      service_id,
      instance_name,
      package_key,
      object_type,
      creation_date,
      creation_user,
      creation_ip,
      context_id
    );

    return v_service_id;
   
end;' language 'plpgsql';


-- procedure delete
create or replace function apm_service__delete (integer)
returns integer as '
declare
  delete__service_id    alias for $1;  
begin
    delete from apm_services
    where service_id = delete__service_id;
    PERFORM apm_package__delete(
	delete__service_id
    );

    return 0; 
end;' language 'plpgsql';









create or replace function apm__get_value (integer,varchar)
returns varchar as '
declare
  p_get_value__package_id             alias for $1;
  p_get_value__parameter_name         alias for $2;
  v_parameter_id                    apm_parameter_values.parameter_id%TYPE;
  value                             apm_parameter_values.attr_value%TYPE;
begin
    v_parameter_id := apm__id_for_name (p_get_value__package_id, p_get_value__parameter_name);

    select attr_value into value from apm_parameter_values v
    where v.package_id = p_get_value__package_id
    and parameter_id = v_parameter_id;

    return value;

end;' language 'plpgsql' stable strict;

create or replace function apm__get_value (varchar,varchar)
returns varchar as '
declare
  get_value__package_key            alias for $1;
  get_value__parameter_name         alias for $2;
  v_parameter_id                    apm_parameter_values.parameter_id%TYPE;
  value                             apm_parameter_values.attr_value%TYPE;
begin
    v_parameter_id := apm__id_for_name (get_value__package_key, get_value__parameter_name);

    select attr_value into value from apm_parameter_values v
    where v.package_id is null
    and parameter_id = get_value__parameter_id;

    return value;

end;' language 'plpgsql' stable strict;
