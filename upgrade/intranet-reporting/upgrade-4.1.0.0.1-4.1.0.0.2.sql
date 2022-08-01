SELECT acs_log__debug('/packages/intranet-reporting/sql/postgresql/upgrade/upgrade-4.1.0.0.1-4.1.0.0.2.sql','');

create or replace function inline_0 ()
returns integer as $$
begin

    perform im_category_new('15200','Daily','Timesheet - Timescale');
    perform im_category_new('15210','Weekly','Timesheet - Timescale');
    perform im_category_new('15220','Monthly','Timesheet - Timescale');


    perform im_category_new('15300','Single','Timesheet - Detail Level');
    perform im_category_new('15310','Subprojects','Timesheet - Detail Level');
    perform im_category_new('15320','Detailed','Timesheet - Detail Level');

    update im_categories set visible_tcl='[im_user_is_md_coo_p [ad_conn user_id]]' where category_id in (15200,15210,15220,15300,15310,15320);

    return 0;
end;
$$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


