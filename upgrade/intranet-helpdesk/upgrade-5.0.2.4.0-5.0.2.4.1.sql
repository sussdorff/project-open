-- upgrade-5.0.2.4.0-5.0.2.4.1.sql

SELECT acs_log__debug('/packages/intranet-helpdesk/sql/postgresql/upgrade/upgrade-5.0.2.4.0-5.0.2.4.1.sql','');


SELECT im_category_new(30008, 'Accepted', 'Intranet Ticket Status');
SELECT im_category_hierarchy_new(30008, 30000);

SELECT im_category_new(30515, 'Set status: Accepted', 'Intranet Ticket Action');
update im_categories set aux_string1 = '/intranet-helpdesk/action-accepted' where category_id = 30515;
