-- upgrade-5.0.0.0.0-5.0.0.0.1.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.0.0.0-5.0.0.0.1.sql','');


drop function if exists im_object_permission_p(integer, integer, varchar);

create or replace function im_object_permission_p (integer, integer, varchar)
returns boolean as $body$
DECLARE
	p_object_id	alias for $1;
	p_user_id	alias for $2;
	p_privilege	alias for $3;
BEGIN
	return acs_permission__permission_p(p_object_id, p_user_id, p_privilege);
END;$body$ language 'plpgsql';



update im_menus set sort_order = 2450 where label = 'rules';
update im_menus set sort_order = 2425, name = 'SQL Selectors' where label = 'selectors_admin';
update im_menus set sort_order = 850 where label = 'cvs_integration';

update im_menus set name = 'Privileges' where name = 'User Profiles';
update im_menus set name = 'User Sub-Administration' where name = 'User Matrix';

update im_menus set 
	name = 'Traffic Light Report',
	label = 'traffic_light_report',
	url = '/intranet-simple-survey/reporting/traffic-light-report'
where
	( label = 'project_reports' OR label = 'traffic_light_reports');

