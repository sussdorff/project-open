-- /packages/intranet-core/sql/postgres/cleanup-ams.sql
--
-- Copyright (C) 1999-2016 various parties
--
-- This program is free software. You can redistribute it
-- and/or modify it under the terms of the GNU General
-- Public License as published by the Free Software Foundation;
-- either version 2 of the License, or (at your option)
-- any later version. This program is distributed in the
-- hope that it will be useful, but WITHOUT ANY WARRANTY;
-- without even the implied warranty of MERCHANTABILITY or
-- FITNESS FOR A PARTICULAR PURPOSE.
-- See the GNU General Public License for more details.
--
-- @author	frank.bergmann@project-open.com

-------------------------------------------------------------
-- Remove any traces of the AMS package from the data-model
--

DROP SEQUENCE if exists public.ams_options_seq;
DROP SEQUENCE if exists public.ams_option_map_id_seq;
DROP SEQUENCE if exists public.ams_list_attribute_sort_order_seq;
DROP VIEW if exists public.ams_lists;
DROP VIEW if exists public.ams_list_attribute_map;
DROP VIEW if exists public.ams_attributes;

delete from acs_function_args
where lower(function) in (
      'ams_attribute__new', 
      'ams_object_revision__new', 
      'ams_list__new'
);


delete from acs_attributes where object_type like 'ams_%';

CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS $BODY$

declare
        v_count                 integer;
begin

	select count(*) into v_count from pg_tables where tablename = 'im_rest_object_types';

        IF      0 != v_count
        THEN
		delete from im_rest_object_types where object_type like 'ams_%';
        END IF;
        return 1;

end;$BODY$ LANGUAGE 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();

delete from acs_object_types where object_type like 'ams_%';

delete from cr_folder_type_map where lower(content_type) like 'ams_%';

