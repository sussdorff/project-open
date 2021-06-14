-- 5.0.2.3.0-5.0.2.3.1.sql
SELECT acs_log__debug('/packages/intranet-cost/sql/postgresql/upgrade/upgrade-5.0.2.3.0-5.0.2.3.1.sql','');

update im_component_plugins
set component_tcl = 
        'set a [lang::message::lookup "" intranet-core.Finance_Home_Page_Help "
		This page shows a section of possible reports and indicators that might help you
		to obtain a quick overview over your company finance.<br>
		The examples included below can be easily modified and extended to suit your needs. <br>
		Please login as System Administrator and click on the wrench ([im_gif wrench])
		symbols to the right of each portlet.
	"]'
where plugin_name = 'Finance Home Page Help';

