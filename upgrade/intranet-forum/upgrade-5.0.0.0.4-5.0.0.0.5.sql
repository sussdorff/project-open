-- upgrade-5.0.0.0.4-5.0.0.0.5.sql
SELECT acs_log__debug('/packages/intranet-forum/sql/postgresql/upgrade/upgrade-5.0.0.0.4-5.0.0.0.5.sql','');


update im_menus set enabled_p = 'f' where label = 'forum';
update im_menus set enabled_p = 'f' where label = 'contacts';
update im_menus set name = 'XoWiki' where label = 'wiki';

