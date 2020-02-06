set server_url "http://localhost:8080"
set system_owner sysadmin@cognovis.de
set server_path /var/www/openacs
set develop_p 1
set staging_p 0

parameter::set_from_package_key -package_key acs-kernel -parameter "SystemURL" -value $server_url
parameter::set_from_package_key -package_key intranet-core -parameter "UtilCurrentLocationRedirect" -value $server_url
    
    parameter::set_from_package_key -package_key acs-kernel -parameter "SystemOwner" -value $system_owner
    
    parameter::set_from_package_key -package_key intranet-core -parameter "BackupBasePathUnix" -value "${server_path}/filestorage/backup"
    parameter::set_from_package_key -package_key intranet-filestorage -parameter "BugBasePathUnix" -value "${server_path}/filestorage/bugs"
    parameter::set_from_package_key -package_key intranet-filestorage -parameter "CompanyBasePathUnix" -value "${server_path}/filestorage/companies"
    parameter::set_from_package_key -package_key intranet-filestorage -parameter "HomeBasePathUnix" -value "${server_path}/filestorage/home"
    parameter::set_from_package_key -package_key intranet-filestorage -parameter "ProjectBasePathUnix" -value "${server_path}/filestorage/projects"
    parameter::set_from_package_key -package_key intranet-filestorage -parameter "ProjectSalesBasePathUnix" -value "${server_path}/filestorage/project_sales"
    parameter::set_from_package_key -package_key intranet-filestorage -parameter "TicketBasePathUnix" -value "${server_path}/filestorage/tickets"
    parameter::set_from_package_key -package_key intranet-filestorage -parameter "UserBasePathUnix" -value "${server_path}/filestorage/users"
    parameter::set_from_package_key -package_key intranet-filestorage -parameter "CostBasePathUnix" -value "${server_path}/filestorage/costs"
    parameter::set_from_package_key -package_key intranet-filestorage -parameter "EventBasePathUnix" -value "${server_path}/filestorage/events"
    parameter::set_from_package_key -package_key intranet-invoices -parameter "InvoiceTemplatePathUnix" -value "${server_path}/filestorage/templates"

    catch {parameter::set_from_package_key -package_key intranet-mail-import -parameter "MailDir" -value "${server_path}/maildir"}

    # Set parameters for redirecting mail
    if {$develop_p || $staging_p} {
	parameter::set_from_package_key -package_key acs-mail-lite -parameter "EmailDeliveryMode" -value "redirect"
	parameter::set_from_package_key -package_key acs-mail-lite -parameter "EmailRedirectTo" -value "$system_owner"
	parameter::set_from_package_key -package_key intranet-core -parameter "TestDemoDevServer" -value "1"
        if {[apm_package_installed_p xotcl-core]} {
            parameter::set_from_package_key -package_key xotcl-core -parameter "NslogRedirector" -value "1"
        }
	if {[apm_package_installed_p intranet-collmex]} {
	    parameter::set_from_package_key -package_key intranet-collmex -parameter "ActiveP" -value "0"
	    parameter::set_from_package_key -package_key intranet-collmex -parameter "Login" -value ""
        }
    }

    if { $staging_p } {
	    parameter::set_from_package_key -package_key intranet-core -parameter "MaintenanceMessage" -value "THIS IS A STAGING SERVER. THIS IS NOT PRODUCTION!"
    }

        # Get the mail bounce domain
    set smtp_domain [parameter::get_from_package_key -package_key acs-mail-lite -parameter SMTPHost]
    if {$smtp_domain ne "localhost"} {
	set bounce_domain [join [lrange [split $smtp_domain .] end-1 end] .]
    } else {
	set sender_mail [parameter::get_from_package_key -package_key acs-mail-lite -parameter FixedSenderEmail]
	if {$sender_mail eq ""} { set sender_mail  [parameter::get_from_package_key -package_key acs-mail-lite -parameter NotificationSender] }
	if {$sender_mail eq ""} { set sender_mail  [parameter::get_from_package_key -package_key acs-mail-lite -parameter NotificationSender] }
	if {$sender_mail eq ""} { set sender_mail  [parameter::get_from_package_key -package_key acs-kernel -parameter SystemOwner] }
	if {$sender_mail ne ""} {
	    set bounce_domain [lindex [split $sender_mail "@"] end]
	    parameter::set_from_package_key -package_key acs-mail-lite -parameter "BounceDomain" -value "$bounce_domain"
	}
    }

# Missed upgrade script in ]project-open[
# catch {db_source_sql_file "[acs_package_root_dir acs-kernel]/sql/postgresql/upgrade/upgrade-5.7.0d3-5.7.0d4.sql"}

ad_return_warning "System migrated" "You have migrated to $server_url"