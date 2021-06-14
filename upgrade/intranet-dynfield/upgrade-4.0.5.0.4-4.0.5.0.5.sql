-- upgrade-4.0.5.0.4-4.0.5.0.5.sql
SELECT acs_log__debug('/packages/intranet-dynfield/sql/postgresql/upgrade/upgrade-4.0.5.0.4-4.0.5.0.5.sql','');


create or replace function inline_0 () 
returns integer as $body$
DECLARE
	v_count		    integer;
	row		    RECORD;
BEGIN
	-- Create a new DynField "page" for /intranet/projects/index:
	select count(*) into v_count
	from im_dynfield_layout_pages
	where  page_url = '/intranet/projects/index';
	IF 0 = v_count THEN
		insert into im_dynfield_layout_pages (
			page_url,
			object_type,
			layout_type
		) values (
			'/intranet/projects/index',
			'im_project',
			'table'
		);
	END IF;

	-- Add all DynFields to the page
	FOR row IN 
		select distinct
			dl.*
		from
			im_dynfield_layout_pages dlp,
			im_dynfield_layout dl,
			im_dynfield_attributes da,
			acs_attributes aa
		where
			dlp.page_url = dl.page_url and
			dl.attribute_id = da.attribute_id and
			da.acs_attribute_id = aa.attribute_id and
			dl.page_url = 'default' and
			aa.object_type = 'im_project'
	LOOP
		select	count(*) into v_count
		from	im_dynfield_layout
		where	attribute_id = row.attribute_id and 
			page_url = '/intranet/projects/index';

		IF 0 = v_count THEN 
			insert into im_dynfield_layout (
				attribute_id, page_url,
				pos_x, pos_y, size_x, size_y,
				label_style, div_class, sort_key
			) values (
				row.attribute_id, '/intranet/projects/index',
				row.pos_x, row.pos_y, row.size_x, row.size_y,
				row.label_style, row.div_class, row.sort_key
			);
		END IF;

	END LOOP;

	RETURN 0;
END;
$body$ language 'plpgsql';
select inline_0();
drop function inline_0();
