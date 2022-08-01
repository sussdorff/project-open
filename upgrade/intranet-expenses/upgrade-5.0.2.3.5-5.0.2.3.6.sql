-- 5.0.2.3.5-5.0.2.3.6.sql
SELECT acs_log__debug('/packages/intranet-expenses/sql/postgresql/upgrade/upgrade-5.0.2.3.5-5.0.2.3.6.sql','');


update lang_messages 
set message = 'Billable?' 
where locale = 'en_US' and message_key = 'Billable' and package_key = 'intranet-expenses';

