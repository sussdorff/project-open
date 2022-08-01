-- upgrade-5.0.2.4.0-5.0.2.5.0.sql
SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-5.0.2.4.0-5.0.2.5.0.sql','');



create or replace function inline_1 () returns integer as $body$
declare
	v_max_invoice_item_id		integer;
	v_max_object_id			integer;
	v_object_id			integer;
	row				record;
begin
	-- We need to make sure we do not have overlapping im_invoice_items.item_id
	-- Therefore we make sure our object sequency is higher than the highest
	select nextval('im_invoice_items_seq') into v_max_invoice_item_id;
	select nextval from acs_object_id_seq into v_max_object_id;
	IF v_max_invoice_item_id > v_max_object_id THEN
		PERFORM setval('acs_object_id_seq', v_max_invoice_item_id+1, true);		 
	END IF;

	-- Now we can replace the item_id of all invoice_items with
	-- newly generated object_ids
	FOR row IN 
		select	item_id
		from	im_invoice_items
		where	item_id not in (
				select	object_id
				from	acs_objects
				where	object_type = 'im_invoice_item'
			)
	LOOP
		v_object_id := acs_object__new(null, 'im_invoice_item');
		update im_invoice_items set item_id = v_object_id where item_id = row.item_id;
	END LOOP;

	return 0;
end;$body$ language 'plpgsql';
select inline_1 ();
drop function inline_1();


-- drop sequence im_invoice_items_seq;



-- Overwrite the invoice destructor that now needs to delete 
-- the invoice items

-- Delete a single invoice (if we know its ID...)
create or replace function im_invoice__delete (integer)
returns integer as $body$
declare
	p_invoice_id		alias for $1;	-- invoice_id
	row	     		record;
begin
	FOR row IN
		select * from im_invoice_items where invoice_id = p_invoice_id
	LOOP
		PERFORM im_invoice_item__delete(row.item_id);
	END LOOP;

	-- Erase the im_invoice_item associated with the id
	-- delete from 	im_invoice_items
	-- where	invoice_id = p_invoice_id;

	-- Delete canned notes values
	delete from 	im_dynfield_attr_multi_value
	where		object_id = p_invoice_id;

	-- Erase the invoice itself
	delete from 	im_invoices
	where		invoice_id = p_invoice_id;

	-- Erase the CostItem
	PERFORM im_cost__delete(p_invoice_id);
	return 0;
end; $body$ language 'plpgsql';





---------------------------------------------------------
-- Categories
--

-- 47000-47099  Intranet Invoice Item Status (100)
-- 47100-47199  Intranet Invoice Item Type (100)

SELECT im_category_new(47000, 'Active', 'Intranet Invoice Item Status');
SELECT im_category_new(47001, 'Deleted', 'Intranet Invoice Item Status');

SELECT im_category_new(47100, 'Default', 'Intranet Invoice Item Type');



---------------------------------------------------------
-- Invoice Items Methods
--

create or replace function im_invoice_item__new (
	integer, varchar, timestamptz, integer, varchar, integer,
	varchar, integer, integer, numeric, integer, numeric, char(3),
	integer, integer
) returns integer as $body$
declare
	p_item_id		alias for $1;		-- invoice_id default null
	p_object_type		alias for $2;		-- object_type default im_invoice
	p_creation_date		alias for $3;		-- creation_date default now()
	p_creation_user		alias for $4;		-- creation_user
	p_creation_ip		alias for $5;		-- creation_ip default null
	p_context_id		alias for $6;		-- context_id default null

	p_item_name		alias for $7;		-- 
	p_invoice_id		alias for $8;		-- 
	p_sort_order		alias for $9;
	p_item_units		alias for $10;		-- 
	p_item_uom_id		alias for $11;		-- 
	p_price_per_unit	alias for $12;		-- 
	p_currency		alias for $13;		-- 
	p_item_type_id		alias for $14;		-- 
	p_item_status_id	alias for $15;		-- 

	v_item_id		integer;
begin
	v_item_id := acs_object__new (
		p_item_id,		-- object_id - NULL to create a new id
		p_object_type,		-- object_type - "im_risk"
		p_creation_date,	-- creation_date - now()
		p_creation_user,	-- creation_user - Current user or "0" for guest
		p_creation_ip,		-- creation_ip - IP from ns_conn, or "0.0.0.0"
		p_context_id,		-- context_id - NULL, not used in ]po[
		't'			-- security_inherit_p - not used in ]po[
	);

	insert into im_invoice_items (
		item_id, item_name, invoice_id, sort_order, 
		item_units, item_uom_id, price_per_unit, currency,
		item_type_id, item_status_id
	) values (
		v_item_id, p_item_name, p_invoice_id, p_sort_order,
		p_item_units, p_item_uom_id, p_price_per_unit, p_currency,
		p_item_type_id, p_item_status_id
	);

	return v_item_id;
end; $body$ language 'plpgsql';

-- Delete a single invoice item, if we know its ID...
create or replace function im_invoice_item__delete (integer)
returns integer as $body$
declare
	p_invoice_item_id alias for $1;
begin
	delete from 	im_invoice_items
	where		item_id = p_invoice_item_id;

	PERFORM acs_object__delete(p_invoice_item_id);
	return 0;
end; $body$ language 'plpgsql';


create or replace function im_invoice_item__name (integer)
returns varchar as $body$
declare
	p_invoice_item_id alias for $1;
	v_name	varchar;
begin
	select	item_name
	into	v_name
	from	im_invoice_items
	where	item_id = p_invoice_item_id;

	return v_name;
end; $body$ language 'plpgsql';

