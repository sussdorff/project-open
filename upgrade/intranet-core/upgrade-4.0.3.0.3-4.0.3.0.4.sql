-- upgrade-4.0.3.0.3-4.0.3.0.4.sql
SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-4.0.3.0.3-4.0.3.0.4.sql','');


-- Fix a very strange XoWiki issue due to 
-- more then one entry in the cr_text table



create or replace function inline_0 ()
returns integer as $body$
declare
	v_count  integer;
begin
	select count(*) into v_count from pg_trigger
	where lower(tgname) = 'cr_text_tr';

	IF v_count > 0 THEN
		alter table cr_text disable trigger cr_text_tr;
	END IF;

	delete from cr_text;
	insert into cr_text (text_data) values (NULL);

	IF v_count > 0 THEN
		alter table cr_text enable trigger cr_text_tr;
	END IF;

	return 0;
end;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();
