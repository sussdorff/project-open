-- upgrade-5.0.0.0.1-5.0.1.0.0.sql

SELECT acs_log__debug('/packages/intranet-portfolio-management/sql/postgresql/upgrade/upgrade-5.0.0.0.1-5.0.1.0.0.sql','');


create or replace function inline_0 ()
returns integer as $$
declare
	v_menu			integer;
	v_main_menu		integer;
	v_employees		integer;
BEGIN
	select group_id into v_employees from groups where group_name = 'Employees';
	select menu_id into v_main_menu from im_menus where label = 'main';
	v_menu := im_menu__new (
		null, 'im_menu', now(), null, null, null, -- meta information
		'intranet-portfolio-management',	-- package_name
		'portfolio',				-- label
		'Portfolio',				-- name
		'/intranet-portfolio-management/',	-- url
		45,					-- sort_order
		v_main_menu,				-- parent_menu_id
		null					-- p_visible_tcl
	);
	PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');
	return 0;
end;$$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




create or replace function inline_0 ()
returns integer as $$
declare
	v_menu				integer;
	v_portfolio_menu		integer;
	v_employees			integer;
BEGIN
	select group_id into v_employees from groups where group_name = 'Employees';
	select menu_id into v_portfolio_menu from im_menus where label = 'portfolio';
	v_menu := im_menu__new (
		null, 'im_menu', now(), null, null, null,	-- meta information
		'intranet-portfolio-management',		-- package_name
		'strategic_vs_roi',				-- label
		'Strategic Value vs. ROI',			-- name
		'/intranet-portfolio-management/strategic-value-vs-roi', -- url
		45,						-- sort_order
		v_portfolio_menu,				-- parent_menu_id
		null						-- p_visible_tcl
	);
	PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');
	return 0;
end;$$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();





create or replace function inline_0 ()
returns integer as $$
declare
	v_menu				integer;
	v_portfolio_menu		integer;
	v_employees			integer;
BEGIN
	select group_id into v_employees from groups where group_name = 'Employees';
	select menu_id into v_portfolio_menu from im_menus where label = 'portfolio';
	v_menu := im_menu__new (
		null, 'im_menu', now(), null, null, null,	-- meta information
		'intranet-portfolio-management',		-- package_name
		'risk_vs_roi',					-- label
		'Risk vs. ROI',					-- name
		'/intranet-portfolio-management/risk-vs-roi',	-- url
		55,						-- sort_order
		v_portfolio_menu,				-- parent_menu_id
		null						-- p_visible_tcl
	);
	PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');
	return 0;
end;$$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();

