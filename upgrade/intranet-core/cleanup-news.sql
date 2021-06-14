-- /packages/intranet-core/sql/postgres/cleanup-news.sql
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




update cr_items set live_revision = null 
where live_revision in (select object_id from acs_objects where object_type = 'news_item');
update cr_items set latest_revision = null 
where latest_revision in (select object_id from acs_objects where object_type = 'news_item');
delete from cr_items where content_type = 'news_item';
delete from cr_type_template_map where content_type = 'news_item';
delete from im_rest_object_types where object_type = 'news_item';
delete from acs_objects where object_type = 'news_item';



delete from acs_attributes where object_type = 'news_item';
delete from acs_object_types where object_type = 'news_item';
delete from acs_sc_impl_aliases where impl_name = 'news_item';
delete from acs_sc_impls where impl_name = 'news_item';
delete from cr_folder_type_map where content_type = 'news_item';


-- ALTER TABLE ONLY public.etp_page_revisions DROP CONSTRAINT "$1";
-- DROP RULE etp_page_revisions_r ON public.etp_page_revisionsi;
-- ALTER TABLE ONLY public.etp_page_revisions DROP CONSTRAINT etp_page_revisions_pkey;
-- DROP VIEW public.etp_page_revisionsx;
-- DROP FUNCTION public.etp_page_revisions_f(p_new etp_page_revisionsi);
-- DROP VIEW public.etp_page_revisionsi;
-- DROP TABLE public.etp_page_revisions;


-- delete from acs_attributes where object_type = 'etp_page_revision';
-- delete from acs_object_types where object_type = 'etp_page_revision';
-- delete from acs_sc_impl_aliases where impl_name = 'etp_page_revision';
-- delete from acs_sc_impls where impl_name = 'etp_page_revision';
-- delete from cr_folder_type_map where content_type = 'etp_page_revision';
