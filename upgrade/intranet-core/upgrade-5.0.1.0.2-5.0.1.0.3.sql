-- upgrade-5.0.1.0.2-5.0.1.0.3.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.1.0.2-5.0.1.0.3.sql','');

update im_categories set category_description = 'Allows assignment of opportunities to marketing campaigns. Disable if CRM module is not used.' where category_type = 'Intranet Project Type' and category = 'CRM Campaign';




update im_menus
set url = '/intranet/master-data'
where label = 'master_data';

