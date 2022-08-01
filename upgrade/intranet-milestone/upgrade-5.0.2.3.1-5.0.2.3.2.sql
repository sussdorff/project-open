-- 5.0.2.3.1-5.0.2.3.2.sql
SELECT acs_log__debug('/packages/intranet-milestone/sql/postgresql/upgrade/upgrade-5.0.2.3.1-5.0.2.3.2.sql','');


update im_component_plugins
set component_tcl = 'im_milestone_tracker -project_id $project_id -diagram_title "Milestones" -diagram_width 300 -diagram_height 300'
where component_tcl = 'im_sencha_milestone_tracker -project_id $project_id -title "Milestones" -diagram_width 300 -diagram_height 300';

