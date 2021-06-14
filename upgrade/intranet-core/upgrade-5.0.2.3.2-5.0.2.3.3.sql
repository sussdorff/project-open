-- upgrade-5.0.2.3.2-5.0.2.3.3.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.2.3.2-5.0.2.3.3.sql','');


-- The parent_id constraint apparently was lost at some moment...
--
-- Remove any offending sub-projects with inconsistent parents.
update im_projects set parent_id = null where parent_id not in (select project_id from im_projects);
--
-- Re-create the constraint
create or replace function inline_0()
returns integer as $body$
DECLARE
	v_count		integer;
BEGIN
	select	count(*) into v_count from pg_constraint
	where	conname in ('im_projects_parent_fk');
	IF v_count > 0 THEN return 1; END IF;

	alter table im_projects add constraint im_projects_parent_fk FOREIGN KEY (parent_id) REFERENCES im_projects(project_id);

	return 0;
END;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();





-- Beautified versions of the triggers
create or replace function im_projects_update_tr () 
returns trigger as $body$
declare
	v_parent_sk		varbit default null;
	v_max_child_sortkey	varbit;
	v_old_parent_length	integer;
begin
	IF new.project_id = old.project_id
	    and ((new.parent_id = old.parent_id)
		or (new.parent_id is null
		    and old.parent_id is null)) THEN
	    return new;
	END IF;

	-- the tree sortkey is going to change so get the new one and update it and all its
	-- children to have the new prefix...
	v_old_parent_length := length(new.tree_sortkey) + 1;

	-- RAISE NOTICE 'im_projects_update_tr: old.parent_id=%, new.parent_id=%, v_old_parent_length=%', 
	--       old.parent_id, new.parent_id, v_old_parent_length;

	IF new.parent_id is null THEN
	    v_parent_sk := int_to_tree_key(new.project_id+1000);
	ELSE
		SELECT	tree_sortkey, tree_increment_key(max_child_sortkey)
		INTO	v_parent_sk, v_max_child_sortkey
		FROM	im_projects
		WHERE	project_id = new.parent_id
		FOR UPDATE;

		UPDATE	im_projects
		SET 	max_child_sortkey = v_max_child_sortkey
		WHERE	project_id = new.parent_id;

		v_parent_sk := v_parent_sk || v_max_child_sortkey;
	END IF;

	UPDATE im_projects
	SET tree_sortkey = v_parent_sk || substring(tree_sortkey, v_old_parent_length)
	WHERE tree_sortkey between new.tree_sortkey and tree_right(new.tree_sortkey);

	return new;
end;$body$ language 'plpgsql';

-- create trigger im_projects_update_tr after update
-- on im_projects
-- for each row
-- execute procedure im_projects_update_tr ();






create or replace function im_project_insert_tr ()
returns trigger as $body$
declare
	v_max_child_sortkey		varbit;
	v_parent_sortkey		varbit;
begin
	IF new.parent_id is null THEN
		new.tree_sortkey := int_to_tree_key(new.project_id+1000);
	ELSE
		select	tree_sortkey, tree_increment_key(max_child_sortkey)
		into	v_parent_sortkey, v_max_child_sortkey
		from	im_projects
		where	project_id = new.parent_id
		for update;

		-- Increment the parent max_child_sortkey
		update	im_projects
		set	max_child_sortkey = v_max_child_sortkey
		where	project_id = new.parent_id;

		new.tree_sortkey := v_parent_sortkey || v_max_child_sortkey;

		-- RAISE NOTICE 'im_projects_insert_tr: new.project_id=%, parent.sortkey=%, max_child_sortkey=%', 
		--      new.project_id, v_parent_sortkey, v_max_child_sortkey;

	END IF;

	new.max_child_sortkey := null;

	return new;
end;$body$ language 'plpgsql';

-- create trigger im_project_insert_tr
-- before insert on im_projects
-- for each row
-- execute procedure im_project_insert_tr();


-- alter table im_projects disable trigger im_projects_calendar_update_tr;
-- alter table im_projects disable trigger im_project_project_cost_center_update_tr;
-- alter table im_projects disable trigger im_projects_project_cache_up_tr;
-- alter table im_projects disable trigger im_projects_tsearch_tr ;

-- Alternative constraint to check inconsistencies with tree_sortkey
--
-- alter table im_projects add constraint im_projects_parent_tree_sortkey_ck CHECK (not ((parent_id is not null) AND (tree_sortkey is null)));


