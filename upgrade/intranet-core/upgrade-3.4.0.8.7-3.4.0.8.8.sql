-- upgrade-3.4.0.8.7-3.4.0.8.8.sql

SELECT acs_log__debug('/packages/intranet-core/sql/postgresql/upgrade/upgrade-3.4.0.8.7-3.4.0.8.8.sql','');




-- ------------------------------------------------------------------
-- Add a new message key to the localization system with default
-- translation.
-- ------------------------------------------------------------------


create or replace function im_lang_add_message(text, text, text, text)
returns integer as $body$
DECLARE
	p_locale	alias for $1;
	p_package_key	alias for $2;
	p_message_key	alias for $3;
	p_message	alias for $4;

	v_count		integer;
BEGIN
	-- Do not insert strings for packages that do not exist
	--
	select	count(*) into v_count from apm_packages
	where	package_key = p_package_key;
	IF 0 = v_count THEN return 0; END IF;

	-- Make sure there is an entry in lang_message_keys
	--
	select	count(*) into v_count from lang_message_keys
	where	package_key = p_package_key and message_key = p_message_key;
	IF 0 = v_count THEN
		insert into lang_message_keys (
			message_key, package_key
		) values (
			p_message_key, p_package_key
		);
	END IF;

	-- Create the translation entry
	--
	select	count(*) into v_count from lang_messages
	where	locale = p_locale and package_key = p_package_key and message_key = p_message_key;
	IF 0 = v_count THEN
		insert into lang_messages (
			message_key, package_key, locale, message, sync_time, upgrade_status
		) values (
			p_message_key, p_package_key, p_locale, p_message, now(), 'added'
		);
	END IF;

	return 1;
END;$body$ language 'plpgsql';



SELECT im_lang_add_message('en_US','intranet-confdb','Project_Open_Package',']po[ Package');
SELECT im_lang_add_message('en_US','intranet-confdb','Project_Open_Process',']po[ Process');
SELECT im_lang_add_message('en_US','intranet-core','Project_Open_Package',']po[ Package');
SELECT im_lang_add_message('en_US','intranet-core','Project_Open_Process',']po[ Process');

SELECT im_lang_add_message('en_US','intranet-audit','Action_Abbrev','A');
SELECT im_lang_add_message('en_US','intranet-bug-tracker','Bug_Tracker_Component','Bug Tracker Component');
SELECT im_lang_add_message('en_US','intranet-bug-tracker','Create_a_New_Issue','New Ticket');
SELECT im_lang_add_message('en_US','intranet-bug-tracker','New_Issue','New Ticket');
SELECT im_lang_add_message('en_US','intranet-bug-tracker','Project','Project');
SELECT im_lang_add_message('en_US','intranet-confdb','Postfix_Process','Postfix Process');
SELECT im_lang_add_message('en_US','intranet-confdb','PostgreSQL_Process','PostgreSQL Process');
SELECT im_lang_add_message('en_US','intranet-confdb','Pound_Process','Pound Process');
SELECT im_lang_add_message('en_US','intranet-confdb','Service','Service');
SELECT im_lang_add_message('en_US','intranet-core','acs-core-docs','acs-core-docs');
SELECT im_lang_add_message('en_US','intranet-core','acs-datetime','acs-datetime');
SELECT im_lang_add_message('en_US','intranet-core','acs-events','acs-events');
SELECT im_lang_add_message('en_US','intranet-core','acs-kernel','acs-kernel');
SELECT im_lang_add_message('en_US','intranet-core','acs-lang','acs-lang');
SELECT im_lang_add_message('en_US','intranet-core','acs-mail','acs-mail');
SELECT im_lang_add_message('en_US','intranet-core','acs-mail-lite','acs-mail-lite');
SELECT im_lang_add_message('en_US','intranet-core','acs-messaging','acs-messaging');
SELECT im_lang_add_message('en_US','intranet-core','acs-reference','acs-reference');
SELECT im_lang_add_message('en_US','intranet-core','acs-service-contract','acs-service-contract');
SELECT im_lang_add_message('en_US','intranet-core','acs-subsite','acs-subsite');
SELECT im_lang_add_message('en_US','intranet-core','acs-tcl','acs-tcl');
SELECT im_lang_add_message('en_US','intranet-core','acs-templating','acs-templating');
SELECT im_lang_add_message('en_US','intranet-core','acs-workflow','acs-workflow');
SELECT im_lang_add_message('en_US','intranet-core','Audit_Trail_Projects','Audit Trail Projects');
SELECT im_lang_add_message('en_US','intranet-core','Audit_Trail_Users','Audit Trail Users');
SELECT im_lang_add_message('en_US','intranet-core','bottom','Bottom');
SELECT im_lang_add_message('en_US','intranet-core','Bug_List_Component','Bug List Component');
SELECT im_lang_add_message('en_US','intranet-core','bug-tracker','bug-tracker');
SELECT im_lang_add_message('en_US','intranet-core','calendar','calendar');
SELECT im_lang_add_message('en_US','intranet-core','cms','cms');
SELECT im_lang_add_message('en_US','intranet-core','Component_Page','Component Page');
SELECT im_lang_add_message('en_US','intranet-core','Conf_Item','Conf Item');
SELECT im_lang_add_message('en_US','intranet-core','Current_Milestones','Current Milestones');
SELECT im_lang_add_message('en_US','intranet-core','CVS_Integration','CVS Integration');
SELECT im_lang_add_message('en_US','intranet-core','diagram','Diagram');
SELECT im_lang_add_message('en_US','intranet-core','Expense','Expense');
SELECT im_lang_add_message('en_US','intranet-core','files','Files');
SELECT im_lang_add_message('en_US','intranet-core','finance','Finance');
SELECT im_lang_add_message('en_US','intranet-core','Freelance_List_Component','Freelance List Component');
SELECT im_lang_add_message('en_US','intranet-core','Gantt_Resourcs','Gantt Resources');
SELECT im_lang_add_message('en_US','intranet-core','Gantt_Resources','Gantt Resources');
SELECT im_lang_add_message('en_US','intranet-core','Gantt_Schedule','Gantt Schedule');
SELECT im_lang_add_message('en_US','intranet-core','Home_All_Time_Top_Customers','Home All Time Top Customers');
SELECT im_lang_add_message('en_US','intranet-core','Home_Bug_Tracker_Component','Home Bug Tracker Component');
SELECT im_lang_add_message('en_US','intranet-core','Home_Calendar_Component','Home Calendar Component');
SELECT im_lang_add_message('en_US','intranet-core','Home_Filestorage_Component','Home Filestorage Component');
SELECT im_lang_add_message('en_US','intranet-core','Home_Forum_Component','Home Forum Component');
SELECT im_lang_add_message('en_US','intranet-core','Home_Indicator_Component','Home Indicator Component');
SELECT im_lang_add_message('en_US','intranet-core','Home_Page_Help_Blurb','Home Page Help Blurb');
SELECT im_lang_add_message('en_US','intranet-core','Home_Page_Project_Component','Home Page Project Component');
SELECT im_lang_add_message('en_US','intranet-core','Home_Project_Queue','Home Project Queue');
SELECT im_lang_add_message('en_US','intranet-core','Home_Ticket_Component','Home Ticket Component');
SELECT im_lang_add_message('en_US','intranet-core','Home_Timesheet_Component','Home Timesheet Component');
SELECT im_lang_add_message('en_US','intranet-core','Home_Wiki_Component','Home Wiki Component');
SELECT im_lang_add_message('en_US','intranet-core','Importing_Master_Data','Import Master Data');
SELECT im_lang_add_message('en_US','intranet-core','intranet-audit','intranet-audit');
SELECT im_lang_add_message('en_US','intranet-core','intranet-big-brother','intranet-big-brother');
SELECT im_lang_add_message('en_US','intranet-core','intranet-bug-tracker','intranet-bug-tracker');
SELECT im_lang_add_message('en_US','intranet-core','intranet-calendar','intranet-calendar');
SELECT im_lang_add_message('en_US','intranet-core','intranet-confdb','intranet-confdb');
SELECT im_lang_add_message('en_US','intranet-core','intranet-confdbnew','intranet-confdbnew');
SELECT im_lang_add_message('en_US','intranet-core','intranet-core','intranet-core');
SELECT im_lang_add_message('en_US','intranet-core','intranet-cost-center','intranet-cost-center');
SELECT im_lang_add_message('en_US','intranet-core','intranet-cost','intranet-cost');
SELECT im_lang_add_message('en_US','intranet-core','intranet-dw-light','intranet-dw-light');
SELECT im_lang_add_message('en_US','intranet-core','intranet-dynfield','intranet-dynfield');
SELECT im_lang_add_message('en_US','intranet-core','intranet-expenses','intranet-expenses');
SELECT im_lang_add_message('en_US','intranet-core','intranet-expensesnew','intranet-expensesnew');
SELECT im_lang_add_message('en_US','intranet-core','intranet-filestorage','intranet-filestorage');
SELECT im_lang_add_message('en_US','intranet-core','intranet-forum','intranet-forum');
SELECT im_lang_add_message('en_US','intranet-core','intranet-freelance','intranet-freelance');
SELECT im_lang_add_message('en_US','intranet-core','intranet-helpdesk','intranet-helpdesk');
SELECT im_lang_add_message('en_US','intranet-core','intranet-helpdesknew','intranet-helpdesknew');
SELECT im_lang_add_message('en_US','intranet-core','intranet-hr','intranet-hr');
SELECT im_lang_add_message('en_US','intranet-core','intranet-invoices','intranet-invoices');
SELECT im_lang_add_message('en_US','intranet-core','intranet-material','intranet-material');
SELECT im_lang_add_message('en_US','intranet-core','intranet-milestone','intranet-milestone');
SELECT im_lang_add_message('en_US','intranet-core','intranet-nagios','intranet-nagios');
SELECT im_lang_add_message('en_US','intranet-core','intranet-notes','intranet-notes');
SELECT im_lang_add_message('en_US','intranet-core','intranet-payments','intranet-payments');
SELECT im_lang_add_message('en_US','intranet-core','intranet-reporting','intranet-reporting');
SELECT im_lang_add_message('en_US','intranet-core','intranet-rest','intranet-rest');
SELECT im_lang_add_message('en_US','intranet-core','intranet-search-pg','intranet-search-pg');
SELECT im_lang_add_message('en_US','intranet-core','intranet-sysconfig','intranet-sysconfig');
SELECT im_lang_add_message('en_US','intranet-core','intranet-timesheet2','intranet-timesheet2');
SELECT im_lang_add_message('en_US','intranet-core','intranet-tinytm','intranet-tinytm');
SELECT im_lang_add_message('en_US','intranet-core','intranet-translation','intranet-translation');
SELECT im_lang_add_message('en_US','intranet-core','intranet-wiki','intranet-wiki');
SELECT im_lang_add_message('en_US','intranet-core','intranet-workflow','intranet-workflow');
SELECT im_lang_add_message('en_US','intranet-core','Late_Milestones','Late Milestones');
SELECT im_lang_add_message('en_US','intranet-core','Material','Material');
SELECT im_lang_add_message('en_US','intranet-core','Milestone','Milestone');
SELECT im_lang_add_message('en_US','intranet-core','Month_and_Day','Month and Day');
SELECT im_lang_add_message('en_US','intranet-core','No_OTP_defined_yet','No OTP defined yet');
SELECT im_lang_add_message('en_US','intranet-core','notifications','Notifications');
SELECT im_lang_add_message('en_US','intranet-core','Online_resources_header','Online Resources Header');
SELECT im_lang_add_message('en_US','intranet-core','Person','Person');
SELECT im_lang_add_message('en_US','intranet-core','PO_Documentation_Wiki',']po[ Documentation Wiki');
SELECT im_lang_add_message('en_US','intranet-core','PO_Professional_Services',']po[ ProfessionalServices');
SELECT im_lang_add_message('en_US','intranet-core','PO_Support_Contracts',']po[ Support Contracts');
SELECT im_lang_add_message('en_US','intranet-core','presales_probability','Presales Probability');
SELECT im_lang_add_message('en_US','intranet-core','Presales_Probability','Presales Probability');
SELECT im_lang_add_message('en_US','intranet-core','Presales_Value','Presales Value');
SELECT im_lang_add_message('en_US','intranet-core','Program','Program');
SELECT im_lang_add_message('en_US','intranet-core','Project_CVS_Logs','Project CVS Logs');
SELECT im_lang_add_message('en_US','intranet-core','Project_Finance_Summary_Component','Project Finance Summary Component');
SELECT im_lang_add_message('en_US','intranet-core','Project_Forum_Component','Project Forum Component');
SELECT im_lang_add_message('en_US','intranet-core','Project_Freelance_Tasks','Project Freelance Tasks');
SELECT im_lang_add_message('en_US','intranet-core','Project_GanttProject_Component','Project Gantt Component');
SELECT im_lang_add_message('en_US','intranet-core','Project_Gantt_Resource_Assignations','Project Gantt Resource Assignations');
SELECT im_lang_add_message('en_US','intranet-core','Project_Notes','Project Notes');
SELECT im_lang_add_message('en_US','intranet-core','Project_Timesheet_Component','Project Timesheet Component');
SELECT im_lang_add_message('en_US','intranet-core','Project_Timesheet_Tasks','Project Timesheet Tasks');
SELECT im_lang_add_message('en_US','intranet-core','Project_Translation_Details','Project Translation Details');
SELECT im_lang_add_message('en_US','intranet-core','Project_Translation_Error_Component','Project Translation Error Component');
SELECT im_lang_add_message('en_US','intranet-core','Project_Translation_Task_Action_Log','Project Translation Task Action Log');
SELECT im_lang_add_message('en_US','intranet-core','Project_Translation_Task_Status','Project Translation Task Status');
SELECT im_lang_add_message('en_US','intranet-core','Project_Translation_Wizard','Project Translation Wizard');
SELECT im_lang_add_message('en_US','intranet-core','Project_Wiki_Component','Project Wiki Component');
SELECT im_lang_add_message('en_US','intranet-core','Project_Workflow_Graph','Project Workflow Graph');
SELECT im_lang_add_message('en_US','intranet-core','Project_Workflow_Journal','Project Workflow Journal');
SELECT im_lang_add_message('en_US','intranet-core','Quarter','Quarter');
SELECT im_lang_add_message('en_US','intranet-core','Release_Items_Component','Release Items Component');
SELECT im_lang_add_message('en_US','intranet-core','Release_Items_Journal','Release Items Journal');
SELECT im_lang_add_message('en_US','intranet-core','Resource_Availability_Component','Resource Availability Component');
SELECT im_lang_add_message('en_US','intranet-core','REST_API','REST API');
SELECT im_lang_add_message('en_US','intranet-core','RFQ_Answer','RFQ Answer');
SELECT im_lang_add_message('en_US','intranet-core','RFQ','RFQ');
SELECT im_lang_add_message('en_US','intranet-core','right','Right');
SELECT im_lang_add_message('en_US','intranet-core','Security_Update_Client_Component','Security Update Client Component');
SELECT im_lang_add_message('en_US','intranet-core','simple-survey','simple-survey');
SELECT im_lang_add_message('en_US','intranet-core','SourceForge_Forum','SourceForge Forum');
SELECT im_lang_add_message('en_US','intranet-core','Templates','Templates');
SELECT im_lang_add_message('en_US','intranet-core','top','Top');
SELECT im_lang_add_message('en_US','intranet-core','Training','Training');
SELECT im_lang_add_message('en_US','intranet-core','Translation_Freelance_List','Translation Freelance List');
SELECT im_lang_add_message('en_US','intranet-core','Upload_File','Upload File');
SELECT im_lang_add_message('en_US','intranet-core','User_Employee_Component','User Employee Component');
SELECT im_lang_add_message('en_US','intranet-core','User_Forum_Component','User Forum Component');
SELECT im_lang_add_message('en_US','intranet-core','User_Notes','User Notes');
SELECT im_lang_add_message('en_US','intranet-core','User_Offices','User Offices');
SELECT im_lang_add_message('en_US','intranet-core','Users_Filestorage_Component','Users Filestorage Component');
SELECT im_lang_add_message('en_US','intranet-core','Users_Freelance_Component','Users Freelance Component');
SELECT im_lang_add_message('en_US','intranet-core','Users_Skills_Component','Users Skills Component');
SELECT im_lang_add_message('en_US','intranet-core','User_Wiki_Component','User Wiki Component');
SELECT im_lang_add_message('en_US','intranet-core','Vacation_Balance','Vacation Balance');
SELECT im_lang_add_message('en_US','intranet-core','Week_and_Day','Week and Day');
SELECT im_lang_add_message('en_US','intranet-core','wiki','wiki');
SELECT im_lang_add_message('en_US','intranet-core','xml-rpc','xml-rpc');
SELECT im_lang_add_message('en_US','intranet-core','Your_browser_cant_display_iframes','Your browser is not capable of displaying IFrames');
SELECT im_lang_add_message('en_US','intranet-cost','Update_Exchange_Rates','Update Exchange Rates');
SELECT im_lang_add_message('en_US','intranet-cvs-integration','Project_CVS_Logs','Project CVS Logs');
SELECT im_lang_add_message('en_US','intranet-freelance','Expected_Quality','Expected Quality');
SELECT im_lang_add_message('en_US','intranet-freelance','LOC_Tools','LOC Tools');
SELECT im_lang_add_message('en_US','intranet-freelance','Operating_System','Operating System');
SELECT im_lang_add_message('en_US','intranet-freelance','Sel','Sel');
SELECT im_lang_add_message('en_US','intranet-freelance','Subjects','Subjects');
SELECT im_lang_add_message('en_US','intranet-freelance','Sworn_Language','Sworn Language');
SELECT im_lang_add_message('en_US','intranet-freelance','TM_Tools','TM Tools');
SELECT im_lang_add_message('en_US','intranet-freelance-translation','never','Never');
SELECT im_lang_add_message('en_US','intranet-freelance-translation','twice','Twice');
SELECT im_lang_add_message('en_US','intranet-freelance-translation','Worked_with_Customer_Before','Worked With Customer Before');
SELECT im_lang_add_message('en_US','intranet-ganttproject','All_Employees','All Employees');
SELECT im_lang_add_message('en_US','intranet-ganttproject','Dim_day_of_week','Day of Week');
SELECT im_lang_add_message('en_US','intranet-ganttproject','Resource_Availability','Resource Availability');
SELECT im_lang_add_message('en_US','intranet-ganttproject','Top_Scale','Top Scale');
SELECT im_lang_add_message('en_US','intranet-ganttproject','Upload_Gantt_OpenProj_File','Upload Gantt OpenProj File');

SELECT im_lang_add_message('en_US','intranet-helpdesk','Conf_Item_type_Project_Open_Process','project-open Process');
SELECT im_lang_add_message('en_US','intranet-helpdesk','Conf_Item_type_Service','Service');
SELECT im_lang_add_message('en_US','intranet-helpdesk','Ticket_type_Change_Ticket','Change Ticket');
SELECT im_lang_add_message('en_US','intranet-helpdesk','Ticket_type_Incident_Ticket','Incident Ticket');
SELECT im_lang_add_message('en_US','intranet-helpdesk','Ticket_type_Nagios_Alert','Nagios Alert');
SELECT im_lang_add_message('en_US','intranet-invoices','Timesheet_Weekly_Report','Timesheet Weekly Report');
SELECT im_lang_add_message('en_US','intranet-notes','Note_Type','Note Type');
SELECT im_lang_add_message('en_US','intranet-release-mgmt','Release_Items','Release Items');
SELECT im_lang_add_message('en_US','intranet-reporting','Budged_Check_for_Main_Projects','Budged Check for Main Projects');
SELECT im_lang_add_message('en_US','intranet-reporting-dashboard','All_Time_Top_Customers','All Time Top Customers');
SELECT im_lang_add_message('en_US','intranet-reporting-dashboard','Project_Queue','Project Queue');
SELECT im_lang_add_message('en_US','intranet-reporting-dashboard','Show_Details','Show Details');
SELECT im_lang_add_message('en_US','intranet-reporting','Finance_Data-Warehouse_Cube','Finance Data-Warehouse Cube');
SELECT im_lang_add_message('en_US','intranet-reporting','Finance_Expenses_Cube','Finance Expenses Cube');
SELECT im_lang_add_message('en_US','intranet-reporting','List_of_All_Project_Budgets','List of All Project Budgets');
SELECT im_lang_add_message('en_US','intranet-reporting','Price_Data-Warehouse_Cube','Price Data-Warehouse Cube');
SELECT im_lang_add_message('en_US','intranet-reporting','Timesheet_Data-Warehouse_Cube','Timesheet Data-Warehouse Cube');
SELECT im_lang_add_message('en_US','intranet-reporting','Timesheet_Weekly_Report','Timesheet Weekly Report');
SELECT im_lang_add_message('en_US','intranet-security-update-client','Your_browser_cant_display_iframes','Your browser is not capable of displaying IFrames');
SELECT im_lang_add_message('en_US','intranet-timesheet2','End_Date','End Date');
SELECT im_lang_add_message('en_US','intranet-timesheet2','Name','Name');
SELECT im_lang_add_message('en_US','intranet-timesheet2','Start_Date','Start Date');
SELECT im_lang_add_message('en_US','intranet-timesheet2','Type','Type');
SELECT im_lang_add_message('en_US','intranet-timesheet2','Vacation_Days_Taken','Vacation Days Taken');
SELECT im_lang_add_message('en_US','intranet-translation','All_languages','All Languages');
SELECT im_lang_add_message('en_US','intranet-translation','Associated_reports','Associated Reports');
SELECT im_lang_add_message('en_US','intranet-translation','Create_Batch','Create Batch');
SELECT im_lang_add_message('en_US','intranet-translation','Delete','Delete');
SELECT im_lang_add_message('en_US','intranet-translation','Edit_Button','Edit Button');
SELECT im_lang_add_message('en_US','intranet-translation','Save_Changes','Save Changes');
SELECT im_lang_add_message('en_US','intranet-translation','Submit','Submit');
SELECT im_lang_add_message('en_US','intranet-trans-project-wizard','Assigned_Tasks','Assigned Tasks');
SELECT im_lang_add_message('en_US','intranet-trans-project-wizard','Bills','Bills');
SELECT im_lang_add_message('en_US','intranet-trans-project-wizard','Execution_header','Execution Header');
SELECT im_lang_add_message('en_US','intranet-trans-project-wizard','Hours','Hours');
SELECT im_lang_add_message('en_US','intranet-trans-project-wizard','Invoices','Invoices');
SELECT im_lang_add_message('en_US','intranet-trans-project-wizard','Missing_Files','Missing Files');
SELECT im_lang_add_message('en_US','intranet-trans-project-wizard','Paid_Bills','Paid Bills');
SELECT im_lang_add_message('en_US','intranet-trans-project-wizard','Paid_Invoices','Paid Invoices');
SELECT im_lang_add_message('en_US','intranet-trans-project-wizard','Perc_Done','% Done');
SELECT im_lang_add_message('en_US','intranet-trans-project-wizard','POs','POs');
SELECT im_lang_add_message('en_US','intranet-trans-project-wizard','Translation_Project_Wizard','Translation Project Wizard');
SELECT im_lang_add_message('en_US','intranet-trans-project-wizard','Translators','Translators');
SELECT im_lang_add_message('en_US','intranet-trans-project-wizard','Trans_Tasks','Trans Tasks');
SELECT im_lang_add_message('en_US','intranet-trans-project-wizard','Upload_Missing_Files','Upload Missing Files');
SELECT im_lang_add_message('en_US','intranet-trans-quality','Allowed_error_points','Allowed Error Points');
SELECT im_lang_add_message('en_US','intranet-workflow','Nuke_Object','Nuke Object');
SELECT im_lang_add_message('en_US','intranet-workflow','Remove_From_Inbox','Remove From Inbox');
SELECT im_lang_add_message('en_US','intranet-workflow','Submit','Submit');

SELECT im_lang_add_message('en_US','intranet-confdb','Assoc_with_a_new_project','Associate with a new project');
SELECT im_lang_add_message('en_US','intranet-confdb','Sub_Items','Sub-Items');
SELECT im_lang_add_message('en_US','intranet-confdb','Unassociate','Unassociate');
SELECT im_lang_add_message('en_US','intranet-core','Archived','Archived');
SELECT im_lang_add_message('en_US','intranet-core','Assignee','Assignee');
SELECT im_lang_add_message('en_US','intranet-core','Audit_Trail_Conf_Items','Audit Trail Conf Items');
SELECT im_lang_add_message('en_US','intranet-core','category_key','Category Key');
SELECT im_lang_add_message('en_US','intranet-core','Change_Ticket','Change Ticket');
SELECT im_lang_add_message('en_US','intranet-core','Computer_Bios','Computer BIOS');
SELECT im_lang_add_message('en_US','intranet-core','Computer_Controller','Computer Controller');
SELECT im_lang_add_message('en_US','intranet-core','Computer_Drive','Computer Drive');
SELECT im_lang_add_message('en_US','intranet-core','Computer_Driver','Computer Driver');
SELECT im_lang_add_message('en_US','intranet-core','Computer_File','Computer File');
SELECT im_lang_add_message('en_US','intranet-core','Computer_Lock','Computer Lock');
SELECT im_lang_add_message('en_US','intranet-core','Computer_Memory','Computer Memory');
SELECT im_lang_add_message('en_US','intranet-core','Computer_Modem','Computer Modem');
SELECT im_lang_add_message('en_US','intranet-core','Computer_Monitor','Computer Monitor');
SELECT im_lang_add_message('en_US','intranet-core','Computer_Port','Computer Port');
SELECT im_lang_add_message('en_US','intranet-core','Computer_Slot','Computer Slot');
SELECT im_lang_add_message('en_US','intranet-core','Config_Item','Conf Item');
SELECT im_lang_add_message('en_US','intranet-core','Conf_Item_CVS_Logs','Conf Item CVS Logs');
SELECT im_lang_add_message('en_US','intranet-core','Conf_Item_Wiki_Component','Conf Item Wiki Component');
SELECT im_lang_add_message('en_US','intranet-core','CVS_Hostname','CVS Hostname');
SELECT im_lang_add_message('en_US','intranet-core','CVS_Password','CVS Password');
SELECT im_lang_add_message('en_US','intranet-core','CVS_Path','CVS Path');
SELECT im_lang_add_message('en_US','intranet-core','CVS_Port','CVS Port');
SELECT im_lang_add_message('en_US','intranet-core','CVS_Protocol','CVS Protocol');
SELECT im_lang_add_message('en_US','intranet-core','CVS_System','CVS System');
SELECT im_lang_add_message('en_US','intranet-core','CVS_User','CVS User');
SELECT im_lang_add_message('en_US','intranet-core','Generic-Router','Generic-Router');
SELECT im_lang_add_message('en_US','intranet-core','Hardware_Component','Hardware Component');
SELECT im_lang_add_message('en_US','intranet-core','Hardware','Hardware');
SELECT im_lang_add_message('en_US','intranet-core','Host','Host');
SELECT im_lang_add_message('en_US','intranet-core','Host_Program','Host Program');
SELECT im_lang_add_message('en_US','intranet-core','Host_Screen','Host Screen');
SELECT im_lang_add_message('en_US','intranet-core','Host_Table','Host Table');
SELECT im_lang_add_message('en_US','intranet-core','HTTP-Server','HTTP-Server');
SELECT im_lang_add_message('en_US','intranet-core','Incident_Ticket','Incident Ticket');
SELECT im_lang_add_message('en_US','intranet-core','IP_Address','IP Address');
SELECT im_lang_add_message('en_US','intranet-core','Laptop','Laptop');
SELECT im_lang_add_message('en_US','intranet-core','License','License');
SELECT im_lang_add_message('en_US','intranet-core','Linux-Server','Linux-Server');
SELECT im_lang_add_message('en_US','intranet-core','Mainframe','Mainframe');
SELECT im_lang_add_message('en_US','intranet-core','Netmap','Netmap');
SELECT im_lang_add_message('en_US','intranet-core','Network_Device','Network Device');
SELECT im_lang_add_message('en_US','intranet-core','Network','Network');
SELECT im_lang_add_message('en_US','intranet-core','Network_Router','Network Router');
SELECT im_lang_add_message('en_US','intranet-core','Network_Switch','Network Switch');
SELECT im_lang_add_message('en_US','intranet-core','New_Number_Location','New Number Location');
SELECT im_lang_add_message('en_US','intranet-core','OCS_Device_ID','OCS Device ID');
SELECT im_lang_add_message('en_US','intranet-core','OCS_ID','OCS_ID');
SELECT im_lang_add_message('en_US','intranet-core','OCS_Last_Update','OCS Last Update');
SELECT im_lang_add_message('en_US','intranet-core','OCS_Username','OCS Username');
SELECT im_lang_add_message('en_US','intranet-core','Old_Number_Location','Old Number Location');
SELECT im_lang_add_message('en_US','intranet-core','OS_Comments','OS Comments');
SELECT im_lang_add_message('en_US','intranet-core','OS_Name','OS Name');
SELECT im_lang_add_message('en_US','intranet-core','OS_Version','OS Version');
SELECT im_lang_add_message('en_US','intranet-core','Personal_Computer','Personal Computer');
SELECT im_lang_add_message('en_US','intranet-core','po_Component',']po[ Component');
SELECT im_lang_add_message('en_US','intranet-core','Postfix_Process','Postfix Process');
SELECT im_lang_add_message('en_US','intranet-core','PostgreSQL_Process','PostgreSQL Process');
SELECT im_lang_add_message('en_US','intranet-core','Pound_Process','Pound Process');
SELECT im_lang_add_message('en_US','intranet-core','Preactive','Preactive');
SELECT im_lang_add_message('en_US','intranet-core','Priority','Priority');
SELECT im_lang_add_message('en_US','intranet-core','Proc_Num','Proc. Num');
SELECT im_lang_add_message('en_US','intranet-core','Proc_Speed','Proc. Speed');
SELECT im_lang_add_message('en_US','intranet-core','Proc_Text','Proc. Text');
SELECT im_lang_add_message('en_US','intranet-core','Quoted_Days','Quoted Days');
SELECT im_lang_add_message('en_US','intranet-core','Server','Server');
SELECT im_lang_add_message('en_US','intranet-core','Service','Service');
SELECT im_lang_add_message('en_US','intranet-core','Software_Application','Software Application');
SELECT im_lang_add_message('en_US','intranet-core','Software_Component','Software Component');
SELECT im_lang_add_message('en_US','intranet-core','Software','Software');
SELECT im_lang_add_message('en_US','intranet-core','Subnet','Subnet');
SELECT im_lang_add_message('en_US','intranet-core','Sys_Memory','Sys Memory');
SELECT im_lang_add_message('en_US','intranet-core','Sys_Swap','Sys Swap');
SELECT im_lang_add_message('en_US','intranet-core','Ticket_Owner','Ticket Owner');
SELECT im_lang_add_message('en_US','intranet-core','Ticket_Status','Ticket Status');
SELECT im_lang_add_message('en_US','intranet-core','Ticket_Type','Ticket Type');
SELECT im_lang_add_message('en_US','intranet-core','Win_Company','Win Company');
SELECT im_lang_add_message('en_US','intranet-core','Win_Owner','Win Owner');
SELECT im_lang_add_message('en_US','intranet-core','Win_Product_ID','Win Product_ID');
SELECT im_lang_add_message('en_US','intranet-core','Win_Product_Key','Win Product_Key');
SELECT im_lang_add_message('en_US','intranet-core','Win_Userdomain','Win Userdomain');
SELECT im_lang_add_message('en_US','intranet-core','Win_Workgroup','Win Workgroup');
SELECT im_lang_add_message('en_US','intranet-core','Workstation','Workstation');
SELECT im_lang_add_message('en_US','intranet-core','Zombie','Zombie');
SELECT im_lang_add_message('en_US','intranet-cvs-integration','CVS_Logs','CVS Logs');
SELECT im_lang_add_message('en_US','intranet-helpdesk','Change_Ticket','Change Ticket');
SELECT im_lang_add_message('en_US','intranet-helpdesk','Creator','Creator');
SELECT im_lang_add_message('en_US','intranet-helpdesk','Incident_Ticket','Incident Ticket');
SELECT im_lang_add_message('en_US','intranet-helpdesk','Nagios_Alert','Nagios Alert');
SELECT im_lang_add_message('en_US','intranet-helpdesk','SLA_long','SLA Long');
SELECT im_lang_add_message('en_US','intranet-helpdesk','Ticket_type','Ticket Type');
SELECT im_lang_add_message('en_US','intranet-reporting-dashboard','Ticket_per_Ticket_Status','Ticket per Ticket Status');
SELECT im_lang_add_message('en_US','intranet-reporting-dashboard','Ticket_per_Ticket_Type','Ticket per Ticket Type');
SELECT im_lang_add_message('en_US','intranet-reporting-dashboard','Tickets_per_Ticket_Owner','Tickets per Ticket Owner');
SELECT im_lang_add_message('en_US','intranet-reporting-dashboard','Tickets_per_Ticket_Status','Tickets per Ticket Status');
SELECT im_lang_add_message('en_US','intranet-reporting-dashboard','Tickets_per_Ticket_Type','Tickets per Ticket Type');
SELECT im_lang_add_message('en_US','intranet-reporting','Timesheet_Project_Hierarchy_&_Finance','Timesheet Project Hierarchy & Finance');

-- Priorities for Helpdesk
SELECT im_lang_add_message('en_US','intranet-core','1','1');
SELECT im_lang_add_message('en_US','intranet-core','2','2');
SELECT im_lang_add_message('en_US','intranet-core','3','3');
SELECT im_lang_add_message('en_US','intranet-core','4','4');
SELECT im_lang_add_message('en_US','intranet-core','5','5');
SELECT im_lang_add_message('en_US','intranet-core','6','6');
SELECT im_lang_add_message('en_US','intranet-core','7','7');
SELECT im_lang_add_message('en_US','intranet-core','8','8');
SELECT im_lang_add_message('en_US','intranet-core','9','9');

