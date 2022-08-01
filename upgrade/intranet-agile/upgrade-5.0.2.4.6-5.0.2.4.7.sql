-- upgrade-5.0.2.4.6-5.0.2.4.7.sql

SELECT acs_log__debug('/packages/intranet-wiki/sql/postgresql/upgrade/upgrade-5.0.2.4.6-5.0.2.4.7.sql','');


-- There should be no parameters without pacakge.
-- I have no idea how these might have got here...
delete from apm_parameter_values where package_id is null;


-- Reset the PackagePath parameter that determines
-- from where the XoWiki instance should inherit
-- pages
update	apm_parameter_values 
set	attr_value = null
where	parameter_id in (select parameter_id from apm_parameters where package_key = 'xowiki' and parameter_name = 'PackagePath');


-- Somebody fu..up the presence parameter...
update	apm_parameter_values 
set	attr_value = 'presence -interval "10 minutes"'
where	parameter_id in (select parameter_id from apm_parameters where package_key = 'xowiki' and parameter_name = 'top_includelet');

