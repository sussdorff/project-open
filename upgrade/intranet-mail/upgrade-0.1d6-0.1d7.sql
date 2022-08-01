-- 
-- packages/intranet-mail/sql/postgresql/upgrade/upgrade-0.1d6-0.1d7.sql
-- 
-- Copyright (c) 2011, cognovís GmbH, Hamburg, Germany
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
-- 
-- @author Malte Sussdorff (malte.sussdorff@cognovis.de)
-- @creation-date 2011-04-27
-- @cvs-id $Id$
--

SELECT acs_log__debug('/packages/intranet-mail/sql/postgresql/upgrade/upgrade-0.1d6-0.1d7.sql','');


-- Component for projects
SELECT im_component_plugin__new (
        null,                           -- plugin_id
        'acs_object',                   -- object_type
        now(),                          -- creation_date
        null,                           -- creation_user
        null,                           -- creation_ip
        null,                           -- context_id
        'Intranet Mail Project Component',        -- plugin_name
        'intranet-mail',                  -- package_name
        'right',                        -- location
        '/intranet/projects/view',      -- page_url
        null,                           -- view_name
        12,                             -- sort_order
        'im_mail_project_component -project_id $project_id -return_url $return_url'
);

-- Component for tasks
SELECT im_component_plugin__new (
        null,                           -- plugin_id
        'acs_object',                   -- object_type
        now(),                          -- creation_date
        null,                           -- creation_user
        null,                           -- creation_ip
        null,                           -- context_id
        'Intranet Mail Task Component',        -- plugin_name
        'intranet-mail',                  -- package_name
        'right',                        -- location
        '/intranet-cognovis/tasks/view',      -- page_url
        null,                           -- view_name
        12,                             -- sort_order
        'im_mail_project_component -project_id $task_id -return_url $return_url'
);