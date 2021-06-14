-- /packages/intranet-timesheet2/sql/postgresql/intranet-leave_entitlements-create.sql
--
-- Copyright (C) 1999-2004 various parties
-- The code is based on ArsDigita ACS 3.4
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
-- @author      unknown@arsdigita.com
-- @author      malte.sussdorff@cognovis.de

-- upgrade-4.0.5.0.0-4.0.5.0.1.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.0.5.0.0-4.0.5.0.1.sql','');

-----------------------------------------------------------
-- Create the object type

SELECT acs_object_type__create_type (
	'im_user_leave_entitlement',		-- object_type
	'Leave Entitlement',			-- pretty_name
	'Leave Entitlements',			-- pretty_plural
	'acs_object',			-- supertype
	'im_user_leave_entitlements',		-- table_name
	'leave_entitlement_id',			-- id_column
	'intranet-leave-entitlement',		-- package_name
	'f',				-- abstract_p
	null,				-- type_extension_table
	'im_user_leave_entitlement__name'		-- name_method
);

insert into acs_object_type_tables (object_type,table_name,id_column)
values ('im_user_leave_entitlement', 'im_user_leave_entitlements', 'leave_entitlement_id');


-- Setup status and type columns for im_user_leave_entitlements
update acs_object_types set 
	status_type_table = 'im_user_leave_entitlements',
	status_column = 'leave_entitlement_status_id', 
	type_column = 'leave_entitlement_type_id' 
where object_type = 'im_user_leave_entitlement';

-- Define how to link to Leave_Entitlement pages from the Forum or the
-- Search Engine
insert into im_biz_object_urls (object_type, url_type, url) values (
'im_user_leave_entitlement','view','/intranet-timesheet2/leave_entitlements/new?form_mode=display&leave_entitlement_id=');
insert into im_biz_object_urls (object_type, url_type, url) values (
'im_user_leave_entitlement','edit','/intranet-timesheet2/leave_entitlements/new?leave_entitlement_id=');


------------------------------------------------------
-- Leave_Entitlements Table
--
create table im_user_leave_entitlements (
        leave_entitlement_id              integer
                                constraint im_user_leave_entitlements_pk
                                primary key
				constraint im_user_leave_entitlements_id_fk
				references acs_objects,
	leave_entitlement_name		varchar(1000),
        owner_id                integer
                                constraint im_user_leave_entitlements_user_fk
                                references users,
        booking_date            timestamptz
                                constraint im_user_leave_entitlements_booking_nn not null,
	entitlement_days	numeric(12,1) 
				constraint im_user_leave_entitlements_entitlement_days_nn not null,
        description             text,
        leave_entitlement_type_id		integer
                                constraint im_user_leave_entitlements_type_fk
                                references im_categories
                                constraint im_user_leave_entitlements_type_nn
				not null,
        leave_entitlement_status_id	integer
                                constraint im_user_leave_entitlements_status_fk
                                references im_categories
                                constraint im_user_leave_entitlements_type_nn 
				not null
);

-- Incices to speed up frequent queries
create index im_user_leave_entitlements_user_id_idx on im_user_leave_entitlements(owner_id);
create index im_user_leave_entitlements_type_idx on im_user_leave_entitlements(leave_entitlement_type_id);

-----------------------------------------------------------
-- Create, Drop and Name PlPg/SQL functions
--
-- These functions represent creator/destructor
-- functions for the OpenACS object system.

create or replace function im_user_leave_entitlement__name(integer)
returns varchar as '
DECLARE
	p_leave_entitlement_id		alias for $1;
	v_name			varchar;
BEGIN
	select	leave_entitlement_name into v_name
	from	im_user_leave_entitlements
	where	leave_entitlement_id = p_leave_entitlement_id;

	-- compatibility fallback
	IF v_name is null THEN
		select	substring(description for 1900) into v_name
		from	im_user_leave_entitlements
		where	leave_entitlement_id = p_leave_entitlement_id;
	END IF;

	return v_name;
end;' language 'plpgsql';


create or replace function im_user_leave_entitlement__new (
	integer, varchar, timestamptz,
	integer, varchar, integer,
	varchar, integer, timestamptz, float,
	integer, integer, varchar
) returns integer as '
DECLARE
	p_leave_entitlement_id		alias for $1;		-- leave_entitlement_id  default null
	p_object_type   	alias for $2;		-- object_type default ''im_user_leave_entitlement''
	p_creation_date 	alias for $3;		-- creation_date default now()
	p_creation_user 	alias for $4;		-- creation_user default null
	p_creation_ip   	alias for $5;		-- creation_ip default null
	p_context_id		alias for $6;		-- context_id default null

	p_leave_entitlement_name		alias for $7;		-- leave_entitlement_name
	p_owner_id		alias for $8;		-- owner_id
	p_booking_date		alias for $9;
	p_entitlement_days	alias for $10;

	p_leave_entitlement_status_id	alias for $11;
	p_leave_entitlement_type_id	alias for $12;
	p_description		alias for $13;

	v_leave_entitlement_id	integer;
BEGIN
	v_leave_entitlement_id := acs_object__new (
		p_leave_entitlement_id,		-- object_id
		p_object_type,		-- object_type
		p_creation_date,	-- creation_date
		p_creation_user,	-- creation_user
		p_creation_ip,		-- creation_ip
		p_context_id,		-- context_id
		''f''			-- security_inherit_p
	);

	insert into im_user_leave_entitlements (
		leave_entitlement_id, leave_entitlement_name, 
		owner_id, booking_date, entitlement_days,
		leave_entitlement_status_id, leave_entitlement_type_id,
		description
	) values (
		v_leave_entitlement_id, p_leave_entitlement_name, 
		p_owner_id, p_booking_date, p_entitlement_days,
		p_leave_entitlement_status_id, p_leave_entitlement_type_id,
		p_description
	);

	return v_leave_entitlement_id;
END;' language 'plpgsql';


create or replace function im_user_leave_entitlement__delete(integer)
returns integer as '
DECLARE
	p_leave_entitlement_id	alias for $1;
BEGIN
	-- Delete any data related to the object
	delete from im_user_leave_entitlements
	where	leave_entitlement_id = p_leave_entitlement_id;

	-- Finally delete the object iself
	PERFORM acs_object__delete(p_leave_entitlement_id);

	return 0;
end;' language 'plpgsql';




------------------------------------------------------
-- Leave_Entitlements Permissions
--

-- add_leave_entitlements makes it possible to restrict the leave_entitlement registering to internal stuff
SELECT acs_privilege__create_privilege('add_leave_entitlements','Add Leave Entitlements','Add Leave Entitlements');
SELECT acs_privilege__add_child('admin', 'add_leave_entitlements');

-- view_leave_entitlements_all restricts possibility to see leave_entitlements of others
SELECT acs_privilege__create_privilege('view_leave_entitlements_all','View Leave Entitlements All','View Leave Entitlements All');
SELECT acs_privilege__add_child('admin', 'view_leave_entitlements_all');

-- Set default permissions per group
SELECT im_priv_create('add_leave_entitlements', 'HR Managers');
SELECT im_priv_create('view_leave_entitlements_all', 'HR Managers');
SELECT im_priv_create('view_leave_entitlements_all', 'Senior Managers');

SELECT  im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',			-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id

	'Leave Entitlements',			-- component_name
	'intranet-timesheet2',			-- package_name
	'bottom',				-- location
	'/intranet/users/view',			-- page_url
	null,					-- view_name
	100,					-- sort_order
	'im_leave_entitlement_user_component -user_id $user_id'
);

SELECT  im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',			-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id

	'Absence Balance',			-- component_name
	'intranet-timesheet2',			-- package_name
	'bottom',				-- location
	'/intranet/users/view',			-- page_url
	null,					-- view_name
	101,					-- sort_order
	'im_leave_entitlement_absence_balance_component -user_id $user_id'
);


-- ------------------------------------------------------
-- Leave Entitlement View Definition
-- ------------------------------------------------------


delete from im_view_columns where view_id = 201;
delete from im_views where view_id = 201;

insert into im_views (view_id, view_name, visible_for, view_type_id) values 
       (201, 'leave_entitlement_list', '', 1400);


insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (20101,201,NULL,'Name',
'"<a href=$leave_entitlement_view_url>$leave_entitlement_name_pretty</a>"','','',1,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (20103,201,NULL,'Booking Date',
'"$booking_date_pretty"','','',3,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (20104,201,NULL,'Entitlement Days',
'"$entitlement_days"','','',4,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (20105,201,NULL,'User',
'"<a href=/intranet/users/view?user_id=$owner_id>$owner_name</a>"','','',5,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (20107,201,NULL,'Type',
'"$leave_entitlement_type"','','',7,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (20109,201,NULL,'Status',
'"$leave_entitlement_status"','','',9,'');

