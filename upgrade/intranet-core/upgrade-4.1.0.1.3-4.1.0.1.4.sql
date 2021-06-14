-- upgrade-4.1.0.1.3-4.1.0.1.4.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.0.1.3-4.1.0.1.4.sql','');


CREATE OR REPLACE FUNCTION im_sendmail(text, text, text, text)
RETURNS integer AS $BODY$
DECLARE
	p_to			alias for $1;
	p_from			alias for $2;
	p_subject		alias for $3;
	p_body			alias for $4;
	v_message_id		integer;
BEGIN
	v_message_id := nextval('acs_mail_lite_id_seq');
	INSERT INTO acs_mail_lite_queue (
		message_id, to_addr, from_addr, subject, body
	) values (
		v_message_id, p_to, p_from, p_subject, p_body
	);
	return v_message_id;
end;$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION im_sendmail(text, text, text)
RETURNS integer AS $BODY$
DECLARE
	p_to			alias for $1;
	p_subject		alias for $2;
	p_body			alias for $3;
	v_from			varchar;
BEGIN
	SELECT attr_value INTO v_from FROM apm_parameters ap, apm_parameter_values apv 
	WHERE ap.parameter_id = apv.parameter_id and ap.package_key = 'acs-kernel' and ap.parameter_name = 'SystemOwner';

	RETURN im_sendmail(p_to, v_from, p_subject, p_body);
end;$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION im_sendmail(text, text)
RETURNS integer AS $BODY$
DECLARE
	p_subject		alias for $1;
	p_body			alias for $2;
	v_to			varchar;
BEGIN
	SELECT attr_value INTO v_to FROM apm_parameters ap, apm_parameter_values apv 
	WHERE ap.parameter_id = apv.parameter_id and ap.package_key = 'intrant-core' and ap.package_key = 'SecurityBreachEmail';
	IF v_to is NULL THEN v_to := 'support@project-open.com'; END IF;

	RETURN im_sendmail(v_to, p_subject, p_body);
end;$BODY$
LANGUAGE plpgsql;


-- Debugging: Test im_sendmail with a long string.
-- ToDo: Disable before production use
CREATE OR REPLACE FUNCTION inline_0()
RETURNS integer AS $BODY$
DECLARE
	row		RECORD;
        v_text		varchar;
BEGIN
	v_text := '';
	FOR row IN
		select	apv.package_key || ' ' || apv.version_name as pack
		from	apm_package_versions apv,
			apm_packages ap
		where	apv.installed_p = 't' and
			apv.package_key = ap.package_key
	LOOP
		v_text := v_text || row.pack || E'\n';
	END LOOP;

	PERFORM im_sendmail('intranet-core.upgrade-4.1.0.1.3-4.1.0.1.4.sql', v_text);
        return 0;
end;$BODY$ LANGUAGE plpgsql;
select inline_0();
drop function inline_0();

