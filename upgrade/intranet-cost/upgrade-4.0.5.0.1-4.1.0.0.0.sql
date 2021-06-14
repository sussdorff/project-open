-- upgrade-4.0.5.0.1-4.1.0.0.0.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-4.0.5.0.1-4.1.0.0.0.sql','');


CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS $$
DECLARE
        v_count                 INTEGER;
BEGIN
	SELECT count(*) into v_count from user_tab_columns
        WHERE lower(table_name) = 'im_cost_centers' and lower(column_name) = 'tree_sortkey';
        IF v_count > 0 THEN return 1; END IF;

	alter table im_cost_centers add column tree_sortkey varbit;
	alter table im_cost_centers add column max_child_sortkey varbit;
	create index im_cost_centers_treesort_idx on im_cost_centers(tree_sortkey);

	RETURN 0;
END;$$ language 'plpgsql';
select inline_0();
drop function inline_0();


-------------------------------------------------------------
-- This is the sortkey code
--
create or replace function im_cost_centers_insert_tr ()
returns trigger as $$
DECLARE
	v_max_child_sortkey		varbit;
	v_parent_sortkey		varbit;
BEGIN
	IF new.parent_id is null THEN
		new.tree_sortkey := int_to_tree_key(new.cost_center_id);
	ELSE
		SELECT	tree_sortkey, tree_increment_key(max_child_sortkey)
		INTO	v_parent_sortkey, v_max_child_sortkey
		FROM	im_cost_centers
		WHERE	cost_center_id = new.parent_id
		for update;

		update im_cost_centers
		set max_child_sortkey = v_max_child_sortkey
		where cost_center_id = new.parent_id;

		new.tree_sortkey := v_parent_sortkey || v_max_child_sortkey;
	END IF;
	new.max_child_sortkey := null;
	RETURN new;
END;$$ language 'plpgsql';

create or replace function im_cost_centers_update_tr () 
returns trigger as $$
DECLARE
	v_parent_sk		varbit default null;
	v_max_child_sortkey	varbit;
	v_old_parent_length	integer;
BEGIN
	IF new.cost_center_id = old.cost_center_id and ((new.parent_id = old.parent_id) or (new.parent_id is null and old.parent_id is null)) THEN 
		return new; 
	END IF;

	v_old_parent_length := length(new.tree_sortkey) + 1;
	IF new.parent_id is null THEN
		v_parent_sk := int_to_tree_key(new.cost_center_id);
	ELSE
		SELECT	tree_sortkey, tree_increment_key(max_child_sortkey)
		INTO v_parent_sk, v_max_child_sortkey
		FROM im_cost_centers
		WHERE cost_center_id = new.parent_id
		FOR UPDATE;

		UPDATE im_cost_centers
		SET max_child_sortkey = v_max_child_sortkey
		WHERE cost_center_id = new.parent_id;

		v_parent_sk := v_parent_sk || v_max_child_sortkey;
	END IF;

	UPDATE im_cost_centers
	SET tree_sortkey = v_parent_sk || substring(tree_sortkey, v_old_parent_length)
	WHERE tree_sortkey between new.tree_sortkey and tree_right(new.tree_sortkey);

	RETURN new;
END;$$ language 'plpgsql';

-- Make sure the top CC has no parent (there was an error in the data on a demo server).
update im_cost_centers
set parent_id = null
where cost_center_code in (
	select min(cost_center_code)
	from im_cost_centers	     
);




-- Update the old CCs
CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS $$
DECLARE
        v_count                 INTEGER;
	row			RECORD;
	v_parent_tree_sortkey	varbit;
	v_parent_max_child_sortkey	varbit;
BEGIN
--	update im_cost_centers set  tree_sortkey = null, max_child_sortkey = null;
	FOR row IN
		select	*
		from	im_cost_centers
		order by cost_center_code
	LOOP
		RAISE NOTICE 'inline_0: %, %, %', row.cost_center_id, row.cost_center_code, row.parent_id;

		select	tree_sortkey, tree_increment_key(max_child_sortkey)
		into	v_parent_tree_sortkey, v_parent_max_child_sortkey
		from	im_cost_centers
		where	cost_center_id = row.parent_id;

		IF v_parent_tree_sortkey is NULL THEN
			v_parent_tree_sortkey = int_to_tree_key(row.cost_center_id);
			v_parent_max_child_sortkey = int_to_tree_key(1);
		END IF;
		RAISE NOTICE 'inline_0: %, parent_sortkey=%, parent_max_child=%', row.cost_center_id, v_parent_tree_sortkey, v_parent_max_child_sortkey;

		update im_cost_centers set tree_sortkey = v_parent_tree_sortkey || v_parent_max_child_sortkey where cost_center_id = row.cost_center_id;
		update im_cost_centers set max_child_sortkey = int_to_tree_key(0) where cost_center_id = row.cost_center_id and max_child_sortkey is null;
		update im_cost_centers set max_child_sortkey = v_parent_max_child_sortkey where cost_center_id = row.parent_id;
	END LOOP;
	RETURN 0;
END;$$ language 'plpgsql';
select inline_0();
drop function inline_0();
-- select cost_center_id, cost_center_code, parent_id, org_parent_id, tree_sortkey, max_child_sortkey from im_cost_centers order by cost_center_code;


CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS $$
DECLARE
        v_count                 INTEGER;
BEGIN
	SELECT count(*) into v_count from pg_trigger
	WHERE lower(tgname) = 'im_cost_centers_insert_tr';
        IF v_count > 0 THEN return 1; END IF;

	create trigger im_cost_centers_insert_tr
	before insert on im_cost_centers
	for each row execute procedure im_cost_centers_insert_tr();
	
	create trigger im_cost_centers_update_tr after update
	on im_cost_centers for each row
	execute procedure im_cost_centers_update_tr ();

	RETURN 0;
END;$$ language 'plpgsql';
select inline_0();
drop function inline_0();





