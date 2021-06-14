-- upgrade-3.2.4.0.0-3.2.5.0.0.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.2.4.0.0-3.2.5.0.0.sql','');

\i upgrade-3.0.0.0.first.sql


-- Add a "Username" field to the users view page
--
delete from im_view_columns where column_id=1107;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (1107,11,NULL,'Username',
'$username','','',4,
'parameter::get_from_package_key -package_key intranet-core -parameter EnableUsersUsernameP -default 0');


-- Make all Categories "enabled", after introducing an enabled_p
-- sensitive CategoryWidget
update im_categories set enabled_p = 't' where enabled_p is null;



-- Add a new privilege to determine who can edit
-- a projects base data in order to protect start- and enddate
--
select acs_privilege__create_privilege('edit_project_basedata','Edit Project Base Data','Edit Project Base Data');
select acs_privilege__add_child('admin', 'edit_project_basedata');

select im_priv_create('edit_project_basedata','Employees');
select im_priv_create('edit_project_basedata','Customers');
select im_priv_create('edit_project_basedata','Freelancers');
select im_priv_create('edit_project_basedata','Accounting');
select im_priv_create('edit_project_basedata','P/O Admins');
select im_priv_create('edit_project_basedata','Project Managers');
select im_priv_create('edit_project_basedata','Senior Managers');
select im_priv_create('edit_project_basedata','Sales');
select im_priv_create('edit_project_basedata','HR Managers');
select im_priv_create('edit_project_basedata','Freelance Managers');



-- Weaken the project_path_un constraint so that it isnt global
-- anymore, just local (wrt to parent_id)

alter table im_projects
drop constraint im_projects_path_un;

alter table im_projects
add constraint im_projects_path_un UNIQUE (project_nr, company_id, parent_id);

