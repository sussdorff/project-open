-- upgrade-4.0.5.0.1-4.0.5.0.2.sql

SELECT acs_log__debug('/packages/intranet-dynfield/sql/postgresql/upgrade/upgrade-4.0.5.0.1-4.0.5.0.2.sql','');


-- Shortcut function
CREATE OR REPLACE FUNCTION im_dynfield_attribute_new (
	varchar, varchar, varchar, varchar, varchar, char(1), integer, char(1)
) RETURNS integer as '
DECLARE
	p_object_type		alias for $1;
	p_column_name		alias for $2;
	p_pretty_name		alias for $3;
	p_widget_name		alias for $4;
	p_datatype		alias for $5;
	p_required_p		alias for $6;
	p_pos_y			alias for $7;
	p_also_hard_coded_p	alias for $8;

	v_table_name		varchar;
BEGIN
	select table_name into v_table_name
	from acs_object_types where object_type = p_object_type;

	RETURN im_dynfield_attribute_new($1,$2,$3,$4,$5,$6,$7,$8,v_table_name);
END;' language 'plpgsql';

