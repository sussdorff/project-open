-- upgrade-5.0.2.5.0-5.0.2.5.1.sql
SELECT acs_log__debug('/packages/intranet-baseline/sql/postgresql/upgrade/upgrade-5.0.2.5.0-5.0.2.5.1.sql','');


-- Extract the value of a specific field from an object at a specific date
create or replace function im_audit_value_baseline (integer, text, integer)
returns text as $body$
DECLARE
	p_object_id	alias for $1;
	p_var_name	alias for $2;
	p_baseline_id	alias for $3;

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
				aa.audit_baseline_id = p_baseline_id
		);

	v_expr := p_var_name || '\t([^\n]*)';
	select	substring(v_audit_value from v_expr) into v_result from dual;
	IF '' = v_result THEN v_result := null; END IF;

	return v_result;
end; $body$ language 'plpgsql';

