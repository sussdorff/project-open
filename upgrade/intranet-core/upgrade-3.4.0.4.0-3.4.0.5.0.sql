-- upgrade-3.4.0.4.0-3.4.0.5.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.4.0-3.4.0.5.0.sql','');


CREATE OR REPLACE FUNCTION im_category_new (
	integer, varchar, varchar, varchar
) RETURNS integer as '
DECLARE
	p_category_id		alias for $1;
	p_category		alias for $2;
	p_category_type		alias for $3;
	p_description		alias for $4;

	v_count			integer;
BEGIN
	select	count(*) into v_count from im_categories
	where	(category = p_category and category_type = p_category_type) OR
		category_id = p_category_id;
	IF v_count > 0 THEN return 0; END IF;

	insert into im_categories(category_id, category, category_type, category_description)
	values (p_category_id, p_category, p_category_type, p_description);

	RETURN 0;
end;' language 'plpgsql';

CREATE OR REPLACE FUNCTION im_category_new (
	integer, varchar, varchar
) RETURNS integer as '
DECLARE
	p_category_id		alias for $1;
	p_category		alias for $2;
	p_category_type		alias for $3;
BEGIN
	RETURN im_category_new(p_category_id, p_category, p_category_type, NULL);
end;' language 'plpgsql';


-- Compatibility for Malte
-- ToDo: Remove
CREATE OR REPLACE FUNCTION im_category__new (
        integer, varchar, varchar, varchar
) RETURNS integer as '
DECLARE
        p_category_id           alias for $1;
        p_category              alias for $2;
        p_category_type         alias for $3;
        p_description           alias for $4;
BEGIN
        RETURN im_category_new(p_category_id, p_category, p_category_type, p_description);
end;' language 'plpgsql';


CREATE OR REPLACE FUNCTION im_category_hierarchy_new (
	integer, integer
) RETURNS integer as '
DECLARE
	p_child_id		alias for $1;
	p_parent_id		alias for $2;

	row			RECORD;
	v_count			integer;
BEGIN
	IF p_child_id is null THEN 
		RAISE NOTICE ''im_category_hierarchy_new: bad category 1: "%" '',p_child_id;
		return 0;
	END IF;

	IF p_parent_id is null THEN 
		RAISE NOTICE ''im_category_hierarchy_new: bad category 2: "%" '',p_parent_id; 
		return 0;
	END IF;
	IF p_child_id = p_parent_id THEN return 0; END IF;

	select	count(*) into v_count from im_category_hierarchy
	where	child_id = p_child_id and parent_id = p_parent_id;
	IF v_count = 0 THEN
		insert into im_category_hierarchy(child_id, parent_id)
		values (p_child_id, p_parent_id);
	END IF;

	-- Loop through the parents of the parent
	FOR row IN
		select	parent_id
		from	im_category_hierarchy
		where	child_id = p_parent_id
	LOOP
		PERFORM im_category_hierarchy_new (p_child_id, row.parent_id);
	END LOOP;

	RETURN 0;
end;' language 'plpgsql';


CREATE OR REPLACE FUNCTION im_category_hierarchy_new (
	varchar, varchar, varchar
) RETURNS integer as '
DECLARE
	p_child			alias for $1;
	p_parent		alias for $2;
	p_cat_type		alias for $3;

	v_child_id		integer;
	v_parent_id		integer;
BEGIN
	select	category_id into v_child_id from im_categories
	where	category = p_child and category_type = p_cat_type;
	IF v_child_id is null THEN 
		RAISE NOTICE ''im_category_hierarchy_new: bad category 1: "%" '',p_child; 
		return 0;
	END IF;

	select	category_id into v_parent_id from im_categories
	where	category = p_parent and category_type = p_cat_type;
	IF v_parent_id is null THEN 
		RAISE NOTICE ''im_category_hierarchy_new: bad category 2: "%" '',p_parent; 
		return 0;
	END IF;

	return im_category_hierarchy_new (v_child_id, v_parent_id);

	RETURN 0;
end;' language 'plpgsql';





-- 22000-22999 Intranet User Type
SELECT im_category_new(22000, 'Registered Users', 'Intranet User Type');
SELECT im_category_new(22010, 'The Public', 'Intranet User Type');
SELECT im_category_new(22020, 'P/O Admins', 'Intranet User Type');
SELECT im_category_new(22030, 'Customers', 'Intranet User Type');
SELECT im_category_new(22040, 'Employees', 'Intranet User Type');
SELECT im_category_new(22050, 'Freelancers', 'Intranet User Type');
SELECT im_category_new(22060, 'Project Managers', 'Intranet User Type');
SELECT im_category_new(22070, 'Senior Managers', 'Intranet User Type');
SELECT im_category_new(22080, 'Accounting', 'Intranet User Type');
SELECT im_category_new(22090, 'Sales', 'Intranet User Type');
SELECT im_category_new(22100, 'HR Managers', 'Intranet User Type');
SELECT im_category_new(22110, 'Freelance Managers', 'Intranet User Type');

create or replace view im_user_type as
select
	category_id as user_type_id,
	category as user_type
from 	im_categories
where	category_type = 'Intranet User Type'
	and (enabled_p is null OR enabled_p = 't');


create or replace view im_user_status as
select
	category_id as user_status_id,
	category as user_status
from 	im_categories
where	category_type = 'Intranet User Status'
	and (enabled_p is null OR enabled_p = 't');



-- ToDo: Fill the im_dynfield_type_attribute_map
-- with entries so that Employees by default show all fields

-- Update the category sequence in case there have been manual entries
SELECT pg_catalog.setval('im_categories_seq', (select 1+max(category_id) from im_categories), true);


-- Map remaining "Intranet User Type" categories to groups

create or replace function inline_0 ()
returns integer as '
declare
        row             RECORD;
        v_category_id   integer;
begin
	-- Add a new category for User Types that havent been defined yet
        FOR row IN
                select  g.*
                from    groups g,
                        im_profiles p
                where   p.profile_id = g.group_id
        LOOP
                PERFORM im_category_new(nextval(''im_categories_seq'')::integer, row.group_name, ''Intranet User Type'');
                update im_categories set 
			aux_int1 = row.group_id 
		where category = row.group_name and category_type = ''Intranet User Type'';
        END LOOP;

        RETURN 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();





-- Changes from Malte to make ]po[ run with OpenACS 5.4 and Contacts

-- Fix the syntax error in acs_rel_type__drop_type
--
create or replace function acs_rel_type__drop_type (varchar,boolean)
returns integer as '
declare
  drop_type__rel_type               alias for $1;  
  drop_type__cascade_p              alias for $2;  -- default ''f''  
  v_cascade_p                       boolean;
begin
    -- XXX do cascade_p.
    -- JCD: cascade_p seems to be ignored in acs_o_type__drop_type anyway...

    if drop_type__cascade_p is null then 
	v_cascade_p := ''f'';
    else 
	v_cascade_p := drop_type__cascade_p;
    end if;

    delete from acs_rel_types
	  where rel_type = drop_type__rel_type;

    PERFORM acs_object_type__drop_type(drop_type__rel_type, 
                                       v_cascade_p);

    return 0; 
end;' language 'plpgsql';



---------------------------------------------------
-- Insert offices to parties and biz_objects
--

insert into parties (party_id)
select	office_id 
from	im_offices
where	office_id not in (select party_id from parties);

insert into im_biz_objects (object_id)
select	office_id
from	im_offices
where	office_id not in (select object_id from im_biz_objects);


---------------------------------------------------
-- Insert companies to parties and biz_objects
--
insert into parties (party_id)
select	company_id
from	im_companies
where	company_id not in (select party_id from parties);

insert into im_biz_objects (object_id)
select	company_id
from	im_companies
where	company_id not in (select object_id from im_biz_objects);











-------------------------------------------------------------------
-- !!!
-------------------------------------------------------------------


-- We need to fill acs_object_type_tables with the correct values
-- As the automated class generation cannot deal with this




CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer as '
DECLARE
	v_count			integer;
BEGIN
	select	count(*) into v_count from acs_object_type_tables
	where	object_type = ''person'' and table_name = ''users_contact'';
	IF v_count > 0 THEN return 0; END IF;

	insert into acs_object_type_tables values (''person'',''users_contact'',''user_id'');

	RETURN 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();


-- users_contact has "user_id" as index column
update acs_object_type_tables set
	id_column = 'user_id'
where	object_type = 'person' and
	table_name = 'users_contact';


-- im_employees has "employee_id" as index column
update acs_object_type_tables set
	id_column = 'employee_id'
where	object_type = 'person' and
	table_name = 'im_employees';




CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer as '
DECLARE
	v_count			integer;
BEGIN
	select	count(*) into v_count from acs_object_type_tables
	where	object_type = ''person'' and table_name = ''parties'';
	IF v_count > 0 THEN return 0; END IF;

	insert into acs_object_type_tables values (''person'',''parties'',''party_id'');

	RETURN 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();


-- Fix bad entry
update acs_attributes set table_name = 'persons' where object_type = 'person' and table_name is null;



CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer as '
DECLARE
	v_count			integer;
BEGIN
	select	count(*) into v_count from acs_object_type_tables
	where	object_type = ''person'' and table_name = ''im_employees'';
	IF v_count > 0 THEN return 0; END IF;

	insert into acs_object_type_tables values (''person'',''im_employees'',''employee_id'');

	RETURN 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();



insert into im_employees (employee_id)
select person_id
from persons
where person_id not in (select employee_id from im_employees);





create or replace function im_office__new (
	integer, varchar, timestamptz, integer, varchar, integer,
	varchar, varchar, integer, integer, integer
) returns integer as '
declare
        p_office_id     alias for $1;
        p_object_type     alias for $2;
        p_creation_date   alias for $3;
        p_creation_user   alias for $4;
        p_creation_ip     alias for $5;
        p_context_id      alias for $6;

	p_office_name	alias for $7;
	p_office_path	alias for $8;
	p_office_type_id  alias for $9;
	p_office_status_id alias for $10;
	p_company_id	alias for $11;

        v_object_id     integer;
begin
	v_object_id := acs_object__new (
		p_office_id,
		p_object_type,
		p_creation_date,
		p_creation_user,
		p_creation_ip,
		p_context_id
	);
	insert into im_offices (
		office_id, office_name, office_path, 
		office_type_id, office_status_id, company_id
	) values (
		v_object_id, p_office_name, p_office_path, 
		p_office_type_id, p_office_status_id, p_company_id
	);

	-- make a party - required by contacts
	insert into parties (party_id) values (v_object_id);
	insert into im_biz_objects (object_id) values (v_object_id);

	return v_object_id;
end;' language 'plpgsql';


create or replace function im_company__new (
	integer, varchar, timestamptz, integer, varchar, integer,
	varchar, varchar, integer, integer, integer
) returns integer as '
DECLARE
	p_company_id      alias for $1;
	p_object_type     alias for $2;
	p_creation_date   alias for $3;
	p_creation_user   alias for $4;
	p_creation_ip     alias for $5;
	p_context_id      alias for $6;

	p_company_name	      alias for $7;
	p_company_path	      alias for $8;
	p_main_office_id      alias for $9;
	p_company_type_id     alias for $10;
	p_company_status_id   alias for $11;

	v_company_id	      integer;
BEGIN
	v_company_id := acs_object__new (
		p_company_id,
		p_object_type,
		p_creation_date,
		p_creation_user,
		p_creation_ip,
		p_context_id
	);

	insert into im_companies (
		company_id, company_name, company_path, 
		company_type_id, company_status_id, main_office_id
	) values (
		v_company_id, p_company_name, p_company_path, 
		p_company_type_id, p_company_status_id, p_main_office_id
	);

	-- Make a party - required for contacts
	insert into parties (party_id) values (v_company_id);
	insert into im_biz_objects (object_id) values (v_company_id);

	-- Set the link back from the office to the company
	update	im_offices
	set	company_id = v_company_id
	where	office_id = p_main_office_id;

	return v_company_id;
end;' language 'plpgsql';




create or replace function im_company__delete (integer) returns integer as '
DECLARE
	v_company_id	     alias for $1;
BEGIN
	-- make sure to remove links from all offices to this company.
	update im_offices
	set company_id = null
	where company_id = v_company_id;

	-- Erase the im_companies item associated with the id
	delete from im_companies
	where company_id = v_company_id;

	-- Delete entry from parties
	delete from parties where party_id = v_office_id;

	-- Erase all the priviledges
	delete from 	acs_permissions
	where		object_id = v_company_id;

	PERFORM acs_object__delete(v_company_id);

	return 0;
end;' language 'plpgsql';




-- Delete a single office (if we know its ID...)
create or replace function im_office__delete (integer) returns integer as '
DECLARE
	v_office_id		alias for $1;
BEGIN
	-- Erase the im_offices item associated with the id
	delete from im_offices
	where office_id = v_office_id;

	-- Delete entry from parties
	delete from parties where party_id = v_office_id;

	-- Erase all the priviledges
	delete from 	acs_permissions
	where		object_id = v_office_id;

	PERFORM	acs_object__delete(v_office_id);

	return 0;
end;' language 'plpgsql';




-- Make sure users_contact has a valid foreign key with
-- persons.

CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer as '
DECLARE
	v_count			integer;
BEGIN
	select	count(*) into v_count
	from	pg_constraint 
	where	conname = ''users_contact_user_id_fk'';
	IF v_count > 0 THEN return 0; END IF;

	-- delete "ruins" from delete users?
	delete from users_contact
	where user_id not in (select person_id from persons);

	alter table users_contact 
	add constraint users_contact_user_id_fk foreign key (user_id) references persons(person_id);

	RETURN 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();




CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer as '
DECLARE
	v_count			integer;
BEGIN
	select	count(*) into v_count from user_tab_columns
	where	lower(table_name) = ''im_companies'' and lower(column_name) = ''default_quote_template_id'';
	IF v_count > 0 THEN return 0; END IF;

	alter table im_companies
	add default_quote_template_id integer;

	alter table im_companies
	add constraint im_companies_default_quote_fk foreign key (default_quote_template_id) references im_categories;

	RETURN 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();



-- Disable the "active or potential" category, if not already disabled...
update im_categories
set enabled_p = 'f'
where category_id = 40;



-------------------------------------------------------------------
-- Create relationships between BizObject and Persons
-------------------------------------------------------------------


-------------------------------------------------------------------
-- "Employee of a Company" relationship
-- It doesn't matter if it's the "internal" company, a customer
-- company or a provider company.
-- Instances of this relationship are created whenever ...??? ToDo
-- Usually included DynFields:
--	- Position
--
-- ]po[ HR information is actually attached to a specific subtype
-- of this rel "internal employee"
-- In ]po[ we will create a "im_company_employee_rel" IF:
--	- The user is an "Employee" and its the "internal" company.
--	- The user is a "Customer" and the company is a "customer".
--	- The user is a "Freelancer" and the company is a "provider".

CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer as '
DECLARE
	v_count			integer;
BEGIN
	select	count(*) into v_count from acs_rel_roles where role = ''employee'';
	IF v_count = 0 THEN 
		PERFORM acs_rel_type__create_role(''employee'', ''#acs-translations.role_employee#'', ''#acs-translations.role_employee_plural#'');
	END IF;

	select	count(*) into v_count from acs_rel_roles where role = ''employer'';
	IF v_count = 0 THEN 
		PERFORM acs_rel_type__create_role(''employer'', ''#acs-translations.role_employer#'', ''#acs-translations.role_employer_plural#'');
	END IF;

	RETURN 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();



CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer as '
DECLARE
	v_count			integer;
BEGIN
	select count(*) into v_count from acs_object_types where object_type = ''im_company_employee_rel'';
	IF v_count > 0 THEN return 0; END IF;

	PERFORM acs_object_type__create_type(
		''im_company_employee_rel'',
		''#intranet-contacts.company_employee_rel#'',
		''#intranet-contacts.company_employee_rels#'',
		''im_biz_object_member'',
		''im_company_employee_rels'',
		''company_employee_rel_id'',
		''intranet-contacts.comp_emp'', 
		''f'',
		null,
		NULL
	);

	create table im_company_employee_rels (
		employee_rel_id		integer
					REFERENCES acs_rels
					ON DELETE CASCADE
		CONSTRAINT im_company_employee_rel_id_pk PRIMARY KEY
	);

	insert into acs_rel_types (
		rel_type, object_type_one, role_one,
		min_n_rels_one, max_n_rels_one,
		object_type_two, role_two,min_n_rels_two, max_n_rels_two
	) values (
		''im_company_employee_rel'', ''im_company'', ''employer'', 
		''1'', NULL,
		''party'', ''employee'', ''1'', NULL
	);

	RETURN 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();




-- Insert our own employees into that relationship
insert into im_company_employee_rels
select 
	r.rel_id 
from
	acs_rels r,
	im_biz_object_members bom
where
	r.rel_id = bom.rel_id and
	r.object_id_two in (
		select member_id 
		from group_approved_member_map 
		where group_id = (select group_id from groups where group_name = 'Employees')
	) and 
	r.object_id_one in (select company_id from im_companies where company_path = 'internal') and
	r.rel_id not in (select employee_rel_id from im_company_employee_rels)
;

-- Insert any employee of any other commpany into that relationship
insert into im_company_employee_rels
select 
	r.rel_id 
from
	acs_rels r,
	im_biz_object_members bom
where
	r.rel_id = bom.rel_id and
	r.object_id_two in (
		select member_id 
		from group_approved_member_map 
		where group_id not in (select group_id from groups where group_name = 'Employees')
	) and 
	r.object_id_one in (select company_id from im_companies where company_path != 'internal') and
	r.rel_id not in (select employee_rel_id from im_company_employee_rels)
;


-- Update the type of the relationship
update acs_rels set rel_type = 'im_company_employee_rel' where rel_id in (select employee_rel_id from im_company_employee_rels);




-------------------------------------------------------------------
-- "Key Account Manager" relationship
--
-- A "key account" is a member of group "Employees" who is entitled
-- to manage a customer or provider company.
--
-- Typical extension field for this relationship:
--	- Contract Value (to be signed by this key account)
--
-- Instances of this rel are created by ]po[ if and only if we
-- create a im_biz_object_membership rel with type "Key Account".


CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer as '
DECLARE
	v_count			integer;
BEGIN
	select	count(*) into v_count from acs_rel_roles where role = ''key_account'';
	IF v_count = 0 THEN 
		PERFORM acs_rel_type__create_role(''key_account'', ''#acs-translations.role_key_account#'', ''#acs-translations.role_key_account_plural#'');
	END IF;

	select	count(*) into v_count from acs_rel_roles where role = ''company'';
	IF v_count = 0 THEN 
		PERFORM acs_rel_type__create_role(''company'', ''#acs-translations.role_company#'', ''#acs-translations.role_company_plural#'');
	END IF;

	RETURN 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();




CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer as '
DECLARE
	v_count			integer;
BEGIN
	select count(*) into v_count from acs_object_types where object_type = ''im_key_account_rel'';
	IF v_count > 0 THEN return 0; END IF;

	PERFORM acs_object_type__create_type(
		''im_key_account_rel'',
		''#intranet-contacts.key_account_rel#'',
		''#intranet-contacts.key_account_rels#'',
		''im_biz_object_member'',
		''im_key_account_rels'',
		''key_account_rel_id'',
		''intranet-contacts.key_account'', 
		''f'',
		null,
		NULL
	);
	
	create table im_key_account_rels (
		key_account_rel_id	integer
					REFERENCES acs_rels
					ON DELETE CASCADE
		CONSTRAINT im_key_account_rel_id_pk PRIMARY KEY
	);
	
	
	insert into acs_rel_types (
		rel_type, object_type_one, role_one,
		min_n_rels_one, max_n_rels_one,
		object_type_two, role_two,min_n_rels_two, max_n_rels_two
	) values (
		''im_key_account_rel'', ''im_company'', ''company'',
		''1'', NULL,
		''party'', ''key_account'', ''1'', NULL
	);
	

	RETURN 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0();


	
-- Insert our employees that manage customers or providers
insert into im_key_account_rels
select
	r.rel_id 
from
	acs_rels r,
	im_biz_object_members bom
where
	r.rel_id = bom.rel_id and
	r.object_id_two in (
		select member_id 
		from group_approved_member_map 
		where group_id in (select group_id from groups where group_name = 'Employees')
	) and 
	r.object_id_one in (select company_id from im_companies where company_path != 'internal') and
	r.rel_id not in (select key_account_rel_id from im_key_account_rels)
;


update acs_rels set rel_type = 'im_key_account_rel' where rel_id in (select key_account_rel_id from im_key_account_rels);






-- Fix "deparment" error in DynField naming
update acs_attributes set
	pretty_name = '#intranet-hr.Department#',
	pretty_plural = '#intranet-hr.Department#'
where
	pretty_name = '#intranet-cost.Deparment';
