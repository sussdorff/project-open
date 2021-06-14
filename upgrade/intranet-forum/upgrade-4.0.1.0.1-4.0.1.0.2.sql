-- upgrade-4.0.1.0.1-4.0.1.0.2.sql

SELECT acs_log__debug('/packages/intranet-forum/sql/postgresql/upgrade/upgrade-4.0.1.0.1-4.0.1.0.2.sql','');

alter table im_forum_topics disable trigger im_forum_topics_update_tr;
alter table im_forum_topics disable trigger im_forum_topics_calendar_update_tr;

-- Change values of im_forum_topics.message
CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE 
	v_message	text;
	row			record;
BEGIN
	FOR row IN
	    SELECT message, topic_id FROM im_forum_topics where message not like ''%text/html''
        LOOP
            v_message := ''{'' ||  row.message || ''} text/html'';
            UPDATE im_forum_topics SET message = v_message WHERE topic_id = row.topic_id;
        END LOOP;
			       
	RETURN 0;

END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();

alter table im_forum_topics enable trigger im_forum_topics_update_tr;
alter table im_forum_topics enable trigger im_forum_topics_calendar_update_tr;