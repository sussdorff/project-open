-- /packages/intranet-core/sql/postgres/cleanup-events.sql
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
-- 
--



drop function acs_activity__new (integer,varchar,text,boolean,text,varchar,timestamptz,integer,varchar,integer);

-- added
select define_function_args('acs_activity__new','activity_id;null,name,description;null,html_p;f,status_summary;null,object_type;acs_activity,creation_date;now(),creation_user;null,creation_ip;null,context_id;null');

--
-- procedure acs_activity__new/10
--
CREATE OR REPLACE FUNCTION acs_activity__new(
   new__activity_id integer,                    -- default null,
   new__name varchar,
   new__description text,          -- default null,
   new__html_p boolean,            -- default 'f',
   new__status_summary text,       -- default null,
   new__object_type varchar,       -- default 'acs_activity'
   new__creation_date timestamptz, -- default now(),
   new__creation_user integer,     -- default null,
   new__creation_ip varchar,       -- default null,
   new__context_id integer         -- default null

) RETURNS integer AS $$
		 -- return acs_activities.activity_id%TYPE
DECLARE       
       v_activity_id		  acs_activities.activity_id%TYPE;
BEGIN
       v_activity_id := acs_object__new(
            new__activity_id,	   -- object_id
            new__object_type,	   -- object_type
            new__creation_date,    -- creation_date  
            new__creation_user,    -- creation_user
            new__creation_ip,	   -- creation_ip
            new__context_id,	   -- context_id
            't',		   -- security_inherit_p
            new__name,		   -- title
            null		   -- package_id
	    );

       insert into acs_activities
            (activity_id, name, description, html_p, status_summary)
       values
            (v_activity_id, new__name, new__description, new__html_p, new__status_summary);

       return v_activity_id;

END;
$$ LANGUAGE plpgsql; 


drop function acs_activity__edit (integer,varchar,text,boolean,text);

-- added
select define_function_args('acs_activity__edit','activity_id,name;null,description;null,html_p;null,status_summary;null');

--
-- procedure acs_activity__edit/5
--
CREATE OR REPLACE FUNCTION acs_activity__edit(
   edit__activity_id integer,
   edit__name varchar,       -- default null,
   edit__description text,   -- default null,
   edit__html_p boolean,     -- default null
   edit__status_summary text -- default null

) RETURNS integer AS $$
DECLARE
BEGIN

       update acs_activities
       set    name        = coalesce(edit__name, name),
              description = coalesce(edit__description, description),
              html_p      = coalesce(edit__html_p, html_p),
              status_summary = coalesce(edit__status_summary, status_summary)
       where activity_id  = edit__activity_id;

       update acs_objects
       set    title = coalesce(edit__name, name)
       where activity_id  = edit__activity_id;

       return 0;

END;
$$ LANGUAGE plpgsql;



create or replace function acs_event__get_html_p (
       --
       -- Returns html_p or html_p of the activity associated with the event if 
       -- html_p is null.
       --
       -- @author W. Scott Meeks
       --
       -- @param event_id id of event to get html_p for
       --
       -- @return The html_p or html_p of the activity associated with the event if html_p is null.
       --
       get_html_p__event_id integer
)
returns boolean as $$
declare
       v_html_p		acs_events.html_p%TYPE; 
begin
       select coalesce(e.html_p, a.html_p) into v_html_p
       from  acs_events e
       left join acs_activities a
       on (e.activity_id = a.activity_id)
       where e.event_id = get_html_p__event_id;

       return v_html_p;

end;
$$ language plpgsql;



-- added
select define_function_args('acs_event__get_status_summary','event_id');

--
-- procedure acs_event__get_status_summary/1
--
CREATE OR REPLACE FUNCTION acs_event__get_status_summary(
   get_status_summary__event_id integer

) RETURNS boolean AS $$
DECLARE
       v_status_summary		acs_events.status_summary%TYPE; 
BEGIN
       select coalesce(e.status_summary, a.status_summary) into v_status_summary
       from  acs_events e
       left join acs_activities a
       on (e.activity_id = a.activity_id)
       where e.event_id = get_status_summary__event_id;

       return v_status_summary;

END;
$$ LANGUAGE plpgsql;



-- added
select define_function_args('acs_event__new','event_id;null,name;null,description;null,html_p;null,status_summary;null,timespan_id;null,activity_id;null,recurrence_id;null,object_type;acs_event,creation_date;now(),creation_user;null,creation_ip;null,context_id;null,package_id;null');


--
-- procedure acs_event__new/14
--
CREATE OR REPLACE FUNCTION acs_event__new(
   new__event_id integer,          -- default null,
   new__name varchar,              -- default null,
   new__description text,          -- default null,
   new__html_p boolean,            -- default null
   new__status_summary text,       -- default null
   new__timespan_id integer,       -- default null,
   new__activity_id integer,       -- default null,
   new__recurrence_id integer,     -- default null,
   new__object_type varchar,       -- default 'acs_event',
   new__creation_date timestamptz, -- default now(),
   new__creation_user integer,     -- default null,
   new__creation_ip varchar,       -- default null,
   new__context_id integer,        -- default null
   new__package_id integer         -- default null

) RETURNS integer AS $$
	-- acs_events.event_id%TYPE
DECLARE
       v_event_id	    acs_events.event_id%TYPE;
BEGIN
       v_event_id := acs_object__new(
            new__event_id,	-- object_id
            new__object_type,	-- object_type
            new__creation_date, -- creation_date
            new__creation_user,	-- creation_user
            new__creation_ip,	-- creation_ip
            new__context_id,	-- context_id
            't',		-- security_inherit_p
            new__name,		-- title
            new__package_id	-- package_id
	    );

       insert into acs_events
            (event_id, name, description, html_p, status_summary, activity_id, timespan_id, recurrence_id)
       values
            (v_event_id, new__name, new__description, new__html_p, new__status_summary, new__activity_id, new__timespan_id,
             new__recurrence_id);

       return v_event_id;

END;
$$ LANGUAGE plpgsql;

-- backwards compatible 13 param version
CREATE OR REPLACE FUNCTION acs_event__new ( 
       integer,
       varchar,
       text,
       boolean,
       text,
       integer,
       integer,
       integer,
       varchar,
       timestamptz,
       integer,
       varchar,
       integer
) RETURNS integer AS $$
BEGIN
       return acs_event__new($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,null);
END;
$$ LANGUAGE plpgsql;




-- added
select define_function_args('acs_event__new_instance','event_id,date_offset');

--
-- procedure acs_event__new_instance/2
--
CREATE OR REPLACE FUNCTION acs_event__new_instance(
   new_instance__event_id integer,
   new_instance__date_offset interval

) RETURNS integer AS $$
DECLARE
       event_row		  acs_events%ROWTYPE;
       object_row		  acs_objects%ROWTYPE;
       v_event_id		  acs_events.event_id%TYPE;
       v_timespan_id		  acs_events.timespan_id%TYPE;
BEGIN

       -- Get event parameters
       select * into event_row
       from   acs_events
       where  event_id = new_instance__event_id;

       -- Get object parameters                
       select * into object_row
       from   acs_objects
       where  object_id = new_instance__event_id;

       -- We allow non-zero offset, so we copy
       v_timespan_id := timespan__copy(event_row.timespan_id, new_instance__date_offset);

       -- Create a new instance
       v_event_id := acs_event__new(
	    null,                     -- event_id (default)
            event_row.name,           -- name
            event_row.description,    -- description
            event_row.html_p,         -- html_p
            event_row.status_summary, -- status_summary
            v_timespan_id,	      -- timespan_id
            event_row.activity_id,    -- activity_id
            event_row.recurrence_id,  -- recurrence_id
	    'acs_event',	      -- object_type (default)
	    now(),		      -- creation_date (default)
            object_row.creation_user, -- creation_user
            object_row.creation_ip,   -- creation_ip
            object_row.context_id,     -- context_id
            object_row.package_id     -- context_id
	    );

      return v_event_id;

END;
$$ LANGUAGE plpgsql;




-- added
select define_function_args('acs_event__insert_instances','event_id,cutoff_date;null');

--
-- procedure acs_event__insert_instances/2
--
CREATE OR REPLACE FUNCTION acs_event__insert_instances(
   insert_instances__event_id integer,
   insert_instances__cutoff_date timestamptz -- default null

) RETURNS integer AS $$
DECLARE
       event_row		       acs_events%ROWTYPE;
       recurrence_row		       recurrences%ROWTYPE;
       v_event_id		       acs_events.event_id%TYPE;
       v_interval_name		       recurrence_interval_types.interval_name%TYPE;
       v_n_intervals		       recurrences.every_nth_interval%TYPE;
       v_days_of_week		       recurrences.days_of_week%TYPE;
       v_last_date_done		       timestamptz;
       v_stop_date		       timestamptz;
       v_start_date		       timestamptz;
       v_event_date		       timestamptz;
       v_diff			       integer;
       v_current_date		       timestamptz;
       v_last_day		       timestamptz;
       v_week_date		       timestamptz;
       v_instance_count		       integer;
       v_days_length		       integer;
       v_days_index		       integer;
       v_day_num		       integer;
       rec_execute		       record;
       v_new_current_date              timestamptz;
       v_offset_notice interval;
BEGIN

	-- Get event parameters
        select * into event_row
        from   acs_events
        where  event_id = insert_instances__event_id;

	-- Get recurrence information
        select * into recurrence_row
        from   recurrences
        where  recurrence_id = event_row.recurrence_id;
        

        -- Set cutoff date to stop populating the DB with recurrences
        -- EventFutureLimit is in years. (a parameter of the service)
        if insert_instances__cutoff_date is null then
           v_stop_date := add_months(now(), 12 * to_number(acs_event__get_value('EventFutureLimit'),'99999')::INT);
        else
           v_stop_date := insert_instances__cutoff_date;
        end if;
        
        -- Events only populated until max(cutoff_date, recur_until)
        -- If recur_until null, then defaults to cutoff_date
        if recurrence_row.recur_until < v_stop_date then
           v_stop_date := recurrence_row.recur_until;
        end if;
        
        -- Figure out the date to start from.
	-- JS: I do not understand why the date must be truncated to the midnight of the event date
        select min(start_date)
        into   v_event_date
        from   acs_events_dates
        where  event_id = insert_instances__event_id;

        if recurrence_row.db_populated_until is null then
           v_start_date := v_event_date;
        else
           v_start_date := recurrence_row.db_populated_until;
        end if;
        
        v_current_date   := v_start_date;
        v_last_date_done := v_start_date;
        v_n_intervals    := recurrence_row.every_nth_interval;
        
        -- Case off of the interval_name to make code easier to read
        select interval_name into v_interval_name
        from   recurrences r, 
               recurrence_interval_types t
        where  recurrence_id   = recurrence_row.recurrence_id
        and    r.interval_type = t.interval_type;
        
        -- Week has to be handled specially.
        -- Start with the beginning of the week containing the start date.
        if v_interval_name = 'week' 
	then
            v_current_date := next_day(v_current_date - to_interval(7,'days'),'SUNDAY');
            v_days_of_week := recurrence_row.days_of_week;
            v_days_length  := char_length(v_days_of_week);
        end if;
        
        -- Check count to prevent runaway in case of error
        v_instance_count := 0;

	-- A feature: we only care about the date when populating the database for reccurrence.
        while v_instance_count < 10000 and (date_trunc('day',v_last_date_done) <= date_trunc('day',v_stop_date))
        loop
            v_instance_count := v_instance_count + 1;
        
            -- Calculate next date based on interval type

	    -- Add next day, skipping every v_n_intervals
	    if v_interval_name = 'day' 
	    then
                v_current_date := v_current_date + to_interval(v_n_intervals,'days');
	    end if;
        
	    -- Add a full month, skipping by v_n_intervals months
            if v_interval_name = 'month_by_date' 
	    then
                v_current_date := add_months(v_current_date, v_n_intervals);
	    end if;

	    -- Add days so that the next date will have the same day of the week,  and week of the month
            if v_interval_name = 'month_by_day' then
                -- Find last day of month before correct month
                v_last_day := add_months(last_day(v_current_date), v_n_intervals - 1);
                -- Find correct week and go to correct day of week
                v_current_date := next_day(v_last_day + 
				              to_interval(7 * (to_number(to_char(v_current_date,'W'),'99')::INT - 1),
							  'days'),
                                            to_char(v_current_date, 'DAY'));
	    end if;

	    -- Add days so that the next date will have the same day of the week on the last week of the month
            if v_interval_name = 'last_of_month' then
                -- Find last day of correct month
                v_last_day := last_day(add_months(v_current_date, v_n_intervals));
                -- Back up one week and find correct day of week
                v_current_date := next_day(v_last_day ::timestamp - to_interval(7,'days') :: timestamptz, to_char(v_current_date, 'DAY'));
	    end if;

	    -- Add a full year (12 months)
            If v_interval_name = 'year' then
                v_current_date := add_months(v_current_date, 12 * v_n_intervals);
	    end if;

            -- Deal with custom function
            if v_interval_name = 'custom' then

	        -- JS: Execute a dynamically created query on the fly...
	        FOR rec_execute IN
		EXECUTE 'select ' || recurrence_row.custom_func 
				    || '(' || quote_literal(v_current_date)
				    || ',' || v_n_intervals || ') as current_date'
		LOOP
		     v_current_date := rec_execute.current_date;
		END LOOP;

            end if;
        
            -- Check to make sure we are not going past Trunc because dates are not integral
            exit when date_trunc('day',v_current_date) > date_trunc('day',v_stop_date);
        
            -- Have to handle week specially
            if v_interval_name = 'week' then
                -- loop over days_of_week extracting each day number
                -- add day number and insert
                v_days_index := 1;
                v_week_date  := v_current_date;
                while v_days_index <= v_days_length loop
                    v_day_num   := SUBSTR(v_days_of_week, v_days_index, 1);
                    v_week_date := (v_current_date ::timestamp + to_interval(v_day_num,'days')) :: timestamptz;
	           if date_trunc('day',v_week_date) > date_trunc('day',v_start_date) 
		       and date_trunc('day',v_week_date) <= date_trunc('day',v_stop_date) then
                         -- This is where we add the event
                         v_event_id := acs_event__new_instance(
                              insert_instances__event_id,					   -- event_id
                              date_trunc('day',v_week_date) - date_trunc('day',v_event_date)    -- offset
                         );
                         v_last_date_done := v_week_date;

                     else if date_trunc('day',v_week_date) > date_trunc('day',v_stop_date) 
		          then
                             -- Gone too far
                             exit;
			  end if;

                     end if;

                     v_days_index := v_days_index + 2;

                 end loop;

                 -- Now move to next week with repeats.
                v_current_date := (v_current_date :: timestamp + to_interval(7 * v_n_intervals,'days')) :: timestamptz;
            else
                -- All other interval types
                -- This is where we add the event
                v_event_id := acs_event__new_instance(
                    insert_instances__event_id,						    -- event_id 
                    date_trunc('day',v_current_date ::timestamp) - date_trunc('day',v_event_date ::timestamp)   -- offset
                );
                v_last_date_done := v_current_date;
            end if;
        end loop;
        
        update recurrences
        set    db_populated_until = v_last_date_done
        where  recurrence_id      = recurrence_row.recurrence_id;

	return 0;
END;
$$ LANGUAGE plpgsql;



-- added
select define_function_args('time_interval__copy','interval_id,offset;0');

--
-- procedure time_interval__copy/2
--
CREATE OR REPLACE FUNCTION time_interval__copy(
   copy__interval_id integer,
   copy__offset interval -- default 0

) RETURNS integer AS $$
-- time_intervals.interval_id%TYPE
DECLARE    
       interval_row           time_intervals%ROWTYPE;
       v_foo                 timestamptz;
BEGIN
       select * into interval_row
       from   time_intervals
       where  interval_id = copy__interval_id;
	
       return time_interval__new(
                  (interval_row.start_date ::timestamp + copy__offset) :: timestamptz,
                  (interval_row.end_date ::timestamp + copy__offset) :: timestamptz
       );

END;
$$ LANGUAGE plpgsql; 



-- 
-- packages/acs-events/sql/postgresql/upgrade/upgrade-0.6d2-0.6d3.sql
-- 
-- @author Dave Bauer (dave@thedesignexperience.org)
-- @creation-date 2007-09-27
-- @cvs-id $Id: cleanup-events.sql,v 1.1 2016/01/11 12:05:56 cvs Exp $
--
-- Fix Daylight Saving Time bug when creating recurring events



-- added
select define_function_args('acs_event__insert_instances','event_id,cutoff_date;null');

--
-- procedure acs_event__insert_instances/2
--
CREATE OR REPLACE FUNCTION acs_event__insert_instances(
   insert_instances__event_id integer,
   insert_instances__cutoff_date timestamptz -- default null

) RETURNS integer AS $$
DECLARE
       event_row		       acs_events%ROWTYPE;
       recurrence_row		       recurrences%ROWTYPE;
       v_event_id		       acs_events.event_id%TYPE;
       v_interval_name		       recurrence_interval_types.interval_name%TYPE;
       v_n_intervals		       recurrences.every_nth_interval%TYPE;
       v_days_of_week		       recurrences.days_of_week%TYPE;
       v_last_date_done		       timestamptz;
       v_stop_date		       timestamptz;
       v_start_date		       timestamptz;
       v_event_date		       timestamptz;
       v_diff			       integer;
       v_current_date		       timestamptz;
       v_last_day		       timestamptz;
       v_week_date		       timestamptz;
       v_instance_count		       integer;
       v_days_length		       integer;
       v_days_index		       integer;
       v_day_num		       integer;
       rec_execute		       record;
       v_new_current_date              timestamptz;
       v_offset_notice interval;
BEGIN

	-- Get event parameters
        select * into event_row
        from   acs_events
        where  event_id = insert_instances__event_id;

	-- Get recurrence information
        select * into recurrence_row
        from   recurrences
        where  recurrence_id = event_row.recurrence_id;
        

        -- Set cutoff date to stop populating the DB with recurrences
        -- EventFutureLimit is in years. (a parameter of the service)
        if insert_instances__cutoff_date is null then
           v_stop_date := add_months(now(), 12 * to_number(acs_event__get_value('EventFutureLimit'),'99999')::INT);
        else
           v_stop_date := insert_instances__cutoff_date;
        end if;
        
        -- Events only populated until max(cutoff_date, recur_until)
        -- If recur_until null, then defaults to cutoff_date
        if recurrence_row.recur_until < v_stop_date then
           v_stop_date := recurrence_row.recur_until;
        end if;
        
        -- Figure out the date to start from.
	-- JS: I do not understand why the date must be truncated to the midnight of the event date
        select min(start_date)
        into   v_event_date
        from   acs_events_dates
        where  event_id = insert_instances__event_id;

        if recurrence_row.db_populated_until is null then
           v_start_date := v_event_date;
        else
           v_start_date := recurrence_row.db_populated_until;
        end if;
        
        v_current_date   := v_start_date;
        v_last_date_done := v_start_date;
        v_n_intervals    := recurrence_row.every_nth_interval;
        
        -- Case off of the interval_name to make code easier to read
        select interval_name into v_interval_name
        from   recurrences r, 
               recurrence_interval_types t
        where  recurrence_id   = recurrence_row.recurrence_id
        and    r.interval_type = t.interval_type;
        
        -- Week has to be handled specially.
        -- Start with the beginning of the week containing the start date.
        if v_interval_name = 'week' 
	then
            v_current_date := next_day(v_current_date - to_interval(7,'days'),'SUNDAY');
            v_days_of_week := recurrence_row.days_of_week;
            v_days_length  := char_length(v_days_of_week);
        end if;
        
        -- Check count to prevent runaway in case of error
        v_instance_count := 0;

	-- A feature: we only care about the date when populating the database for reccurrence.
        while v_instance_count < 10000 and (date_trunc('day',v_last_date_done) <= date_trunc('day',v_stop_date))
        loop
            v_instance_count := v_instance_count + 1;
        
            -- Calculate next date based on interval type

	    -- Add next day, skipping every v_n_intervals
	    if v_interval_name = 'day' 
	    then
                v_current_date := v_current_date + to_interval(v_n_intervals,'days');
	    end if;
        
	    -- Add a full month, skipping by v_n_intervals months
            if v_interval_name = 'month_by_date' 
	    then
                v_current_date := add_months(v_current_date, v_n_intervals);
	    end if;

	    -- Add days so that the next date will have the same day of the week,  and week of the month
            if v_interval_name = 'month_by_day' then
                -- Find last day of month before correct month
                v_last_day := add_months(last_day(v_current_date), v_n_intervals - 1);
                -- Find correct week and go to correct day of week
                v_current_date := next_day(v_last_day + 
				              to_interval(7 * (to_number(to_char(v_current_date,'W'),'99')::INT - 1),
							  'days'),
                                            to_char(v_current_date, 'DAY'));
	    end if;

	    -- Add days so that the next date will have the same day of the week on the last week of the month
            if v_interval_name = 'last_of_month' then
                -- Find last day of correct month
                v_last_day := last_day(add_months(v_current_date, v_n_intervals));
                -- Back up one week and find correct day of week
                v_current_date := next_day(v_last_day ::timestamp - to_interval(7,'days') :: timestamptz, to_char(v_current_date, 'DAY'));
	    end if;

	    -- Add a full year (12 months)
            If v_interval_name = 'year' then
                v_current_date := add_months(v_current_date, 12 * v_n_intervals);
	    end if;

            -- Deal with custom function
            if v_interval_name = 'custom' then

	        -- JS: Execute a dynamically created query on the fly...
	        FOR rec_execute IN
		EXECUTE 'select ' || recurrence_row.custom_func 
				    || '(' || quote_literal(v_current_date)
				    || ',' || v_n_intervals || ') as current_date'
		LOOP
		     v_current_date := rec_execute.current_date;
		END LOOP;

            end if;
        
            -- Check to make sure we are not going past Trunc because dates are not integral
            exit when date_trunc('day',v_current_date) > date_trunc('day',v_stop_date);
        
            -- Have to handle week specially
            if v_interval_name = 'week' then
                -- loop over days_of_week extracting each day number
                -- add day number and insert
                v_days_index := 1;
                v_week_date  := v_current_date;
                while v_days_index <= v_days_length loop
                    v_day_num   := SUBSTR(v_days_of_week, v_days_index, 1);
                    v_week_date := (v_current_date ::timestamp + to_interval(v_day_num,'days')) :: timestamptz;
	           if date_trunc('day',v_week_date) > date_trunc('day',v_start_date) 
		       and date_trunc('day',v_week_date) <= date_trunc('day',v_stop_date) then
                         -- This is where we add the event
                         v_event_id := acs_event__new_instance(
                              insert_instances__event_id,					   -- event_id
                              date_trunc('day',v_week_date :: timestamp) - date_trunc('day',v_event_date :: timestamp)    -- offset
                         );
                         v_last_date_done := v_week_date;

                     else if date_trunc('day',v_week_date) > date_trunc('day',v_stop_date) 
		          then
                             -- Gone too far
                             exit;
			  end if;

                     end if;

                     v_days_index := v_days_index + 2;

                 end loop;

                 -- Now move to next week with repeats.
                v_current_date := (v_current_date :: timestamp + to_interval(7 * v_n_intervals,'days')) :: timestamptz;
            else
                -- All other interval types
                -- This is where we add the event
                v_event_id := acs_event__new_instance(
                    insert_instances__event_id,						    -- event_id 
                    date_trunc('day',v_current_date ::timestamp) - date_trunc('day',v_event_date ::timestamp)   -- offset
                );
                v_last_date_done := v_current_date;
            end if;
        end loop;
        
        update recurrences
        set    db_populated_until = v_last_date_done
        where  recurrence_id      = recurrence_row.recurrence_id;

	return 0;
END;
$$ LANGUAGE plpgsql;


create or replace function acs_event__recurrence_timespan_edit (
       p_event_id integer,
       p_start_date timestamptz,
       p_end_date timestamptz,
       p_edit_past_events_p boolean
) returns integer as $$
DECLARE
        v_timespan                   RECORD;
        v_one_start_date             timestamptz;
        v_one_end_date               timestamptz;
BEGIN
        -- get the initial offsets
        select start_date,
               end_date into v_one_start_date,
               v_one_end_date
        from time_intervals, 
             timespans, 
             acs_events 
        where time_intervals.interval_id = timespans.interval_id
          and timespans.timespan_id = acs_events.timespan_id
          and event_id=p_event_id;
        FOR v_timespan in
            select *
            from time_intervals
            where interval_id in (select interval_id
                                  from timespans 
                                  where timespan_id in (select timespan_id
                                                        from acs_events 
                                                        where recurrence_id = (select recurrence_id 
                                                                               from acs_events where event_id = p_event_id)))
           and (p_edit_past_events_p = 't' or start_date >= v_one_start_date)
        LOOP
                PERFORM time_interval__edit(v_timespan.interval_id, 
                                            (to_char(v_timespan.start_date,'yyyy-mm-dd') || ' ' || to_char(p_start_date,'hh24:mi:ss')) :: timestamptz, 
                                            (to_char(v_timespan.end_date,'yyyy-mm-dd') || ' ' || to_char(p_end_date,'hh24:mi:ss')) :: timestamptz);
        END LOOP;

        return p_event_id;
END;
$$ LANGUAGE plpgsql;

-- Allow editing only future recurrences
create or replace function acs_event__recurrence_timespan_edit (
        p_event_id integer,
        p_start_date timestamptz,
        p_end_date timestamptz
) returns integer as $$
DECLARE
BEGIN
    return acs_event__recurrence_timespan_edit (
           p_event_id,
           p_start_date,
           p_end_date,
           't');
END;
$$ LANGUAGE plpgsql;



-- 
-- 
-- 
-- @author Victor Guerra (vguerra@gmail.com)
-- @creation-date 2010-11-05
-- @cvs-id $Id: cleanup-events.sql,v 1.1 2016/01/11 12:05:56 cvs Exp $
--

-- PG 9.x support - changes regarding usage of sequences

drop view acs_events_seq;
drop sequence acs_events_sequence;
drop view timespan_seq;
drop view recurrence_seq;



-- added
select define_function_args('time_interval__new','start_date;null,end_date;null');

--
-- procedure time_interval__new/2
--
CREATE OR REPLACE FUNCTION time_interval__new(
   new__start_date timestamptz,  -- default null,
   new__end_date timestamptz     -- default null

) RETURNS integer AS $$
DECLARE
       v_interval_id     time_intervals.interval_id%TYPE;
BEGIN
       select nextval('timespan_sequence') into v_interval_id from dual;

       insert into time_intervals 
            (interval_id, start_date, end_date)
       values
            (v_interval_id, new__start_date, new__end_date);
                
       return v_interval_id;

END;
$$ LANGUAGE plpgsql; 



-- added

--
-- procedure timespan__new/2
--
CREATE OR REPLACE FUNCTION timespan__new(
   new__interval_id integer,
   new__copy_p boolean

) RETURNS integer AS $$
-- timespans.timespan_id%TYPE
DECLARE
        v_timespan_id           timespans.timespan_id%TYPE;
        v_interval_id           time_intervals.interval_id%TYPE;
BEGIN
        -- get a new id;
        select nextval('timespan_sequence') into v_timespan_id from dual;

        if new__copy_p
        then      
             -- JS: Note use of overloaded function (zero offset)
             v_interval_id := time_interval__copy(new__interval_id);
        else
             v_interval_id := new__interval_id;
        end if;
        
        insert into timespans
            (timespan_id, interval_id)
        values
            (v_timespan_id, v_interval_id);
        
        return v_timespan_id;

END;
$$ LANGUAGE plpgsql; 



-- added
select define_function_args('recurrence__new','interval_name,every_nth_interval,days_of_week;null,recur_until;null,custom_func;null');


--
-- procedure recurrence__new/5
--
CREATE OR REPLACE FUNCTION recurrence__new(
   new__interval_name varchar,
   new__every_nth_interval integer,
   new__days_of_week varchar,    -- default null,
   new__recur_until timestamptz, -- default null,
   new__custom_func varchar      -- default null

) RETURNS integer AS $$
	-- recurrences.recurrence_id%TYPE
DECLARE
       v_recurrence_id		  recurrences.recurrence_id%TYPE;
       v_interval_type_id	  recurrence_interval_types.interval_type%TYPE;
BEGIN

       select nextval('recurrence_sequence') into v_recurrence_id from dual;
        
       select interval_type
       into   v_interval_type_id 
       from   recurrence_interval_types
       where  interval_name = new__interval_name;
        
       insert into recurrences
            (recurrence_id, 
             interval_type, 
             every_nth_interval, 
             days_of_week,
             recur_until, 
             custom_func)
       values
            (v_recurrence_id, 
             v_interval_type_id, 
             new__every_nth_interval, 
             new__days_of_week,
             new__recur_until, 
             new__custom_func);
         
       return v_recurrence_id;

END;
$$ LANGUAGE plpgsql; 

select define_function_args('acs_event__recurrence_timespan_edit','event_id,start_date,end_date,edit_past_events_p');
create index acs_events_timespan_id_idx on acs_events(timespan_id);
select define_function_args('time_interval__copy','interval_id,offset;0');
select define_function_args('time_interval__delete','interval_id');
select define_function_args('time_interval__edit','interval_id,start_date;null,end_date;null');
select define_function_args('time_interval__eq','interval_1_id,interval_2_id');
select define_function_args('time_interval__overlaps_p','interval_id,start_date;null,end_date;null');
select define_function_args('time_interval__shift','interval_id,start_offset;0,end_offset;0');

select define_function_args('timespan__copy','timespan_id,offset');
select define_function_args('timespan__delete','timespan_id');
select define_function_args('timespan__exists_p','timespan_id');
select define_function_args('timespan__interval_delete','timespan_id,interval_id');
select define_function_args('timespan__join','timespan_id,start_date;null,end_date;null');
select define_function_args('timespan__join_interval','timespan_id,interval_id,copy_p;true');
select define_function_args('timespan__multi_interval_p','timespan_id');
select define_function_args('timespan__new','start_date;null,end_date;null');
select define_function_args('timespan__overlaps_interval_p','timespan_id,interval_id;null');
select define_function_args('timespan__overlaps_p','timespan_id,start_date;null,end_date;null');

select define_function_args('acs_event__new','event_id;null,name;null,description;null,html_p;null,status_summary;null,timespan_id;null,activity_id;null,recurrence_id;null,object_type;acs_event,creation_date;now(),creation_user;null,creation_ip;null,context_id;null,package_id;null');
select define_function_args('acs_event__delete','event_id');
select define_function_args('acs_event__delete_all_recurrences','recurrence_id;null');
select define_function_args('acs_event__delete_all','event_id');
select define_function_args('acs_event__get_name','event_id');
select define_function_args('acs_event__get_description','event_id');
select define_function_args('acs_event__get_html_p','event_id');
select define_function_args('acs_event__get_status_summary','event_id');
select define_function_args('acs_event__timespan_set','event_id,timespan_id');
select define_function_args('acs_event__recurrence_timespan_edit','event_id,start_date,end_date,edit_past_events_p');
select define_function_args('acs_event__activity_set','event_id,activity_id');
select define_function_args('acs_event__party_map','event_id,party_id');
select define_function_args('acs_event__party_unmap','event_id,party_id');
select define_function_args('acs_event__recurs_p','event_id');
select define_function_args('acs_event__instances_exist_p','recurrence_id');
select define_function_args('acs_event__get_value','parameter_name');
select define_function_args('acs_event__new_instance','event_id,date_offset');
select define_function_args('acs_event__insert_instances','event_id,cutoff_date;null');
select define_function_args('acs_event__shift','event_id;null,start_offset;0,end_offset;0');
select define_function_args('acs_event__shift_all','event_id;null,start_offset;0,end_offset;0');

select define_function_args('acs_activity__new','activity_id;null,name,description;null,html_p;f,status_summary;null,object_type;acs_activity,creation_date;now(),creation_user;null,creation_ip;null,context_id;null');
select define_function_args('acs_activity__delete','activity_id');
select define_function_args('acs_activity__name','activity_id');
select define_function_args('acs_activity__edit','activity_id,name;null,description;null,html_p;null,status_summary;null');
select define_function_args('acs_activity__object_map','activity_id,object_id');
select define_function_args('acs_activity__object_unmap','activity_id,object_id');

select define_function_args('recurrence__new','interval_name,every_nth_interval,days_of_week;null,recur_until;null,custom_func;null');
select define_function_args('recurrence__delete','recurrence_id');
