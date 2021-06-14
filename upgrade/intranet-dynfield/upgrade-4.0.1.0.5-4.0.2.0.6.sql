-- upgrade-4.0.1.0.5-4.0.2.0.6.sql

SELECT acs_log__debug('/packages/intranet-dynfield/sql/postgresql/upgrade/upgrade-4.0.1.0.5-4.0.2.0.6.sql','');

-- Set the ACS datatype of already existing DynFields
-- to "float" in order to avoid errors with float fractions
update acs_attributes
set datatype = 'float'
where attribute_id in (
	select	aa.attribute_id
	from	acs_attributes aa,
		im_dynfield_attributes da,
		im_dynfield_widgets dw
	where	aa.attribute_id = da.acs_attribute_id and
		dw.widget_name = da.widget_name and
		dw.widget_name = 'numeric'
);

