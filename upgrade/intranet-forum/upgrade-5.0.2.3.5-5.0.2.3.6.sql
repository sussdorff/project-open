-- upgrade-5.0.2.3.5-5.0.2.3.6.sql
SELECT acs_log__debug('/packages/intranet-forum/sql/postgresql/upgrade/upgrade-5.0.2.3.5-5.0.2.3.6.sql','');




-- ForumList for home page
--
delete from im_view_columns where column_id >= 4000 and column_id < 4099;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4000,40,NULL,'P',
'$priority','','',2,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4002,40,NULL,'Type',
'"<a href=/intranet-forum/view?[export_vars -url {topic_id return_url}]>\
[im_gif $topic_type]</a>"',
'','',4,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4003,40,NULL,'Object',
'"<a href=$object_view_url$object_id>$object_name</a>"',
'','',5,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4004,40,NULL,'Subject',
'"<a href=/intranet-forum/view?[export_vars -url {topic_id return_url}]>\
[string_truncate -len 80 $subject]</a>"','','',6,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4006,40,NULL,'Due',
'[if {$overdue > 0} {
        set t "<font color=red>$due_date</font>"
} else {
        set t "$due_date"
}]','','',8,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4010,40,NULL,
'"[im_gif help "Select topics here for processing"]"',
'"<input type=checkbox name=topic_id.$topic_id>"',
'','',12,'');




-- ForumList for ProjectViewPage or CompanyViewPage
--
delete from im_view_columns where column_id >= 4100 and column_id < 4199;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4100,41,NULL,'P',
'$priority','','',2,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4102,41,NULL,'Type',
'"<a href=/intranet-forum/view?[export_vars -url {topic_id return_url}]>\
[im_gif $topic_type]</a>"',
'','',4,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4104,41,NULL,'Subject',
'"<a href=/intranet-forum/view?[export_vars -url {topic_id return_url}]>\
[string_truncate -len 80 $subject]</a>"','','',6,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4106,41,NULL,'Due',
'[if {$overdue > 0} {
        set t "<font color=red>$due_date</font>"
} else {
        set t "$due_date"
}]','','',8,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4107,41,NULL,'Own',
'"<a href=/intranet/users/view?user_id=$owner_id>$owner_initials</a>"',
'','',9,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4108,41,NULL,'Ass',
'"<a href=/intranet/users/view?user_id=$asignee_id>$asignee_initials</a>"',
'','',10,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4109,41,NULL,'Status',
'$topic_status','','',11,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4110,41,NULL,
'"[im_gif help "Select topics here for processing"]"',
'"<input type=checkbox name=topic_id.$topic_id>"',
'','',12,'');



-- ForumList for the forum index page (all projects with a lot of space)
--
delete from im_view_columns where column_id >= 4200 and column_id < 4299;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4200,42,NULL,'P',
'$priority','','',2,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4201,42,NULL,'Object',
'"<a href=$object_view_url$object_id>$object_name</a>"',
'','',3,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4202,42,NULL,'Type',
'"<a href=/intranet-forum/view?[export_vars -url {topic_id return_url}]>\
[im_gif $topic_type]</a>"',
'','',4,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4204,42,NULL,'Subject',
'"<a href=/intranet-forum/view?[export_vars -url {topic_id return_url}]>\
[string_truncate -len 80 $subject]</A>"','','',6,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4206,42,NULL,'Due',
'[if {$overdue > 0} {
        set t "<font color=red>$due_date</font>"
} else {
        set t "$due_date"
}]','','',8,'');


insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4207,42,NULL,'Own',
'"<a href=/intranet/users/view?user_id=$owner_id>$owner_initials</a>"',
'','',9,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4208,42,NULL,'Ass',
'"<a href=/intranet/users/view?user_id=$asignee_id>$asignee_initials</a>"',
'','',10,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4209,42,NULL,'Status',
'$topic_status','','',11,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4210,42,NULL,'Read',
'$read','','',12,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4211,42,NULL,
'"[im_gif help "Select topics here for processing"]"',
'"<input type=checkbox name=topic_id.$topic_id>"',
'','',13,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4212,42,NULL,'Folder',
'$folder_name','','',14,'');




-- ForumList Short as a default when no other LIST is found
--
delete from im_view_columns where column_id >= 4400 and column_id < 4499;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4400,44,NULL,'P',
'$priority','','',2,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4402,44,NULL,'Type',
'"<a href=/intranet-forum/view?[export_vars -url {topic_id return_url}]>\
[im_gif $topic_type]</a>"',
'','',4,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4404,44,NULL,'Subject',
'"<a href=/intranet-forum/view?[export_vars -url {topic_id return_url}]>\
[string_truncate -len 80 $subject]</a>"','','',6,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4406,44,NULL,'Due',
'[if {$overdue > 0} {
        set t "<font color=red>$due_date</font>"
} else {
        set t "$due_date"
}]','','',8,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4407,44,NULL,'Own',
'"<a href=/intranet/users/view?user_id=$owner_id>$owner_initials</a>"',
'','',9,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4408,44,NULL,'Ass',
'"<a href=/intranet/users/view?user_id=$asignee_id>$asignee_initials</a>"',
'','',10,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4410,44,NULL,
'"[im_gif help "Select topics here for processing"]"',
'"<input type=checkbox name=topic_id.$topic_id>"',
'','',12,'');

-- commit;


-- ForumList Short as a default when no other LIST is found
--
delete from im_view_columns where column_id >= 4500 and column_id < 4599;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4500,45,NULL,'P',
'$priority','','',2,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4502,45,NULL,'Type',
'"<a href=/intranet-forum/view?[export_vars -url { topic_id return_url}]>\
[im_gif $topic_type]</a>"',
'','',4,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4504,45,NULL,'Subject',
'"<a href=/intranet-forum/view?[export_vars -url { topic_id return_url}]>\
[string_truncate -len 80 $subject]</a>"','','',6,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4506,45,NULL,'Due',
'[if {$overdue > 0} {
        set t "<font color=red>$due_date</font>"
} else {
        set t "$due_date"
}]','','',8,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4507,45,NULL,'Own',
'"<a href=/intranet/users/view?user_id=$owner_id>$owner_initials</a>"',
'','',9,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4508,45,NULL,'Ass',
'"<a href=/intranet/users/view?user_id=$asignee_id>$asignee_initials</a>"',
'','',10,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4510,45,NULL,
'"[im_gif help "Select topics here for processing"]"',
'"<input type=checkbox name=topic_id.$topic_id>"',
'','',12,'');

-- commit;


-- ForumList Short as a default when no other LIST is found
--
delete from im_view_columns where column_id >= 4600 and column_id < 4699;
insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4600,46,NULL,'P',
'$priority','','',2,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4602,46,NULL,'Type',
'"<a href=/intranet-forum/view?[export_vars -url { topic_id return_url}]>\
[im_gif $topic_type]</a>"',
'','',4,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4604,46,NULL,'Subject',
'"<a href=/intranet-forum/view?[export_vars -url { topic_id return_url}]>\
[string_truncate -len 80 $subject]</a>"','','',6,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4606,46,NULL,'Due',
'[if {$overdue > 0} {
        set t "<font color=red>$due_date</font>"
} else {
        set t "$due_date"
}]','','',8,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4607,46,NULL,'Own',
'"<a href=/intranet/users/view?user_id=$owner_id>$owner_initials</a>"',
'','',9,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4608,46,NULL,'Ass',
'"<a href=/intranet/users/view?user_id=$asignee_id>$asignee_initials</a>"',
'','',10,'');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (4610,46,NULL,
'"[im_gif help "Select topics here for processing"]"',
'"<input type=checkbox name=topic_id.$topic_id>"',
'','',12,'');

-- commit;

