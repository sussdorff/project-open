-- upgrade-3.2.9.0.0-3.3.0.0.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.2.9.0.0-3.3.0.0.0.sql','');

\i upgrade-3.0.0.0.first.sql



create or replace function im_integer_from_id(integer)
returns varchar as '
DECLARE
	v_result	alias for $1;
BEGIN
	return v_result::varchar;
END;' language 'plpgsql';


create or replace function im_integer_from_id(varchar)
returns varchar as '
DECLARE
	v_result	alias for $1;
BEGIN
	return v_result;
END;' language 'plpgsql';


create or replace function im_integer_from_id(numeric)
returns varchar as '
DECLARE
	v_result	alias for $1;
BEGIN
	return v_result::varchar;
END;' language 'plpgsql';



-------------------------------------------------------------
-- Audit for im_projects
--
-- The table and audit trigger definition will in future be
-- defined by the intranet-dynfield module to take care of
-- dynamic extensions of data types


create or replace function inline_0 ()
returns integer as '
DECLARE
	v_count		integer;
BEGIN
	select count(*) into v_count from user_tab_columns
	where   lower(table_name) = ''im_projects_audit'';
	IF v_count > 0 THEN return 0; END IF;
	
	create table im_projects_audit (
		modifying_action		varchar(20),
		last_modified			timestamptz,
		last_modifying_user		integer,
		last_modifying_ip		varchar(20),
	
		project_id			integer,
		project_name			varchar(1000),
		project_nr			varchar(100),
		project_path			varchar(100),
		parent_id			integer,
		company_id			integer,
		project_type_id			integer,
		project_status_id		integer,
		description			varchar(4000),
		billing_type_id			integer,
		note				varchar(4000),
		project_lead_id			integer,
		supervisor_id			integer,
		project_budget			float,
		corporate_sponsor		integer,
		percent_completed		float,
		on_track_status_id		integer,
		project_budget_currency		character(3),
		project_budget_hours		float,
		end_date			timestamptz,
		start_date			timestamptz,
		company_contact_id		integer,
		company_project_nr		varchar(50)
	);
	
	create index im_projects_audit_project_id_idx on im_projects_audit(project_id);

	return 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();




create or replace function inline_0 ()
returns integer as '
DECLARE
	v_count		integer;
BEGIN
	select count(*) into v_count from user_tab_columns
	where   lower(table_name) = ''im_categories'' and lower(column_name) = ''sort_order'';
	IF v_count > 0 THEN return 0; END IF;

	alter table im_categories add sort_order integer;
	alter table im_categories alter column sort_order set default 0;
	update im_categories set sort_order = category_id;

	return 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();




-- ------------------------------------------------------------------
-- Special dereferencing function for green-yellow-red traffic light
-- ------------------------------------------------------------------


-- Return a suitable GIF for traffic light status display
create or replace function im_traffic_light_from_id(integer)
returns varchar as '
DECLARE
	p_status_id	alias for $1;

	v_category	varchar;
	v_gif		varchar;
BEGIN
	select	c.category, c.aux_string1
	into	v_category, v_gif
	from	im_categories c
	where	category_id = p_status_id;

	-- Take the GIF specified in the category
	IF v_gif is null OR v_gif = '''' THEN 
		-- No GIF specified - take the default one...
		v_gif := ''/intranet/images/navbar_default/bb_''||lower(v_category)|| ''.gif'';
	END IF;

	return ''<img src="'' || v_gif || ''" border=0 title="" alt="">'';
END;' language 'plpgsql';


-- ------------------------------------------------------------------
-- Increase ns_cache Memoize cache size
-- ------------------------------------------------------------------

update apm_parameter_values set
	attr_value = '5000000'
where parameter_id in (
	select	parameter_id
	from	apm_parameters
	where	package_key = 'acs-kernel'
		and parameter_name = 'MaxSize'
);

