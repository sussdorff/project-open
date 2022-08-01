-- upgrade-5.0.0.0.2-5.0.0.0.3.sql
SELECT acs_log__debug('/packages/intranet-invoices/sql/postgresql/upgrade/upgrade-5.0.0.0.2-5.0.0.0.3.sql','');


update im_categories set category = 'template.en_US.adp' where category = 'template.en.adp' and category_type = 'Intranet Cost Template';
update im_categories set category = 'template.es_ES.adp' where category = 'template.es.adp' and category_type = 'Intranet Cost Template';


SELECT im_category_new((select nextval('im_categories_seq'))::integer, 'Tigerpond.en_US.odp', 'Intranet Cost Template');

