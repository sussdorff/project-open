-- upgrade-3.3.0.0.0-3.3.0.1.0.sql

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-3.3.0.0.0-3.3.0.1.0.sql','');


create or replace function inline_0 ()
returns integer as '
declare
	v_count	integer;
begin
	select count(*) into v_count from user_tab_columns
	where table_name = ''IM_INVOICES'' and column_name = ''DISCOUNT_PERC'';
	IF v_count > 0 THEN return 0; END IF;

	alter table im_invoices add discount_perc numeric(12,2);
	alter table im_invoices add discount_text text;
	alter table im_invoices ALTER discount_perc set default 0;
	update im_invoices set discount_perc = 0 where discount_perc is null;

	alter table im_invoices add surcharge_perc numeric(12,2);
	alter table im_invoices add surcharge_text text;
	alter table im_invoices ALTER surcharge_perc set default 0;
	update im_invoices set surcharge_perc = 0 where surcharge_perc is null;

	alter table im_invoices add deadline_start_date	timestamptz;
	alter table im_invoices add deadline_interval interval;

	return 0;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();


--------------------------------------------------------------
-- Category for canned note
-- alter table im_invoices add canned_note_id integer;

create or replace function inline_0 ()
returns integer as '
declare
	v_count	integer;
begin
	select count(*) into v_count from acs_object_type_tables
	where table_name = ''im_invoices'' and object_type = ''im_invoice'';
	IF v_count > 0 THEN return 0; END IF;

	insert into acs_object_type_tables (object_type,table_name,id_column)
	values (''im_invoice'', ''im_invoices'', ''invoice_id'');

	return 0;
end;' language 'plpgsql';
SELECT inline_0();
DROP FUNCTION inline_0();






create or replace function im_dynfield_attribute__new (
	integer, varchar, timestamptz, integer, varchar, integer,
	varchar, varchar, integer, integer, varchar, 
	varchar, varchar, varchar, varchar, char, char
) returns integer as '
DECLARE
	p_attribute_id		alias for $1;
	p_object_type		alias for $2;
	p_creation_date 	alias for $3;
	p_creation_user 	alias for $4;
	p_creation_ip		alias for $5;
	p_context_id		alias for $6;

	p_attribute_object_type	alias for $7;
	p_attribute_name	alias for $8;
	p_min_n_values		alias for $9;
	p_max_n_values		alias for $10;
	p_default_value		alias for $11;

	p_datatype		alias for $12;
	p_pretty_name		alias for $13;
	p_pretty_plural		alias for $14;
	p_widget_name		alias for $15;
	p_deprecated_p		alias for $16;
	p_already_existed_p	alias for $17;

	v_acs_attribute_id	integer;
	v_attribute_id		integer;
	v_table_name		varchar;
BEGIN
	-- Check for duplicate
	select	da.attribute_id into v_attribute_id
	from	acs_attributes aa, im_dynfield_attributes da 
	where	aa.attribute_id = da.acs_attribute_id and
		aa.attribute_name = p_attribute_name and aa.object_type = p_attribute_object_type;
	if v_attribute_id is not null then return v_attribute_id; end if;

	select table_name into v_table_name
	from acs_object_types where object_type = p_attribute_object_type;

	v_acs_attribute_id := acs_attribute__create_attribute (
		p_attribute_object_type,
		p_attribute_name,
		p_datatype,
		p_pretty_name,
		p_pretty_plural,
		v_table_name,		-- table_name
		null,			-- column_name
		p_default_value,
		p_min_n_values,
		p_max_n_values,
		null,			-- sort order
		''type_specific'',	-- storage
		''f''			-- static_p
	);

	v_attribute_id := acs_object__new (
		p_attribute_id,
		p_object_type,
		p_creation_date,
		p_creation_user,
		p_creation_ip,
		p_context_id
	);

	insert into im_dynfield_attributes (
		attribute_id, acs_attribute_id, widget_name,
		deprecated_p, already_existed_p
	) values (
		v_attribute_id, v_acs_attribute_id, p_widget_name,
		p_deprecated_p, p_already_existed_p
	);

	-- By default show the field for all object types
	insert into im_dynfield_type_attribute_map (attribute_id, object_type_id, display_mode)
	select	ida.attribute_id,
		c.category_id,
		''edit''
	from	im_dynfield_attributes ida,
		acs_attributes aa,
		acs_object_types aot,
		im_categories c
	where	ida.acs_attribute_id = aa.attribute_id and
		aa.object_type = aot.object_type and
		aot.type_category_type = c.category_type and
		aot.object_type = p_attribute_object_type and
		aa.attribute_name = p_attribute_name;

	return v_attribute_id;
end;' language 'plpgsql';






create or replace function im_dynfield_attribute__new (
	integer, varchar, timestamptz, integer, varchar, integer,
	varchar, varchar, integer, integer, varchar, 
	varchar, varchar, varchar, varchar, char, char, char
) returns integer as '
DECLARE
	p_attribute_id		alias for $1;
	p_object_type		alias for $2;
	p_creation_date 	alias for $3;
	p_creation_user 	alias for $4;
	p_creation_ip		alias for $5;
	p_context_id		alias for $6;

	p_attribute_object_type	alias for $7;
	p_attribute_name	alias for $8;
	p_min_n_values		alias for $9;
	p_max_n_values		alias for $10;
	p_default_value		alias for $11;

	p_datatype		alias for $12;
	p_pretty_name		alias for $13;
	p_pretty_plural		alias for $14;
	p_widget_name		alias for $15;
	p_deprecated_p		alias for $16;
	p_already_existed_p	alias for $17;

	p_table_name		alias for $18;

	v_acs_attribute_id	integer;
	v_attribute_id		integer;

BEGIN
	-- Check for duplicate
	select	da.attribute_id into v_attribute_id
	from	acs_attributes aa, im_dynfield_attributes da 
	where	aa.attribute_id = da.acs_attribute_id and
		aa.attribute_name = p_attribute_name and aa.object_type = p_attribute_object_type;
	if v_attribute_id is not null then return v_attribute_id; end if;

	v_acs_attribute_id := acs_attribute__create_attribute (
		p_attribute_object_type,
		p_attribute_name,
		p_datatype,
		p_pretty_name,
		p_pretty_plural,
		p_table_name,		-- table_name
		null,			-- column_name
		p_default_value,
		p_min_n_values,
		p_max_n_values,
		null,			-- sort order
		''type_specific'',	-- storage
		''f''			-- static_p
	);

	v_attribute_id := acs_object__new (
		p_attribute_id,
		p_object_type,
		p_creation_date,
		p_creation_user,
		p_creation_ip,
		p_context_id
	);

	insert into im_dynfield_attributes (
		attribute_id, acs_attribute_id, widget_name,
		deprecated_p, already_existed_p
	) values (
		v_attribute_id, v_acs_attribute_id, p_widget_name,
		p_deprecated_p, p_already_existed_p
	);

	-- By default show the field for all object types
	insert into im_dynfield_type_attribute_map (attribute_id, object_type_id, display_mode)
	select	ida.attribute_id,
		c.category_id,
		''edit''
	from	im_dynfield_attributes ida,
		acs_attributes aa,
		acs_object_types aot,
		im_categories c
	where	ida.acs_attribute_id = aa.attribute_id and
		aa.object_type = aot.object_type and
		aot.type_category_type = c.category_type and
		aot.object_type = p_attribute_object_type and
		aa.attribute_name = p_attribute_name;

	return v_attribute_id;
end;' language 'plpgsql';







create or replace function im_insert_acs_object_type_tables (varchar, varchar, varchar)
returns integer as $body$
DECLARE
        p_object_type           alias for $1;
        p_table_name            alias for $2;
        p_id_column             alias for $3;

        v_count                 integer;
BEGIN
        -- Check for duplicates
        select  count(*) into v_count
        from    acs_object_type_tables
        where   object_type = p_object_type and
                table_name = p_table_name;
        IF v_count > 0 THEN return 1; END IF;

        -- Make sure the object_type exists
        select  count(*) into v_count
        from    acs_object_types
        where   object_type = p_object_type;
        IF v_count = 0 THEN return 2; END IF;

        insert into acs_object_type_tables (object_type, table_name, id_column)
        values (p_object_type, p_table_name, p_id_column);

        return 0;
end;$body$ language 'plpgsql';

-- make sure the acs_object_type_table entries exist, before adding the dynfield
SELECT im_insert_acs_object_type_tables('im_invoice','im_costs','cost_id');
SELECT im_insert_acs_object_type_tables('im_invoice','im_invoices','invoice_id');


select im_dynfield_attribute__new (
	null,				-- widget_id
	'im_dynfield_attribute',	-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id

	'im_invoice',			-- attribute_object_type
	'canned_note_id',		-- attribute name
	0,
	0,
	null,
	'integer',
	'#intranet-invoices.Canned_Note#',	-- pretty name
	'#intranet-invoices.Canned_Note#',	-- pretty plural
	'integer',			-- Widget (dummy)
	'f',
	'f'
);



-- 11600-11699	Intranet Invoice Canned Notes

create or replace view im_invoice_canned_notes as
select
	category_id as canned_note_id,
	category as canned_note_category,
	aux_string1 as canned_note
from im_categories
where category_type = 'Intranet Invoice Canned Notes';


SELECT im_category_new(11600, 'Dummy Canned Note', 'Intranet Invoice Canned Note');
update im_categories set aux_string1 = 'Message text for Dummy Canned Note' where category_id = 11600;

