-- /packages/intranet-core/sql/postgres/cleanup-etp.sql
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
-- Remove any traces of the ETP (Edit This page) package from the data-model
--

delete from im_rest_object_types where object_type in ('journal_article', 'journal_issue');


drop view if exists journal_articlei cascade;
-- drop function if exists journal_article_f(journal_articlei);
drop view if exists journal_articlex;
delete from acs_attributes where object_type = 'journal_article';
delete from acs_object_types where object_type = 'journal_article';
-- drop rule if exists journal_article_r on journal_articlei;
select content_type__drop_type('journal_article', 'f', 'f');


drop view if exists journal_issuei cascade;
-- drop function if exists journal_issue_f(journal_issuei);
drop view if exists journal_issuex;
delete from acs_attributes where object_type = 'journal_issue';
delete from acs_object_types where object_type = 'journal_issue';
-- drop rule if exists journal_issue_r on journal_issuei;
select content_type__drop_type('journal_issue', 'f', 'f');


