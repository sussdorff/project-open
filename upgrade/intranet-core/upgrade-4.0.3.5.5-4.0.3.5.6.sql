-- upgrade-4.0.3.5.5-4.0.3.5.6.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.5.5-4.0.3.5.6.sql','');


-- Disable the "All time top services" portlet that does not work anymore
create or replace function inline_0() returns varchar as $body$
        DECLARE
                v_portlet_id         integer;
        BEGIN
		select plugin_id into v_portlet_id from im_component_plugins
		where plugin_name = 'Home All-Time Top Services';

                IF v_portlet_id is not null THEN 
			perform im_component_plugin__delete(v_portlet_id);
		END IF;

                return 0;
        END;
$body$ language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();

