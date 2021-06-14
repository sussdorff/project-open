-- upgrade-3.4.0.2.1-3.4.0.3.0.sql

SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-3.4.0.2.1-3.4.0.3.0.sql','');

-- Fix the location of the admin_workflow label
-- for those ]po[ installations where the acs-workflow
-- is already mounted at /acs-workflow/ (instead of
-- (/workflow/ for older installations)
--

create or replace function inline_0 ()
returns integer as '
declare
        v_count         integer;
begin
        select count(*) into v_count from site_nodes where object_id in (select package_id from apm_packages where package_key = ''acs-workflow'');
        IF v_count = 0 THEN RETURN 1; END IF;

        update im_menus set
                url = ''/''
                        || (
                        select name
                        from site_nodes
                        where object_id in (select package_id from apm_packages where package_key = ''acs-workflow''))
                        || ''/admin/''
        where
                label = ''admin_workflow'';
        RETURN 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();
