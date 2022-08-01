-- upgrade-4.0.3.3.6-4.0.3.3.7.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.3.6-4.0.3.3.7.sql','');

-- http://openacs.org/forums/message-view?message_id=3970549
create or replace function apm__get_value(int4,varchar) returns varchar as '
   declare
     get_value__package_id             alias for $1; 
     get_value__parameter_name         alias for $2; 
     v_parameter_id                    apm_parameter_values.parameter_id%TYPE;
     value                             apm_parameter_values.attr_value%TYPE;
   begin
       v_parameter_id := apm__id_for_name (get_value__package_id, get_value__parameter_name);
  
       select attr_value into value from apm_parameter_values v
       where v.package_id = get_value__package_id
       and parameter_id = v_parameter_id;
  
       return value;
     
   end;' language 'plpgsql';



