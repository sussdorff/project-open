-- /packages/intranet-core/sql/postgres/cleanup-tsearch2.sql
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



-- Drop triggers that are available in all ]po[ configurations
drop trigger if exists cr_items_tsearch_tr on cr_items;
drop trigger if exists im_forum_topics_tsearch_tr on im_forum_topics;
drop trigger if exists im_projects_tsearch_tr on im_projects;
drop trigger if exists im_companies_tsearch_tr on im_companies;
drop trigger if exists persons_tsearch_tr on persons;
drop trigger if exists im_invoices_tsearch_tr on im_invoices;
drop trigger if exists im_conf_items_tsearch_tr on im_conf_items; 

DROP TRIGGER IF EXISTS im_fs_files_tsearch_tr ON im_fs_files;
DROP TRIGGER IF EXISTS im_tickets_tsearch_tr ON im_tickets;

drop function if exists content_item_tsearch ();
drop function if exists im_forum_topics_tsearch ();
drop function if exists persons_tsearch ();
drop function if exists im_projects_tsearch ();
drop function if exists im_companies_tsearch ();
drop function if exists im_search_update (integer, varchar, integer, varchar);
drop function if exists norm_text (varchar);
drop function if exists norm_text_utf8 (varchar);
drop function if exists im_conf_items_tsearch();

drop table if exists im_search_objects;
drop table if exists im_search_object_types;

