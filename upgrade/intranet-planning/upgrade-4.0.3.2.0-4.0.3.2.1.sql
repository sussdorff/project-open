-- upgrade-4.0.3.2.0-4.0.3.2.1.sql

SELECT acs_log__debug('/packages/intranet-planning/sql/postgresql/upgrade/upgrade-4.0.3.2.0-4.0.3.2.1.sql','');

-- Disable the top-level tab until there are some reasonable pages for it...
update im_menus
set enabled_p = 'f'
where label = 'planning';

