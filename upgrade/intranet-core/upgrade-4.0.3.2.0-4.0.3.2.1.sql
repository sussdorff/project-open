-- upgrade-4.0.3.2.0-4.0.3.2.1.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.2.0-4.0.3.2.1.sql','');


update im_component_plugins
set package_name = 'intranet-core'
where package_name = 'intranet' and plugin_name like 'Conf Item Members';

update im_menus
set package_name = 'intranet-core'
where package_name = 'intranet';


select  im_component_plugin__del_module('intranet');
select  im_menu__del_module('intranet');


