-- upgrade-4.0.2.0.3-4.0.2.0.4.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.2.0.3-4.0.2.0.4.sql','');

CREATE OR REPLACE FUNCTION im_category_find_next_free_id_in_sequence(INTEGER, INTEGER)
  RETURNS INTEGER AS '
declare
        p_start_seq_id          alias for $1;
        p_stop_seq_id        	alias for $2;
	v_count			integer;
	v_category_id		integer;
begin

	-- how many in sequence
	select count(*) into v_count from im_categories where category_id > p_start_seq_id and category_id <= p_stop_seq_id; 

	-- none used, return seq_start 
        IF 0 = v_count THEN return p_start_seq_id; END IF;

	-- none available in sequence, return 0 
	IF v_count = (p_stop_seq_id-p_start_seq_id +1) THEN return 0; END IF; 
	
	-- there should be at least one free id in sequence, find it: 
	FOR i IN p_start_seq_id .. p_stop_seq_id LOOP
		select count(*) into v_category_id from im_categories where category_id = i; 
		IF v_category_id = 0 THEN return i; END IF; 
	END LOOP; 
 
end;' LANGUAGE 'plpgsql' VOLATILE;
