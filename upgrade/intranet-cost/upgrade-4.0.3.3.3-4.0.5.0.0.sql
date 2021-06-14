-- upgrade-4.0.3.3.3-4.0.5.0.0.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-4.0.3.3.3-4.0.5.0.0.sql','');

CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS $body$
DECLARE
        v_count                 INTEGER;
	v_view_id		INTEGER;
	v_next_column_id	INTEGER;
	v_column_id		INTEGER;
BEGIN
	select view_id into v_view_id from im_views where view_name = 'invoice_list';
	IF v_view_id IS NULL THEN
	   RAISE NOTICE 'View "invoice_list" not found, column Created/$object_creation_date not created';
	   RETURN 0;
        ELSE 
	   select column_id into v_column_id from im_view_columns where column_name = 'Effective Date' and column_render_tcl = '$cost_effective_date' and view_id = v_view_id;  
           IF v_column_id IS NOT NULL THEN
	        RAISE NOTICE 'Column Created/$object_creation_date exists already';
           	RETURN 0;
           ELSE 
	   	SELECT MAX(column_id)+1 INTO v_next_column_id FROM im_view_columns;	   	
           	INSERT INTO im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,extra_select, extra_where, sort_order, visible_for) VALUES (v_next_column_id,v_view_id,NULL,'Effective Date', '$cost_effective_date','','',20,'');
	   END IF; 
        END IF;
        RETURN 0;
END;$body$ LANGUAGE 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();
