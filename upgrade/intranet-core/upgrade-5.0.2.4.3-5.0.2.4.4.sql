-- upgrade-5.0.2.4.3-5.0.2.4.4.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-5.0.2.4.3-5.0.2.4.4.sql','');


-- insert into country_codes (iso, country_name) values ('la', 'Sri Lanka');

update country_codes 
set country_name = 'Taiwan (ROC)' 
where country_name = 'Taiwan';


update im_offices 
set address_country_code = lower(address_country_code) 
where address_country_code in ('KP', 'KR', 'MK');


delete from country_codes where iso in ('KP');
delete from country_codes where iso in ('KR');
delete from country_codes where iso in ('MK');

