-- upgrade-3.4.1.0.0-3.4.1.0.1.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.1.0.0-3.4.1.0.1.sql','');




CREATE or REPLACE FUNCTION im_project_level_spaces(integer)
RETURNS varchar as $body$
DECLARE
	p_level		alias for $1;
	v_result	varchar;
	i		integer;
BEGIN
	v_result := '';
	FOR i IN 1..p_level LOOP
		v_result := v_result || '    ';
	END LOOP;
	RETURN v_result;
END; $body$ LANGUAGE 'plpgsql';





create or replace function im_project__new (
	integer, varchar, timestamptz, integer, varchar, integer,
	varchar, varchar, varchar, integer, integer, integer, integer
) returns integer as '
DECLARE
	p_project_id		alias for $1;
	p_object_type		alias for $2;
	p_creation_date 	alias for $3;
	p_creation_user		alias for $4;
	p_creation_ip		alias for $5;
	p_context_id		alias for $6;

	p_project_name		alias for $7;
	p_project_nr		alias for $8;
	p_project_path		alias for $9;
	p_parent_id		alias for $10;
	p_company_id		alias for $11;
	p_project_type_id	alias for $12;
	p_project_status_id	alias for $13;

	v_project_id		integer;
BEGIN
	v_project_id := acs_object__new (
		p_project_id,
		p_object_type,
		p_creation_date,
		p_creation_user,
		p_creation_ip,
		p_context_id
	);

	insert into im_biz_objects (object_id) values (v_project_id);

	insert into im_projects (
		project_id, project_name, project_nr, 
		project_path, parent_id, company_id, project_type_id, 
		project_status_id 
	) values (
		v_project_id, p_project_name, p_project_nr, 
		p_project_path, p_parent_id, p_company_id, p_project_type_id, 
		p_project_status_id
	);
	return v_project_id;
end;' language 'plpgsql';

insert into im_biz_objects (object_id)
select	project_id
from	im_projects
where	project_id not in (
		select	object_id
		from	im_biz_objects
	)
;





-----------------------------------------------------------
-- Widgets
--

SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'offices', 'Offices', 'Offices',
	10007, 'integer', 'generic_sql', 'integer',
	'{custom {sql {
		select	
			p.office_id,
			p.office_name
		from 
			im_offices p
		where 
			p.office_status_id not in (161)
		order by 
			lower(office_name) 
	}}}'
);


-----------------------------------------------------------
-- Hard coded fields
--



-- Shortcut function
CREATE OR REPLACE FUNCTION im_dynfield_attribute_new (
	varchar, varchar, varchar, varchar, varchar, char(1), integer, char(1), varchar
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
	p_table_name	 	alias for $9;

	v_dynfield_id		integer;
	v_widget_id		integer;
	v_type_category		varchar;
	row			RECORD;
	v_count			integer;
	v_min_n_value		integer;
BEGIN
	select	widget_id into v_widget_id from im_dynfield_widgets
	where	widget_name = p_widget_name;
	IF v_widget_id is null THEN return 1; END IF;

	select	count(*) from im_dynfield_attributes into v_count
	where	acs_attribute_id in (
			select	attribute_id 
			from	acs_attributes 
			where	attribute_name = p_column_name and
				object_type = p_object_type
		);
	IF v_count > 0 THEN return 1; END IF;

	v_min_n_value := 0;
	IF p_required_p = ''t'' THEN  v_min_n_value := 1; END IF;

	v_dynfield_id := im_dynfield_attribute__new (
		null, ''im_dynfield_attribute'', now(), 0, ''0.0.0.0'', null,
		p_object_type, p_column_name, v_min_n_value, 1, null,
		p_datatype, p_pretty_name, p_pretty_name, p_widget_name,
		''f'', ''f'', p_table_name
	);

	update im_dynfield_attributes set also_hard_coded_p = p_also_hard_coded_p
	where attribute_id = v_dynfield_id;

	insert into im_dynfield_layout (
		attribute_id, page_url, pos_y, label_style
	) values (
		v_dynfield_id, ''default'', p_pos_y, ''plain''
	);

	-- set all im_dynfield_type_attribute_map to "edit"
	select type_category_type into v_type_category from acs_object_types
	where object_type = p_object_type;
	FOR row IN
		select	category_id
		from	im_categories
		where	category_type = v_type_category
	LOOP
		select	count(*) into v_count from im_dynfield_type_attribute_map
		where	object_type_id = row.category_id and attribute_id = v_dynfield_id;
		IF 0 = v_count THEN
			insert into im_dynfield_type_attribute_map (
				attribute_id, object_type_id, display_mode
			) values (
				v_dynfield_id, row.category_id, ''edit''
			);
		END IF;
	END LOOP;

	PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name=''Employees''), ''read'');
	PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name=''Employees''), ''write'');
	PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name=''Customers''), ''read'');
	PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name=''Customers''), ''write'');
	PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name=''Freelancers''), ''read'');
	PERFORM acs_permission__grant_permission(v_dynfield_id, (select group_id from groups where group_name=''Freelancers''), ''write'');

	RETURN v_dynfield_id;
END;' language 'plpgsql';

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

	RETURN im_dynfield_attribute_new($1,$2,$3,$4,$5,$6,null,''f'',v_table_name);
END;' language 'plpgsql';

-- Shortcut function
CREATE OR REPLACE FUNCTION im_dynfield_attribute_new (
	varchar, varchar, varchar, varchar, varchar, char(1)
) RETURNS integer as '
BEGIN
	RETURN im_dynfield_attribute_new($1,$2,$3,$4,$5,$6,null,''f'');
END;' language 'plpgsql';




SELECT im_dynfield_attribute_new (
	'im_company', 'company_name', 'Name', 'textbox_medium', 'string', 'f', 0, 't', 'im_companies'
);
SELECT im_dynfield_attribute_new (
	'im_company', 'company_path', 'Path', 'textbox_medium', 'string', 'f', 10, 't', 'im_companies'
);
SELECT im_dynfield_attribute_new (
	'im_company', 'main_office_id', 'Main Office', 'offices', 'integer', 'f', 20, 't', 'im_companies'
);
SELECT im_dynfield_attribute_new (
	'im_company', 'company_status_id', 'Status', 'category_company_status', 
	'integer', 'f', 30, 't', 'im_companies'
);
SELECT im_dynfield_attribute_new (
	'im_company', 'company_type_id', 'Type', 'category_company_type', 
	'integer', 'f', 40, 't', 'im_companies'
);


-----------------------------------------------------------
-- Hard coded fields
--

SELECT im_dynfield_attribute_new ('im_company', 'primary_contact_id', 'Primary Contact', 'customer_contact', 'integer', 'f', 100, 'f', 'im_companies');
SELECT im_dynfield_attribute_new ('im_company', 'accounting_contact_id', 'Accounting Contact', 'customer_contact', 'integer', 'f', 100, 'f', 'im_companies');


-- note                        | character varying(4000) |
-- referral_source             | character varying(1000) |
-- annual_revenue_id           | integer                 |
-- status_modification_date    | date                    |
-- old_company_status_id       | integer                 |
-- billable_p                  | character(1)            | default 'f'::bpchar
-- site_concept                | character varying(100)  |
-- manager_id                  | integer                 |
-- contract_value              | integer                 |
-- start_date                  | date                    |
-- vat_number                  | character varying(100)  |
-- default_vat                 | numeric(12,1)           | default 0
-- default_invoice_template_id | integer                 |
-- default_payment_method_id   | integer                 |
-- default_payment_days        | integer                 |
-- default_bill_template_id    | integer                 |
-- default_po_template_id      | integer                 |
-- default_delnote_template_id | integer                 |
-- invoice_template_id         | integer                 |
-- payment_method_id           | integer                 |
-- payment_days                | integer                 |
-- default_quote_template_id   | integer                 |
-- company_group_id            | integer                 |
-- business_sector_id          | integer                 |
-- default_tax                 | numeric(12,1)           | default 0






create or replace function im_company_employee_rel__new (
	integer, varchar, integer, integer, integer, integer, varchar, integer
) returns integer as '
DECLARE
	p_rel_id		alias for $1;	-- null
	p_rel_type		alias for $2;	-- im_company_employee_rel
	p_object_id_one		alias for $3;
	p_object_id_two		alias for $4;
	p_context_id		alias for $5;
	p_creation_user		alias for $6;	-- null
	p_creation_ip		alias for $7;	-- null

	v_rel_id	integer;
BEGIN
	v_rel_id := acs_rel__new (
		p_rel_id,
		p_rel_type,
		p_object_id_one,
		p_object_id_two,
		p_context_id,
		p_creation_user,
		p_creation_ip
	);

	insert into im_company_employee_rels (
	       rel_id, sort_order
	) values (
	       v_rel_id, p_sort_order
	);

	return v_rel_id;
end;' language 'plpgsql';


create or replace function im_company_employee_rel__delete (integer)
returns integer as '
DECLARE
	p_rel_id	alias for $1;
BEGIN
	delete	from im_company_employee_rels
	where	rel_id = p_rel_id;

	PERFORM acs_rel__delete(p_rel_id);
	return 0;
end;' language 'plpgsql';






create or replace function im_key_account_rel__new (
	integer, varchar, integer, integer, integer, integer, varchar, integer
) returns integer as '
DECLARE
	p_rel_id		alias for $1;	-- null
	p_rel_type		alias for $2;	-- im_key_account_rel
	p_object_id_one		alias for $3;
	p_object_id_two		alias for $4;
	p_context_id		alias for $5;
	p_creation_user		alias for $6;	-- null
	p_creation_ip		alias for $7;	-- null

	v_rel_id	integer;
BEGIN
	v_rel_id := acs_rel__new (
		p_rel_id,
		p_rel_type,
		p_object_id_one,
		p_object_id_two,
		p_context_id,
		p_creation_user,
		p_creation_ip
	);

	insert into im_key_account_rels (
	       rel_id, sort_order
	) values (
	       v_rel_id, p_sort_order
	);

	return v_rel_id;
end;' language 'plpgsql';


create or replace function im_key_account_rel__delete (integer)
returns integer as '
DECLARE
	p_rel_id	alias for $1;
BEGIN
	delete	from im_key_account_rels
	where	rel_id = p_rel_id;

	PERFORM acs_rel__delete(p_rel_id);
	return 0;
end;' language 'plpgsql';

