-- upgrade-3.4.0.8.4-3.4.0.8.5.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.8.4-3.4.0.8.5.sql','');


delete from im_view_columns where column_id = 1108;

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (1108,11,NULL,'Authority',
'$authority_pretty_name','','',5,
'parameter::get_from_package_key -package_key intranet-core -parameter EnableUsersAuthorityP -default 0');

