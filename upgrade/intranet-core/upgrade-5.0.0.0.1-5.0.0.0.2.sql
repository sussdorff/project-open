-- upgrade-5.0.0.0.1-5.0.0.0.2.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.0.0.1-5.0.0.0.2.sql','');



-- Add metadata to Office object


SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'category_office_type', 'Office Type', 'Office Type',
	10007, 'integer', 'im_category_tree', 'integer',
	'{custom {category_type "Intranet Office Type"}}'
);

SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'category_office_status', 'Office Status', 'Office Status',
	10007, 'integer', 'im_category_tree', 'integer',
	'{custom {category_type "Intranet Office Status"}}'
);


SELECT im_dynfield_attribute_new ('im_office', 'office_name', 'Name', 'textbox_medium', 'string', 'f', 0, 't', 'im_offices');
SELECT im_dynfield_attribute_new ('im_office', 'office_path', 'Path', 'textbox_medium', 'string', 'f', 10, 't', 'im_offices');
SELECT im_dynfield_attribute_new ('im_office', 'office_status_id', 'Status', 'category_office_status', 'integer', 'f', 30, 't', 'im_offices');
SELECT im_dynfield_attribute_new ('im_office', 'office_type_id', 'Type', 'category_office_type', 'integer', 'f', 40, 't', 'im_offices');

SELECT im_dynfield_attribute_new ('im_office', 'phone', 'Phone', 'textbox_medium', 'string', 'f', 100, 't', 'im_offices');
SELECT im_dynfield_attribute_new ('im_office', 'fax', 'Fax', 'textbox_medium', 'string', 'f', 110, 't', 'im_offices');

SELECT im_dynfield_attribute_new ('im_office', 'address_line1', 'Address 1', 'textbox_large', 'string', 'f', 120, 't', 'im_offices');
SELECT im_dynfield_attribute_new ('im_office', 'address_line2', 'Address 2', 'textbox_large', 'string', 'f', 130, 't', 'im_offices');
SELECT im_dynfield_attribute_new ('im_office', 'address_city', 'City', 'textbox_medium', 'string', 'f', 140, 't', 'im_offices');
SELECT im_dynfield_attribute_new ('im_office', 'address_state', 'State', 'textbox_medium', 'string', 'f', 150, 't', 'im_offices');
SELECT im_dynfield_attribute_new ('im_office', 'address_postal_code', 'ZIP', 'textbox_small', 'string', 'f', 160, 't', 'im_offices');
SELECT im_dynfield_attribute_new ('im_office', 'address_country_code', 'Country', 'country_codes', 'string', 'f', 170, 't', 'im_offices');

SELECT im_dynfield_attribute_new ('im_office', 'note', 'Note', 'textarea_small', 'string', 'f', 200, 't', 'im_offices');


