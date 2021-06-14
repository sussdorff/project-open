-- upgrade-3.4.0.8.1-3.4.0.8.2.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.8.1-3.4.0.8.2.sql','');



-----------------------------------------------------------
-- Store information about the open/closed status of 
-- hierarchical business objects including projects etc.
--

create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = ''im_biz_object_tree_status'';
	IF v_count > 0 THEN return 1; END IF;

	CREATE TABLE im_biz_object_tree_status (
			object_id	integer
					constraint im_biz_object_tree_status_object_nn 
					not null
					constraint im_biz_object_tree_status_object_fk
					references acs_objects on delete cascade,
			user_id		integer
					constraint im_biz_object_tree_status_user_nn 
					not null
					constraint im_biz_object_tree_status_user_fk
					references persons on delete cascade,
			page_url	text
					constraint im_biz_object_tree_status_page_nn 
					not null,
	
			open_p		char(1)
					constraint im_biz_object_tree_status_open_ck
					CHECK (open_p = ''o''::bpchar OR open_p = ''c''::bpchar),
			last_modified	timestamptz,
	
		primary key  (object_id, user_id, page_url)
	);

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


-----------------------------------------------------------

create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = ''im_projects'' and lower(column_name) = ''presales_probability'';
	IF v_count > 0 THEN return 1; END IF;

	alter table im_projects add presales_probability numeric(5,2);
	alter table im_projects add presales_value numeric(12,2);

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


SELECT im_dynfield_attribute_new ('im_project', 'presales_probability', 'Presales Probability', 'integer', 'integer', 'f');
SELECT im_dynfield_attribute_new ('im_project', 'presales_value', 'Presales Value', 'integer', 'integer', 'f');



-- reported_days_cache for controlling per day.
--
create or replace function inline_0 ()
returns integer as '
declare
	v_count		integer;
begin
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = ''im_projects'' and lower(column_name) = ''reported_days_cache'';
	IF v_count > 0 THEN return 1; END IF;

	alter table im_projects add reported_days_cache numeric(12,2) default 0;

	RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

