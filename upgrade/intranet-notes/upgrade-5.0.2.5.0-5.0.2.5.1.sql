-- upgrade-5.0.2.5.0-5.0.2.5.1.sql

SELECT acs_log__debug('/packages/intranet-notes/sql/postgresql/upgrade/upgrade-5.0.2.5.0-5.0.2.5.1.sql','');


update acs_object_types set
        type_category_type = 'Intranet Notes Type'
where object_type = 'im_note';


