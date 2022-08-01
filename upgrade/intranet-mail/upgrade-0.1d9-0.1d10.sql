-- /packages/intranet-mail/sql/postgresql/upgrade/upgrade-0.1d9-0.1d10.sql

SELECT acs_log__debug ('/packages/intranet-mail/sql/postgresql/upgrade/upgrade-0.1d9-0.1d10.sql','');

ALTER TABLE acs_mail_log RENAME COLUMN object_id TO context_id;

CREATE OR REPLACE FUNCTION acs_mail_log__new (integer, varchar, integer, integer, varchar, varchar, integer, varchar, integer, varchar, varchar, varchar, varchar)
RETURNS integer AS '
DECLARE	
	p_log_id	alias for $1;
	p_message_id 	alias for $2;
	p_sender_id 	alias for $3;
	p_package_id 	alias for $4;
	p_subject 	alias for $5;
	p_body 		alias for $6;
	p_creation_user alias for $7;
        p_creation_ip 	alias for $8;
        p_context_id 	alias for $9;
	p_cc 		alias for $10;
	p_bcc 		alias for $11;
	p_to_addr 	alias for $12;
	p_from_addr	alias for $13;

BEGIN
	PERFORM acs_object__new (	
		p_log_id,         -- object_id	
		''mail_log'', 	  -- object_type	
		now(),	     	  -- creation_date
		p_creation_user,  -- creation_user
		p_creation_ip,	  -- creation_ip
		p_context_id	  -- context_id	
	);	
	
	insert into acs_mail_log
		(log_id, message_id, context_id, sender_id, package_id, subject, body, cc, bcc, sent_date, to_addr, from_addr)
	values
		(p_log_id, p_message_id, p_context_id, p_sender_id, p_package_id, p_subject, p_body, p_cc, p_bcc, now(), p_to_addr, p_from_addr);

	RETURN 0;

END;' language 'plpgsql';
