alter table im_dynfield_layout_pages drop constraint im_dynfield_layout_type_ck;

alter table im_dynfield_layout_pages add constraint im_dynfield_layout_type_ck 
check (layout_type in ( 'absolute','relative','adp' ));
