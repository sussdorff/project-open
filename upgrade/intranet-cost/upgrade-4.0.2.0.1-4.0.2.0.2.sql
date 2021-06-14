-- upgrade-4.0.2.0.1-4.0.2.0.2.sql

SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-4.0.2.0.1-4.0.2.0.2.sql','');


-- Fix a syntax error in the parameters specs of the installation
--
update im_dynfield_widgets
set parameters = '{custom {start_cc_id "" department_only_p 0 include_empty_p 1 translate_p 0}}'
where parameters = '{custom {start_cc_id ""} {department_only_p 0} {include_empty_p 1} {translate_p 0}}';


