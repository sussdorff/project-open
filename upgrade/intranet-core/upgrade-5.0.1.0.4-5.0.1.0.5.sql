-- upgrade-5.0.1.0.4-5.0.1.0.5.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.1.0.4-5.0.1.0.5.sql','');



-- Extract the value of a specific field from an audit_value
create or replace function im_audit_value (text, text)
returns text as $body$
DECLARE
	p_audit_value	alias for $1;
	p_var_name	alias for $2;

	v_expr		text;
	v_result	text;
BEGIN
	v_expr := p_var_name || '\t([^\n]*)';
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

	v_expr := p_var_name || '\t([^\n]*)';
	select	substring(v_audit_value from v_expr) into v_result from dual;
	IF '' = v_result THEN v_result := null; END IF;

	return v_result;
end; $body$ language 'plpgsql';

