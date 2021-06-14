SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.1.0.0.8-4.1.0.0.9.sql','');

-- -------------------------------------------------------
-- Don't make Reduction in Working hours a holiday
-- -------------------------------------------------------

delete from im_category_hierarchy where child_id = 5007;

-- Enable weekends again
update im_categories set enabled_p = 't', aux_string2='CCCCCC' where category_id = 5009;
    