-- upgrade-5.0.0.0.5-5.0.0.0.6.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.0.0.5-5.0.0.0.6.sql','');


-- http://openacs.org/bugtracker/openacs/bug?bug_number=3290
create or replace function acs_object__get_attribute(int4,varchar) returns text as $BODY$
declare
  object_id_in           alias for $1;  
  attribute_name_in      alias for $2;  
  v_table_name           varchar(200);  
  v_column               varchar(200);  
  v_key_sql              text; 
  v_return               text; 
  v_storage              text;
  v_rec                  record;
begin

   v_storage := acs_object__get_attribute_storage(object_id_in, attribute_name_in);

   v_column     := acs_object__get_attr_storage_column(v_storage);
   v_table_name := acs_object__get_attr_storage_table(v_storage);
   v_key_sql    := acs_object__get_attr_storage_sql(v_storage);

   RAISE NOTICE 'v_column: %, v_table_name: %, v_key_sql: % ', v_column,v_table_name,v_key_sql;
      
   for v_rec in execute 'select ' || quote_ident(v_column) || '::text as col_return from ' || quote_ident(v_table_name) || ' where ' || v_key_sql
      LOOP
        v_return := v_rec.col_return;
        exit;
   end loop;
   if not FOUND then 
       return null;
   end if;

   return v_return;

end;$BODY$ language 'plpgsql';
