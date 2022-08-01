-- upgrade-3.2.6.0.0-3.2.7.0.0.sql

SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-3.2.6.0.0-3.2.7.0.0.sql','');


-- -------------------------------------------------------------
-- Add field default_quote_template_id to im_companies
--
-- Add new attributes to im_companies for default templates


create or replace function inline_0 ()
returns integer as '
declare
	v_attrib_name		varchar;
	v_attrib_pretty		varchar;
	v_acs_attrib_id		integer;
	v_attrib_id		integer;
	v_count			integer;
begin
	v_attrib_name := ''default_bill_template_id'';
	v_attrib_pretty := ''Default Provider Bill Template'';

	select count(*)	into v_count from acs_attributes
	where attribute_name = v_attrib_name;
	IF 0 != v_count THEN return 0; END IF;

	v_acs_attrib_id := acs_attribute__create_attribute (
		''im_company'',
		v_attrib_name,
		''integer'',
		v_attrib_pretty,
		v_attrib_pretty,
		''im_companies'',
		NULL, NULL, ''0'', ''1'',
		NULL, NULL, NULL
	);
	alter table im_companies add default_bill_template_id integer;
	v_attrib_id := acs_object__new (
		null,
		''im_dynfield_attribute'',
		now(),
		null, null, null
	);
	insert into im_dynfield_attributes (
		attribute_id, acs_attribute_id, widget_name, deprecated_p
	) values (
		v_attrib_id, v_acs_attrib_id, ''category_invoice_template'', ''f''
	);
    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



create or replace function inline_0 ()
returns integer as '
declare
	v_count		 integer;
begin
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = ''im_companies'' and lower(column_name) = ''default_bill_template_id'';
	IF 0 != v_count THEN return 0; END IF;

	alter table im_companies add default_bill_template_id integer;

	return 1;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();





create or replace function inline_0 ()
returns integer as '
declare
	v_attrib_name		varchar;
	v_attrib_pretty		varchar;
	v_acs_attrib_id		integer;
	v_attrib_id		integer;
	v_count			integer;
begin
	v_attrib_name := ''default_po_template_id'';
	v_attrib_pretty := ''Default PO Template'';

	select count(*)	into v_count from acs_attributes
	where attribute_name = v_attrib_name;
	IF 0 != v_count THEN return 0; END IF;

	v_acs_attrib_id := acs_attribute__create_attribute (
		''im_company'',
		v_attrib_name,
		''integer'',
		v_attrib_pretty,
		v_attrib_pretty,
		''im_companies'',
		NULL, NULL,
		''0'', ''1'',
		NULL, NULL,
		NULL
	);

	alter table im_companies add default_po_template_id integer;

	v_attrib_id := acs_object__new (
		null,
		''im_dynfield_attribute'',
		now(),
		null,
		null, 
		null
	);

	insert into im_dynfield_attributes (
		attribute_id, acs_attribute_id, widget_name, deprecated_p
	) values (
		v_attrib_id, v_acs_attrib_id, ''category_invoice_template'', ''f''
	);

    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




create or replace function inline_0 ()
returns integer as '
declare
	v_count		 integer;
begin
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = ''im_companies'' and lower(column_name) = ''default_po_template_id'';
	IF 0 != v_count THEN return 0; END IF;

	alter table im_companies add default_po_template_id integer;

	return 1;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();








create or replace function inline_0 ()
returns integer as '
declare
	v_attrib_name		varchar;
	v_attrib_pretty		varchar;
	v_acs_attrib_id		integer;
	v_attrib_id		integer;
	v_count			integer;
begin
	v_attrib_name := ''default_delnote_template_id'';
	v_attrib_pretty := ''Default Delivery Note Template'';

	select count(*)	into v_count
	from acs_attributes
	where attribute_name = v_attrib_name;
	IF 0 != v_count THEN return 0; END IF;

	v_acs_attrib_id := acs_attribute__create_attribute (
		''im_company'',
		v_attrib_name,
		''integer'',
		v_attrib_pretty,
		v_attrib_pretty,
		''im_companies'',
		NULL, NULL,
		''0'', ''1'',
		NULL, NULL,
		NULL
	);

	alter table im_companies add default_delnote_template_id integer;

	v_attrib_id := acs_object__new (
		null,
		''im_dynfield_attribute'',
		now(),
		null,
		null, 
		null
	);

	insert into im_dynfield_attributes (
		attribute_id, acs_attribute_id, widget_name, deprecated_p
	) values (
		v_attrib_id, v_acs_attrib_id, ''category_invoice_template'', ''f''
	);

    return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




create or replace function inline_0 ()
returns integer as '
declare
	v_count		 integer;
begin
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = ''im_companies'' and lower(column_name) = ''default_delnote_template_id'';
	IF 0 != v_count THEN return 0; END IF;

	alter table im_companies add default_delnote_template_id integer;

	return 1;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



