-- upgrade-4.1.0.1.2-4.1.0.1.3.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.1.0.1.2-4.1.0.1.3.sql','');


update lang_messages set message = 'Add New Project' where locale = 'en_US' and message_key = 'Add_a_new_project' and package_key = 'intranet-core';

