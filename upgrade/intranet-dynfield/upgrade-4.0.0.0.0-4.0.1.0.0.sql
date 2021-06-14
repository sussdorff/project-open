-- upgrade-4.0.0.0.0-4.0.1.0.0.sql
--
-- Copyright (c) 2011, cognovi GmbH, Hamburg, Germany
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
-- 

SELECT acs_log__debug('/packages/intranet-dynfield/sql/postgresql/upgrade/upgrade-4.0.0.0.0-4.0.1.0.0.sql','');

comment on table im_dynfield_attributes is 'Contains additional information for an acs_attribute like the widget to be used. The other attributes are mainly for backwards compatibility. Note that dynfield_attributes are acs_objects in contrast to acs_attributes which are NOT acs_objects (see acs_attributes for this)';

comment on column im_dynfield_attributes.attribute_id is 'This column should be called dynfield_id. It is the internal dynfield_id (an object_id) is referenced by the other tables in dynfields to provide the connection between the acs_attribute_id and the display logic of the dynfield';

comment on column im_dynfield_attributes.acs_attribute_id is 'This references the attribute_id from acs_attributes. It is used to connect an acs_attribute with the display_logic';

comment on table im_dynfield_layout is 'This table is used for providing positioning (layout) information of an attribute when being displayed.';
comment on column im_dynfield_layout.attribute_id is 'This is the dynfield_id which references im_dynfield_attributes.';
comment on column im_dynfield_layout.page_url is 'The page_url is the identified which groups the attributes together on a single page. The idea is that you can have a different layout of the attributes depending e.g. if you display the form (which would be displayed like a normal ad_form, where you just need the pos_y to define the order of attributes) and a page to display the attribute values, which could be a table with two columns where you would define which attribute will be displayed on what column in the table (using pos_y). The ''default'' page_url is the standard being used when no other page_url is specified.';
comment on column im_dynfield_layout.pos_x is 'pos_x defines in which column in a table layout you will find the attribute rendered.';
comment on column im_dynfield_layout.pos_y is 'pos_y could also be labelled ''sort_order'', but defines the row coordinate in a table layout where the attribute is rendered. By default im_dynfields supports only one_column which is why the entry form at attribute-new.tcl provides a possibility to enter pos_y for sorting';
comment on column im_dynfield_layout.label_style is ' the style in which the label (attribute_name) is presented in conjunction with the attribute''s value / form_widget. Default is ''table'' which means the label is in column 1 and the value / form_widget is in column 2. Most pages in ]project-open[ don''t bother looking at im_dynfield_layout and just use a normal ''table'' layout. This is changing with the advent of ExtJS driven Forms.';
comment on column im_dynfield_layout.div_class is 'This is the class information which you can pass onto the renderer to override the the standard CSS for this widget. Not in use in any ]project-open[ application as of beginning of 2011';
comment on column im_dynfield_layout.sort_key is 'This is the sorting key for attributes which have a multiple choice widget like combo_box (select) or radio/ checkboxes. This allows you to differentiate if you would like to sort by value or by name. Not in use, all applications default to sort by name as of 2011';


alter table im_dynfield_type_attribute_map drop constraint im_dynfield_type_attr_map_attr_fk;
delete from im_dynfield_type_attribute_map where attribute_id not in (select attribute_id from im_dynfield_attributes);
alter table im_dynfield_type_attribute_map add constraint im_dynfield_type_attr_map_attr_fk foreign key (attribute_id) references im_dynfield_attributes(attribute_id) on delete cascade;

comment on table im_dynfield_type_attribute_map is 'This table defines under which conditions an attribute is to be rendered. The condition is determined by the object_type_id, which is a category_id. This category_id is of the category_type which is defined as ''type_category_type'' for the object_type of the attribute. The object_type ''im_projects'' has a type_category_type in acs_object_types of ''Intranet Project Type'' which is the category_type (in im_categories) that contains all the category_ids which can be used to define conditions in the way of object_type_id.';
comment on column im_dynfield_type_attribute_map.attribute_id is 'This is the dynfield_id from im_dynfield_attributes which identifies the attribute. It is NOT an attribute_id from acs_attributes.';
comment on column im_dynfield_type_attribute_map.object_type_id is 'This is the conditions identifier. This identifier is object specific, so if we take Projects as an example again, the condition is defined by the object''s type_id. In the case of Projects, this is stored in im_projects.project_type_id (see acs_object_types.type_column for more). When an object (e.g. Project) is displayed, the system takes the project_type_id and looks up in type_attribute_map how the attributes for the object_type ''im_project'' are to be treated.';
comment on column im_dynfield_type_attribute_map.display_mode is 'The display mode defining the mode in which the attribute is to be displayed. ''edit'' means, it can be both displayed (attribute & value) and edited in a form. ''display'' means that it will displayed when showing the object, but it will not be included in a form. ''none'' means it will neither show up when displaying the object nor when editing a form for this object. This is in addition to the individual permissions you can give on the dynfield_id, so if Freelancers don''t have permission to view attribute, then it does not matter what the display_mode says, they won''t see it';
comment on column im_dynfield_type_attribute_map.help_text is 'This is the help_text for this attribute. Though usually it is the same for all object_type_ids (and this is how it is saved with im_dynfield::attribute::add) it is possible to make it differ depending on the TYPE (category_id) of the object';
comment on column im_dynfield_type_attribute_map.section_heading is 'This allows the grouping of attributes under a common heading. See ad_form sections for more details.';
comment on column im_dynfield_type_attribute_map.default_value is 'This is the default value for this attribute. Though usually it is the same for all object_type_ids (and this is how it is saved with im_dynfield::attribute::add) it is possible to make it differ depending on the TYPE (category_id) of the object';
comment on column im_dynfield_type_attribute_map.required_p is 'This marks, if the attribute is a required attribute in this condition. This is useful e.g. in Projects where depending on the project_type you want an attribute to be filled out, but for other project types it is not necessary.';

comment on column acs_object_types.status_column is 'Defines the column in the status_type_table which stores the category_id for the STATUS of an object of this object_type.';
comment on column acs_object_types.type_column is 'Defines the column in the status_type_table which stores the category_id for the TYPE of an object of this object_type.';
comment on column acs_object_types.status_type_table is 'Defines the table which stores the STATUS and TYPE of the object_type. Defaults to the table_namee of the object_type';
comment on column acs_object_types.type_category_type is 'Defines the category_type from im_categories which contains the options for the TYPE of the object';
comment on column acs_object_types.object_type_gif is 'Image for the object_type';

