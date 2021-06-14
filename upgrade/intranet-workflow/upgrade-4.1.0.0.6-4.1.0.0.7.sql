-- upgrade-4.1.0.0.6-4.1.0.0.7.sql

SELECT acs_log__debug('/packages/intranet-workflow/sql/postgresql/upgrade/upgrade-4.1.0.0.6-4.1.0.0.7.sql','');

--------------------------------------------------------------------------
-- Update the expense approval WF
-- for start -> approve
--

update	wf_places set sort_order = 100 where workflow_key = 'project_approval_wf';

update	wf_places
set	place_name = 'Start'
where	place_key = 'start' and
	workflow_key = 'project_approval_wf';

update	wf_places
set	sort_order = 10
where	place_key = 'before_approve' and
	workflow_key = 'project_approval_wf';


update	wf_arcs
set	place_key = 'before_approve'
where	workflow_key = 'project_approval_wf' and
	transition_key = 'approve' and
	place_key = 'start' and
	direction = 'out';

update	wf_arcs
set	place_key = 'start'
where	workflow_key = 'project_approval_wf' and
	transition_key = 'modify' and
	place_key = 'before_approve' and
	direction = 'out';

update	wf_arcs
set	place_key = 'start'
where	workflow_key = 'project_approval_wf' and
	transition_key = 'approve' and
	place_key = 'before_approve' and
	direction = 'in';

update	wf_arcs
set	place_key = 'before_approve'
where	workflow_key = 'project_approval_wf' and
	transition_key = 'modify' and
	place_key = 'start' and
	direction = 'in';

