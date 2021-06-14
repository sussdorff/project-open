-- 
-- packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.0.4-4.0.3.0.5.sql
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
-- @creation-date 2012-03-02
-- @cvs-id $Id$
--

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.0.0.9-4.1.0.0.10.sql','');

-- --------------------------------------------------------
-- Projects Trigger
-- --------------------------------------------------------

drop trigger im_projects_calendar_update_tr on im_projects;
drop function im_projects_calendar_update_tr();

create or replace function im_projects_calendar_update_tr () returns trigger as '
declare
	v_cal_item_id		integer;	

	v_timespan_id		integer;
	v_interval_id		integer;
	v_calendar_id		integer;
	v_activity_id		integer;
	v_recurrence_id		integer;
begin
	-- -------------- Skip if start or end date are null ------------
	IF new.start_date is null OR new.end_date is null THEN
		return new;
	END IF;

	-- -------------- Check if the entry already exists ------------
	v_cal_item_id := null;

	SELECT	event_id
	INTO	v_cal_item_id
	FROM	acs_events
	WHERE	related_object_id = new.project_id
		and related_object_type = ''im_project'';

	-- --------------------- Create entry if it isnt there -------------
	IF v_cal_item_id is null THEN

		v_timespan_id := timespan__new(new.end_date - interval ''1 hour'', new.end_date);
		RAISE NOTICE ''im_projects_calendar_update_tr: timespan_id=%'', v_timespan_id;
	
		v_activity_id := acs_activity__new(
			null, 
			new.project_name,
			new.description, 
			''f'', 
			'''', 
			''acs_activity'', now(), null, ''0.0.0.0'', null
		);
		RAISE NOTICE ''im_projects_calendar_update_tr: v_activity_id=%'', v_activity_id;
	
		SELECT	min(calendar_id)
		INTO 	v_calendar_id
		FROM	calendars
		WHERE	private_p = ''f'';
	
		v_recurrence_id := NULL;
		v_cal_item_id := cal_item__new (
			null,			-- cal_item_id
			v_calendar_id,		-- on_which_calendar
			new.project_name,	-- name
			new.description,	-- description
			''f'',			-- html_p
			'''',			-- status_summary
			v_timespan_id,		-- timespan_id
			v_activity_id,		-- activity_id
			v_recurrence_id,	-- recurrence_id
			''cal_item'', null, now(), null, ''0.0.0.0''	
		);
		RAISE NOTICE ''im_projects_calendar_update_tr: cal_id=%'', v_cal_item_id;

	END IF;

	-- --------------------- Update the entry --------------------
	SELECT	activity_id	INTO v_activity_id	FROM acs_events	WHERE	event_id = v_cal_item_id;
	SELECT	timespan_id	INTO v_timespan_id	FROM acs_events	WHERE	event_id = v_cal_item_id;
	SELECT	recurrence_id	INTO v_recurrence_id	FROM acs_events	WHERE	event_id = v_cal_item_id;

	-- Update the event
	UPDATE	acs_events 
	SET	name = new.project_name,
		description = new.description,
		related_object_id = new.project_id,
		related_object_type = ''im_project'',
		related_link_url = ''/intranet/projects/view?project_id=''||new.project_id,
		related_link_text = new.project_name || '' Project'',
		redirect_to_rel_link_p = ''t''
	WHERE	event_id = v_cal_item_id;

	-- Update the activity - same as event
	UPDATE	acs_activities
	SET	name = new.project_name,
		description = new.description
	WHERE	activity_id = v_activity_id;

	-- Update the timespan. Make sure there is only one interval
	-- in this timespan (there may be multiples)
	SELECT	interval_id	INTO v_interval_id	FROM timespans	WHERE	timespan_id = v_timespan_id;

	RAISE NOTICE ''cal_update_tr: cal_item:%, activity:%, timespan:%, recurrence:%, interval:%'', 
			v_cal_item_id, v_activity_id, v_timespan_id, v_recurrence_id, v_interval_id;

	UPDATE	time_intervals
	SET	start_date = new.end_date - interval ''1 hour'',
		end_date = new.end_date
	WHERE	interval_id = v_interval_id;

	return new;
end;' language 'plpgsql';

create trigger im_projects_calendar_update_tr after insert or update
on im_projects for each row
execute procedure im_projects_calendar_update_tr ();
