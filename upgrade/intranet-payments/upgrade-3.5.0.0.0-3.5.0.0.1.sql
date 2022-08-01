-- upgrade-3.5.0.0.0-3.5.0.0.1.sql

SELECT acs_log__debug('/packages/intranet-payments/sql/postgresql/upgrade/upgrade-3.5.0.0.0-3.5.0.0.1.sql','');

alter table im_payments drop constraint im_payments_provider;
alter table im_payments add constraint im_payments_provider foreign key (provider_id) references acs_objects(object_id) match full;
