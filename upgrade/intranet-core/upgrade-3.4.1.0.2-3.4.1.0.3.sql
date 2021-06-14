-- upgrade-3.4.1.0.2-3.4.1.0.3.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.1.0.2-3.4.1.0.3.sql','');

update im_menus set url = '/intranet/projects/index?project_status_id=81&view_name=project_list'
where url = '/intranet/projects/index?project_status_id=81';

update im_menus set url = '/intranet/projects/index?project_status_id=76&view_name=project_list'
where url = '/intranet/projects/index?project_status_id=76';

update im_menus set url = '/intranet/projects/index?project_status_id=71&view_name=project_list'
where url = '/intranet/projects/index?project_status_id=71';
