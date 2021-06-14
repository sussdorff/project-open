-- 
-- packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.0.1.0.5-4.0.1.0.6.sql
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
-- @creation-date 2011-08-08
--

SELECT acs_log__debug('/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade/upgrade-4.0.1.0.5-4.0.1.0.6.sql','');

update acs_object_types set status_column = 'task_status_id', type_column = 'task_type_id', status_type_table = 'im_timesheet_tasks' where object_type = 'im_timesheet_task';
update im_timesheet_tasks set task_type_id = 9500 where task_type_id is null;

create or replace function im_timesheet_task__new (
	integer, varchar, timestamptz, integer, varchar, integer,
	varchar, varchar, integer, integer, integer, integer, integer, integer, varchar
) returns integer as '
declare
	p_task_id		alias for $1;		-- timesheet task_id default null
	p_object_type		alias for $2;		-- object_type default ''im_timesheet task''
	p_creation_date		alias for $3;		-- creation_date default now()
	p_creation_user		alias for $4;		-- creation_user
	p_creation_ip		alias for $5;		-- creation_ip default null
	p_context_id		alias for $6;		-- context_id default null

	p_task_nr		alias for $7;
	p_task_name		alias for $8;
	p_project_id		alias for $9;
	p_material_id		alias for $10;
	p_cost_center_id	alias for $11;
	p_uom_id		alias for $12;
	p_task_type_id		alias for $13;
	p_task_status_id	alias for $14;
	p_description		alias for $15;

	v_task_id		integer;
	v_company_id		integer;
begin
	select	p.company_id into v_company_id from im_projects p
	where	p.project_id = p_project_id;

	v_task_id := im_project__new (
		p_task_id,		-- object_id
		p_object_type,		-- object_type
		p_creation_date,	-- creation_date
		p_creation_user,	-- creation_user
		p_creation_ip,		-- creation_ip
		p_context_id,		-- context_id

		p_task_name,		-- project_name
		p_task_nr,		-- project_nr
		p_task_nr,		-- project_path
		p_project_id,		-- parent_id
		v_company_id,		-- company_id
		100,		-- project_type
		76	-- project_status
	);

	update	im_projects
	set	description = p_description
	where	project_id = v_task_id;

	insert into im_timesheet_tasks (
		task_id,
		material_id,
		uom_id,
		cost_center_id,
		task_type_id,
		task_status_id
	) values (
		v_task_id,
		p_material_id,
		p_uom_id,
		p_cost_center_id,
		p_task_type_id,
		p_task_status_id
	);

	return v_task_id;
end;' language 'plpgsql';
