SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-4.1.0.0.2-4.1.0.0.3.sql','');

create or replace function inline_0 ()
returns integer as $$
begin

    update im_categories set visible_tcl='[expr { [im_user_is_workscouncil_p [ad_conn user_id]] || [im_user_is_md_coo_p [ad_conn user_id]] }]' where category_id in (15200,15210,15220,15300,15310,15320);

    return 0;
end;
$$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


