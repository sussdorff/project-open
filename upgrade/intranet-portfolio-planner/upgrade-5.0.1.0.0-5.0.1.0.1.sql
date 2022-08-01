-- upgrade-5.0.1.0.0-5.0.1.0.1.sql
SELECT acs_log__debug('/packages/intranet-portfolio-planner/sql/postgresql/upgrade/upgrade-5.0.1.0.0-5.0.1.0.1.sql','');

update im_menus set
       parent_menu_id = (select menu_id from im_menus where label = 'portfolio')
where label = 'portfolio_planner';

