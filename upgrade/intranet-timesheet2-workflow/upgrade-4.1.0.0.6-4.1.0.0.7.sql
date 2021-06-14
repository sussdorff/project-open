-- upgrade-4.1.0.0.6-4.1.0.0.7.sql

SELECT acs_log__debug('/packages/intranet-timesheet2-workflow/sql/postgresql/upgrade/upgrade-4.1.0.0.6-4.1.0.0.7.sql','');




update	wf_places set sort_order = 100 where workflow_key = 'vacation_approval_wf';

update	wf_places
set	place_name = 'Start'
where	place_key = 'start' and
	workflow_key = 'vacation_approval_wf';

update	wf_places
set	sort_order = 10
where	place_key = 'before_review' and
	workflow_key = 'vacation_approval_wf';


update	wf_arcs
set	place_key = 'before_review'
where	workflow_key = 'vacation_approval_wf' and
	transition_key = 'approve' and
	place_key = 'start' and
	direction = 'out';

update	wf_arcs
set	place_key = 'start'
where	workflow_key = 'vacation_approval_wf' and
	transition_key = 'modify' and
	place_key = 'before_review' and
	direction = 'out';

update	wf_arcs
set	place_key = 'start'
where	workflow_key = 'vacation_approval_wf' and
	transition_key = 'approve' and
	place_key = 'before_review' and
	direction = 'in';

update	wf_arcs
set	place_key = 'before_review'
where	workflow_key = 'vacation_approval_wf' and
	transition_key = 'modify' and
	place_key = 'start' and
	direction = 'in';











--------------------------------------------------------------------------
-- Update the timesheet approval WF
-- for start -> approve
--

update	wf_places set sort_order = 100 where workflow_key = 'timesheet_approval_wf';

update	wf_places
set	place_name = 'Start'
where	place_key = 'start' and
	workflow_key = 'timesheet_approval_wf';

update	wf_places
set	sort_order = 10
where	place_key = 'before_confirm_hours' and
	workflow_key = 'timesheet_approval_wf';


update	wf_arcs
set	place_key = 'before_confirm_hours'
where	workflow_key = 'timesheet_approval_wf' and
	transition_key = 'approve' and
	place_key = 'start' and
	direction = 'out';

update	wf_arcs
set	place_key = 'start'
where	workflow_key = 'timesheet_approval_wf' and
	transition_key = 'modify' and
	place_key = 'before_confirm_hours' and
	direction = 'out';

update	wf_arcs
set	place_key = 'start'
where	workflow_key = 'timesheet_approval_wf' and
	transition_key = 'approve' and
	place_key = 'before_confirm_hours' and
	direction = 'in';

update	wf_arcs
set	place_key = 'before_confirm_hours'
where	workflow_key = 'timesheet_approval_wf' and
	transition_key = 'modify' and
	place_key = 'start' and
	direction = 'in';

