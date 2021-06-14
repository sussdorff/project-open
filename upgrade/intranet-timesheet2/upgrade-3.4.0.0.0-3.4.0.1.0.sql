-- upgrade-3.4.0.0.0-3.4.0.1.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-3.4.0.0.0-3.4.0.1.0.sql','');


-- ------------------------------------------------------
-- 
-- ------------------------------------------------------

create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
        select count(*) into v_count from user_tab_columns
	where table_name = ''IM_USER_ABSENCES'' and column_name = ''ABSENCE_STATUS_ID'';
        if v_count > 0 then return 0; end if;

	alter table im_user_absences
	add absence_status_id integer
	constraint im_user_absences_status_fk
	references im_categories;

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
        select count(*) into v_count from user_tab_columns
	where table_name = ''IM_USER_ABSENCES'' and column_name = ''ABSENCE_NAME'';
        if v_count > 0 then return 0; end if;

	alter table im_user_absences
	add absence_name varchar(1000);

    	update im_user_absences 
	set absence_name = substring(description for 990);

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
        select count(*) into v_count from user_tab_columns
	where table_name = ''IM_USER_ABSENCES'' and column_name = ''DURATION_DAYS'';
        if v_count > 0 then return 0; end if;

	-- Add a duration field to specify how many days the absence will take.
	alter table im_user_absences
	add duration_days numeric(12,1) default 1
	constraint im_user_absences_duration_days_nn not null;

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


-- Add a NOT NULL constraint to im_hours:
update im_hours set hours=0 where hours is null;

-- Never NULL again...
-- Its OK to run this command multiple times...
ALTER TABLE im_hours ALTER COLUMN hours SET NOT NULL;


update im_component_plugins
set title_tcl = 'lang::message::lookup "" intranet-timesheet2.Timesheet "Timesheet"'
where title_tcl = 'lang::message::lookup "" intranet-timesheet.Timesheet "Timesheet"';

-----------------------------------------------------------


create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
	select count(*) into v_count from acs_object_types 
	where object_type = ''im_user_absence'';
        if v_count > 0 then return 0; end if;

	PERFORM acs_object_type__create_type (
		''im_user_absence'',		-- object_type
		''Absence'',			-- pretty_name
		''Absences'',			-- pretty_plural
		''acs_object'',			-- supertype
		''im_user_absences'',		-- table_name
		''absence_id'',			-- id_column
		''intranet-timesheet2'',	-- package_name
		''f'',				-- abstract_p
		null,				-- type_extension_table
		''im_user_absence__name''	-- name_method
	);

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


-----------------------------------------------------------
-- Create, Drop and Name PlPg/SQL functions
--
-- These functions represent creator/destructor
-- functions for the OpenACS object system.


create or replace function im_user_absence__name(integer)
returns varchar as '
DECLARE
	p_absence_id		alias for $1;
	v_name			varchar(2000);
BEGIN
	select	absence_name into v_name
	from	im_user_absences
	where	absence_id = p_absence_id;

	-- compatibility fallback
	IF v_name is null THEN
		select	substring(description for 1900) into v_name
		from	im_user_absences
		where	absence_id = p_absence_id;
	END IF;

	return v_name;
end;' language 'plpgsql';


create or replace function im_user_absence__new (
	integer, varchar, timestamptz,
	integer, varchar, integer,
	varchar, integer, timestamptz, timestamptz,
	integer, integer, varchar, varchar
) returns integer as '
DECLARE
	p_absence_id		alias for $1;		-- absence_id  default null
	p_object_type   	alias for $2;		-- object_type default ''im_user_absence''
	p_creation_date 	alias for $3;		-- creation_date default now()
	p_creation_user 	alias for $4;		-- creation_user default null
	p_creation_ip   	alias for $5;		-- creation_ip default null
	p_context_id		alias for $6;		-- context_id default null

	p_absence_name		alias for $7;		-- absence_name
	p_owner_id		alias for $8;		-- owner_id
	p_start_date		alias for $9;
	p_end_date		alias for $10;

	p_absence_status_id	alias for $11;
	p_absence_type_id	alias for $12;
	p_description		alias for $13;
	p_contact_info		alias for $14;

	v_absence_id	integer;
BEGIN
	v_absence_id := acs_object__new (
		p_absence_id,		-- object_id
		p_object_type,		-- object_type
		p_creation_date,	-- creation_date
		p_creation_user,	-- creation_user
		p_creation_ip,		-- creation_ip
		p_context_id,		-- context_id
		''f''			-- security_inherit_p
	);

	insert into im_user_absences (
		absence_id, absence_name, 
		owner_id, start_date, end_date,
		absence_status_id, absence_type_id,
		description, contact_info
	) values (
		v_absence_id, p_absence_name, 
		p_owner_id, p_start_date, p_end_date,
		p_absence_status_id, p_absence_type_id,
		p_description, p_contact_info
	);

	return v_absence_id;
END;' language 'plpgsql';


create or replace function im_user_absence__delete(integer)
returns integer as '
DECLARE
	p_absence_id	alias for $1;
BEGIN
	-- Delete any data related to the object
	delete from im_user_absences
	where	absence_id = p_absence_id;

	-- Finally delete the object iself
	PERFORM acs_object__delete(p_absence_id);

	return 0;
end;' language 'plpgsql';




-----------------------------------------------------------
-- Type and Status
--
-- Create categories for Absence type and status.
-- Status acutally is not use, so we just define "active"

-- Here are the ranges for the constants as defined in
-- /intranet-core/sql/common/intranet-categories.sql
--
-- Please contact support@project-open.com if you need to
-- reserve a range of constants for a new module.
--
-- 16000-16999  Intranet Absence (1000)
-- 16000-16099	Intranet Absence Status
-- 16100-16999	reserved


SELECT im_category_new (16000, 'Active', 'Intranet Absence Status');
SELECT im_category_new (16002, 'Deleted', 'Intranet Absence Status');
SELECT im_category_new (16004, 'Requested', 'Intranet Absence Status');
SELECT im_category_new (16006, 'Rejected', 'Intranet Absence Status');



-----------------------------------------------------------
-- Create views for shortcut
--

create or replace view im_user_absence_status as
select	category_id as absence_status_id, category as absence_status
from	im_categories
where	category_type = 'Intranet Absence Status'
	and (enabled_p is null or enabled_p = 't');

create or replace view im_user_absence_types as
select	category_id as absence_type_id, category as absence_type
from	im_categories
where	category_type = 'Intranet Absence Type'
	and (enabled_p is null or enabled_p = 't');





-----------------------------------------------------------
-- Workflow Callbacks to reset an absence status etc.
--






-- ------------------------------------------------------
-- Setup status and type columns for im_user_absences
-- ------------------------------------------------------

update acs_object_types set 
	status_column = 'absence_status_id', 
	type_column='absence_type_id', 
	status_type_table='im_user_absences' 
where object_type = 'im_user_absence';





-- ------------------------------------------------------
-- Relax unique constraint
-- ------------------------------------------------------



-- Drop old constraint if there
create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
        select count(*) into v_count 
	from pg_constraint 
	where lower(conname) = ''owner_and_start_date_unique'';
        if v_count = 0 then return 0; end if;

	alter table im_user_absences
	drop constraint owner_and_start_date_unique;

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

alter table im_user_absences 
add constraint owner_and_start_date_unique unique (owner_id,absence_type_id,start_date);



-- ------------------------------------------------------
-- New privilege for those privileged users who can set an 
-- absence status manually (and thus override WF results).
-- ------------------------------------------------------

create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
        select count(*) into v_count
        from acs_privileges where privilege = ''edit_absence_status'';
        if v_count > 0 then return 0; end if;

        PERFORM acs_privilege__create_privilege(''edit_absence_status'',''Edit Absence Status'',''Edit Absence Status'');
        PERFORM acs_privilege__add_child(''admin'', ''edit_absence_status'');

        PERFORM im_priv_create(''edit_absence_status'', ''Accounting'');
        PERFORM im_priv_create(''edit_absence_status'', ''P/O Admins'');
        PERFORM im_priv_create(''edit_absence_status'', ''Project Managers'');
        PERFORM im_priv_create(''edit_absence_status'', ''Senior Managers'');

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




-- ------------------------------------------------------
-- Absence View Definition
-- ------------------------------------------------------

delete from im_view_columns where view_id = 200;

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (20001,200,NULL,'Name',
'"<a href=$absence_view_url>$absence_name_pretty</a>"','','',1,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (20003,200,NULL,'Start',
'"$start_date_pretty"','','',3,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (20004,200,NULL,'End',
'"$end_date_pretty"','','',4,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (20005,200,NULL,'User',
'"<a href=/intranet/users/view?user_id=$owner_id>$owner_name</a>"','','',5,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (20007,200,NULL,'Type',
'"$absence_type"','','',7,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (20009,200,NULL,'Status',
'"$absence_status"','','',9,'');

-- insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
-- extra_select, extra_where, sort_order, visible_for) values (20009,200,NULL,'Description',
-- '"$description_pretty"', '','',9,'');

-- insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
-- extra_select, extra_where, sort_order, visible_for) values (20011,200,NULL,'Contact',
-- '"$contact_info_pretty"','','',11,'');




-- ------------------------------------------------------
-- Set the default WF for each absence type
-- ------------------------------------------------------

update im_categories
set aux_string1 = 'vacation_approval_wf'
where category_id = 5000 and aux_string1 is null;

update im_categories
set aux_string1 = 'personal_approval_wf'
where category_id = 5001 and aux_string1 is null;

update im_categories
set aux_string1 = 'sick_approval_wf'
where category_id = 5002 and aux_string1 is null;

update im_categories
set aux_string1 = 'travel_approval_wf'
where category_id = 5003 and aux_string1 is null;




-- ------------------------------------------------------
-- Workflow graph on Absence View Page
-- ------------------------------------------------------

SELECT  im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',			-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id

	'Absence Workflow',			-- component_name
	'intranet-timesheet2',			-- package_name
	'right',				-- location
	'/intranet-timesheet2/absences/new',	-- page_url
	null,					-- view_name
	10,					-- sort_order
	'im_workflow_graph_component -object_id $absence_id'
);


-- ------------------------------------------------------
-- Journal on Absence View Page
-- ------------------------------------------------------

SELECT  im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',			-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id

	'Absence Journal',			-- component_name
	'intranet-timesheet2',			-- package_name
	'bottom',				-- location
	'/intranet-timesheet2/absences/new',	-- page_url
	null,					-- view_name
	100,					-- sort_order
	'im_workflow_journal_component -object_id $absence_id'
);


-- ------------------------------------------------------
-- Menus
-- ------------------------------------------------------

SELECT im_new_menu(
	'intranet-timesheet2',
	'timesheet2_absences_vacation',
	'New Vacation Absence',
	'/intranet-timesheet2/absences/new?absence_type_id=5000',
	10,
	'timesheet2_absences', 
	null
);
SELECT im_new_menu_perms('timesheet2_absences_vacation', 'Employees');

SELECT im_new_menu(
	'intranet-timesheet2',
	'timesheet2_absences_personal',
	'New Personal Absence',
	'/intranet-timesheet2/absences/new?absence_type_id=5001',
	20,
	'timesheet2_absences', 
	null
);
SELECT im_new_menu_perms('timesheet2_absences_personal', 'Employees');

SELECT im_new_menu(
	'intranet-timesheet2',
	'timesheet2_absences_sick',
	'New Sick Leave',
	'/intranet-timesheet2/absences/new?absence_type_id=5002',
	30,
	'timesheet2_absences', 
	null
);
SELECT im_new_menu_perms('timesheet2_absences_sick', 'Employees');

SELECT im_new_menu(
	'intranet-timesheet2',
	'timesheet2_absences_travel',
	'New Travel Absence',
	'/intranet-timesheet2/absences/new?absence_type_id=5003',
	40,
	'timesheet2_absences', 
	null
);
SELECT im_new_menu_perms('timesheet2_absences_travel', 'Employees');

SELECT im_new_menu(
	'intranet-timesheet2',
	'timesheet2_absences_bankholiday',
	'New Bank Holiday',
	'/intranet-timesheet2/absences/new?absence_type_id=5004',
	50,
	'timesheet2_absences', 
	null
);
SELECT im_new_menu_perms('timesheet2_absences_bankholiday', 'Employees');




-- ------------------------------------------------------
-- Add DynFields
-- ------------------------------------------------------
--
-- select im_dynfield_attribute__new (
-- 	null,				-- widget_id
-- 	'im_dynfield_attribute',	-- object_type
-- 	now(),				-- creation_date
-- 	null,				-- creation_user
-- 	null,				-- creation_ip	
-- 	null,				-- context_id
-- 
-- 	'im_user_absence',		-- attribute_object_type
-- 	'description',			-- attribute name
-- 	0,				-- min_n_values
-- 	1,				-- max_n_values
-- 	null,				-- default_value
-- 	'date',				-- ad_form_datatype
-- 	'#intranet-timesheet2.Description#',	-- pretty name
-- 	'#intranet-timesheet2.Description#',	-- pretty plural
-- 	'textarea_small',		-- widget_name
-- 	'f',				-- deprecated_p
-- 	't'				-- already_existed_p
-- );
-- 
-- update acs_attributes set sort_order = 50
-- where attribute_name = 'description' and object_type = 'im_user_absence';
-- 
-- 
-- Add DynFields
--
-- select im_dynfield_attribute__new (
-- 	null,				-- widget_id
-- 	'im_dynfield_attribute',	-- object_type
-- 	now(),				-- creation_date
-- 	null,				-- creation_user
-- 	null,				-- creation_ip	
-- 	null,				-- context_id
-- 
-- 	'im_user_absence',		-- attribute_object_type
-- 	'contact_info',			-- attribute name
-- 	0,				-- min_n_values
-- 	1,				-- max_n_values
-- 	null,				-- default_value
-- 	'date',				-- ad_form_datatype
-- 	'#intranet-timesheet2.Contact#',	-- pretty name
-- 	'#intranet-timesheet2.Contact#',	-- pretty plural
-- 	'textarea_small',		-- widget_name
-- 	'f',				-- deprecated_p
-- 	't'				-- already_existed_p
-- );
-- 
-- update acs_attributes set sort_order = 60
-- where attribute_name = 'contact_info' and object_type = 'im_user_absence';
