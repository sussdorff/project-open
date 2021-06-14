-- upgrade-5.0.2.4.2-5.0.2.4.3.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.2.4.2-5.0.2.4.3.sql','');


update im_dynfield_widgets
set deref_plpgsql_function = 'im_category_from_id'
where deref_plpgsql_function = 'im_name_from_id' and widget = 'im_category_tree';

update im_dynfield_widgets
set deref_plpgsql_function = 'im_cost_center_name_from_id'
where deref_plpgsql_function = 'im_name_from_id' and widget = 'im_cost_center_tree';


-- absence_vacation_replacements    | integer      | generic_sql         | integer         | im_name_from_id
-- conf_items_locations             | integer      | generic_sql         | integer         | im_name_from_id
-- conf_items_servers               | integer      | generic_sql         | integer         | im_name_from_id
-- customer_companies               | integer      | generic_sql         | integer         | im_name_from_id
-- customer_contact                 | integer      | generic_sql         | integer         | im_name_from_id
-- customer_contact_select_ajax     | integer      | generic_sql         | integer         | im_name_from_id
-- customers_active                 | integer      | generic_sql         | integer         | im_name_from_id
-- gender_select                    | string       | select              | string          | im_name_from_id
-- idea_assignees                   | integer      | generic_sql         | integer         | im_name_from_id
-- idea_po_components               | integer      | generic_sql         | integer         | im_name_from_id
-- materials                        | integer      | generic_sql         | integer         | im_name_from_id
-- offices                          | integer      | generic_sql         | integer         | im_name_from_id
-- open_projects                    | integer      | generic_sql         | integer         | im_name_from_id
-- opportunity_campaign             | integer      | generic_sql         | integer         | im_name_from_id
-- parent_projects                  | integer      | generic_sql         | integer         | im_name_from_id
-- program_projects                 | integer      | generic_sql         | integer         | im_name_from_id
-- project_managers                 | integer      | generic_sql         | integer         | im_name_from_id
-- project_sponsors                 | integer      | generic_sql         | integer         | im_name_from_id
-- service_level_agreements         | integer      | generic_sql         | integer         | im_name_from_id
-- ticket_assignees                 | integer      | generic_sql         | integer         | im_name_from_id
-- ticket_po_components             | integer      | generic_sql         | integer         | im_name_from_id
-- ticket_queues                    | integer      | generic_sql         | integer         | im_name_from_id
