-- upgrade-upgrade-5.0.2.3.4-5.0.2.3.5.sql
SELECT acs_log__debug('/packages/intranet-dynfield/sql/postgresql/upgrade/upgrade-5.0.2.3.4-5.0.2.3.5.sql','');

select im_menu__delete(
       (select menu_id from im_menus where label = 'dynfield_otype_events')
);

select im_menu__delete(
       (select menu_id from im_menus where label = 'dynfield_otype_freelance_rfqs')
);

select im_menu__delete(
       (select menu_id from im_menus where label = 'dynfield_otype_freelance_rfq_answers')
);

