-- upgrade-5.0.2.4.1-5.0.2.4.2.sql

SELECT acs_log__debug('/packages/intranet-gantt-editor/sql/postgresql/upgrade/upgrade-5.0.2.4.1-5.0.2.4.2.sql', '');


-- We changed the encoding of preferences, so we need to delete the old ones...
delete from im_sencha_preferences;

