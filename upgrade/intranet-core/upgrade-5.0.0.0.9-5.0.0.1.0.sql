-- upgrade-5.0.0.0.9-5.0.0.1.0.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.0.0.9-5.0.0.1.0.sql','');



create or replace function inline_0()
returns integer as $body$
DECLARE
	v_count		integer;
BEGIN
	select	count(*) into v_count from user_tab_columns
	where	table_name = 'IM_AUDIT_SEQ';
	IF v_count > 0 THEN return 1; END IF;

	create sequence im_audit_seq;

	return 0;
END;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();





create or replace function inline_0()
returns integer as $body$
DECLARE
	v_count		integer;
BEGIN
	select	count(*) into v_count from user_tab_columns
	where	lower(table_name) = 'im_audits';
	IF v_count > 0 THEN return 1; END IF;

		create table im_audits (
			audit_id		integer
						constraint im_audits_pk
						primary key,
			audit_object_id		integer
						constraint im_audits_object_nn
						not null,
			audit_object_status_id	integer,
			audit_action		text
						constraint im_audits_action_ck
						check (audit_action in ('after_create','before_update','after_update','before_nuke', 'view', 'baseline')),
			audit_user_id		integer
						constraint im_audits_user_nn
						not null,
			audit_date		timestamptz
						constraint im_audits_date_nn
						not null,
			audit_ip		varchar(50)
						constraint im_audits_ip_nn
						not null,
			audit_last_id		integer
						constraint im_audits_last_fk
						references im_audits,
			audit_ref_object_id	integer,
			audit_value		text
						constraint im_audits_value_nn
						not null,
			audit_diff		text,
			audit_note		text,
			audit_hash		text
		);

		-- Add a link for every object to the ID of the last audit entry
		alter table acs_objects add column last_audit_id integer;

		-- Add a foreign key constraint on last_audit_id:
		alter table acs_objects 
		add constraint acs_objects_last_audit_id_fkey 
		foreign key (last_audit_id) references im_audits;

		-- Create an index for fast access of the changes of an object
		create index im_audits_audit_object_id_idx on im_audits(audit_object_id);

		-- Create an index for fast access of the audit date
		create index im_audits_audit_date_idx on im_audits(audit_date);

		comment on table im_audits is 'Generic audit table. A new row is created everytime that the value of the object is updated.';
		comment on column im_audits.audit_id is 'ID of the audit log (not an OpenACS object_id).';
		comment on column im_audits.audit_object_id is 'Object to be audited. ';
		comment on column im_audits.audit_action is 'Type of action - one of create, update, delete, nuke or pre_update.';
		comment on column im_audits.audit_user_id is 'Who has performed the change?';
		comment on column im_audits.audit_date is 'When was the change performed?';
		comment on column im_audits.audit_ip is 'IP address of the connection initiating the change.';
		comment on column im_audits.audit_last_id is 'Pointer to the last last audit of the object or NULL before the first update. 
		Used to quickly find the old values for calculating a diff.';
		comment on column im_audits.audit_ref_object_id is 'Optional reference to an object who initiated the change.';
		comment on column im_audits.audit_value is 'List of the object fields after the update.';
		comment on column im_audits.audit_diff is 'Difference between the audit_value of the audit_value of the audit_last_id and the new audit_value.';
		comment on column im_audits.audit_note is 'Additional note by the user. Optional.';
		comment on column im_audits.audit_hash is '
		 Crypto hash to ensure the integrity of the audit log.
		 The hash value includes the hash of the audit_last_id,
		 so that any modification in the audit log can be 
		 identified.
		 In the case of a complete recalculation of all hashs,
		 the PostgreSQL OIDs will witness these changes.
		';

	return 0;
END;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();


-----------------------------------------------------------
-- Function for accessing the values in an audit_value string
--

-- Extract the value of a specific field from an audit_value
create or replace function im_audit_value (text, text)
returns text as $body$
DECLARE
	p_audit_value	alias for $1;
	p_var_name	alias for $2;

	v_expr		text;
	v_result	text;
BEGIN
	v_expr := p_var_name || '\\t([^\\n]*)';
	select	substring(p_audit_value from v_expr) into v_result from dual;
	IF '' = v_result THEN v_result := null; END IF;

	return v_result;
end; $body$ language 'plpgsql';


-- Extract the value of a specific field from an object at a specific date
create or replace function im_audit_value (integer, text, timestamptz)
returns text as $body$
DECLARE
	p_object_id	alias for $1;
	p_var_name	alias for $2;
	p_audit_date	alias for $3;

	v_audit_value	text;
	v_expr		text;
	v_result	text;
BEGIN
	select	a.audit_value into v_audit_value
	from	im_audits a
	where	a.audit_id = (
			select	max(aa.audit_id)
			from	im_audits aa
			where	aa.audit_object_id = p_object_id and
				aa.audit_date <= p_audit_date
		);

	v_expr := p_var_name || '\\t([^\\n]*)';
	select	substring(v_audit_value from v_expr) into v_result from dual;
	IF '' = v_result THEN v_result := null; END IF;

	return v_result;
end; $body$ language 'plpgsql';

