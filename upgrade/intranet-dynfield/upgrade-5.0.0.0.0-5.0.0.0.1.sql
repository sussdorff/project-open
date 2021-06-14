-- upgrade-5.0.0.0.0-5.0.0.0.1.sql
SELECT acs_log__debug('/packages/intranet-dynfield/sql/postgresql/upgrade/upgrade-5.0.0.0.0-5.0.0.0.1.sql','');


-- Deal with widgets with double outer parentesis.
-- No idea how they every got in there. During 5.0 upgrade?
update im_dynfield_widgets 
set parameters = regexp_replace(parameters, '{({.*})}', E'\\1') 
where parameters ~ E'^\{\{.*\}\}$';
