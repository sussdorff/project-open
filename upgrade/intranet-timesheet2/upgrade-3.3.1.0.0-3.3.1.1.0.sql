-- upgrade-3.3.1.0.0-3.3.1.1.0.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-3.3.1.0.0-3.3.1.1.0.sql','');




create or replace function inline_1 ()
returns integer as '
declare
        v_count                 integer;
	v_menu_id		integer;
begin
	select	count(*) into v_count from user_tab_columns
	where	lower(table_name) = ''im_user_absences'' and lower(column_name) = ''absence_status_id'';
	if v_count > 0 then return 0; end if;

	alter table im_user_absences 
	add absence_status_id integer
	constraint im_user_absences_status_fk references im_categories;

	alter table im_user_absences add absence_name varchar(1000);

	update im_user_absences set absence_name = substring(description for 990);

	return 0;
end;' language 'plpgsql';
select inline_1 ();
drop function inline_1();



-----------------------------------------------------------

create or replace function inline_1 ()
returns integer as '
declare
        v_count                 integer;
begin
	select	count(*) into v_count from acs_object_types where object_type = ''im_user_absence'';
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
select inline_1 ();
drop function inline_1();



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

