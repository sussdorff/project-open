# packages/intranet-search-pg/www/search.tcl
#
# Copyright (C) 1998-2004 various parties
# The code is based on ArsDigita ACS 3.4
#
# This program is free software. You can redistribute it
# and/or modify it under the terms of the GNU General
# Public License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option)
# any later version. This program is distributed in the
# hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.

ad_page_contract {
    @author Neophytos Demetriou <k2pts@cytanet.com.cy>
    @author Frank Bergmann <frank.bergmann@project-open.com>
    @creation-date May 20th, 2005
    @cvs-id $Id: search.tcl,v 1.51 2019/07/02 14:41:46 cvs Exp $

    This search page uses the "TSearch2" full text index (FTI)
    and the P/O permission system to locate suitable business
    objects for a search query.<p>

    The main problem of searching in P/O is it's relatively
    strict permission system with object specific permissions
    that can only be tested via a (relatively slow) TCL routine.
    For example: Project are readable for the "key account"
    managers of the project's customer.<p>

    So this search page contains several performance optimizations:
    <ul>
    <li>Rapid exclusion of non-allowed objects:<br>
	A search query can return millions of object_id's in
	the worst case. Testing each of these objects for permission
	would take minutes or even hours.
	However, we can (frequently!) discard a large number of
	these objects when they are located in projects (or 
	companies, offices, ...) that are outside of the permission
	scope of the current user. This is why the "im_search_objects"
	table explicitely carries the "business_object_id".

    <li>Explicit permissions for specific "profiles":<br>
	Explicit permissions are given for certain user groups,
	most notably "Registered Users". So documents in a project
	folder that are marked as publicly readable can be found
	even if the project may not be readable at all.
    </ul>

} {
    {q:trim ""}
    {t:trim ""}
    {offset:integer 0}
    {results_per_page:integer 0}
    {type:multiple "all"}
    {include_deleted_p 0}
} 

# -----------------------------------------------------------
# Default & Security
# -----------------------------------------------------------

set current_user_id [auth::require_login]
set page_title [lang::message::lookup "" intranet-search-pg.Search_Results_for_query "Search Results for '%q%'"]
set package_id [ad_conn package_id]
set package_url [ad_conn package_url]
set package_url_with_extras $package_url
set context [list]
set context_base_url $package_url

# Determine the user's group memberships
set user_is_employee_p [im_user_is_employee_p $current_user_id]
set user_is_customer_p [im_user_is_customer_p $current_user_id]
set user_is_wheel_p [im_profile::member_p -profile_id [im_wheel_group_id] -user_id $current_user_id]
set user_is_admin_p [im_is_user_site_wide_or_intranet_admin $current_user_id]
set user_is_admin_p [expr {$user_is_admin_p || $user_is_wheel_p}]


if {"" == $q} {
    ad_return_complaint 1 [_ search.lt_You_must_specify_some]
}

if { $results_per_page <= 0} {
    set results_per_page [im_parameter -package_id $package_id SearchResultsPerPage -default 20]
} else {
    set results_per_page $results_per_page
}

set limit [expr {100 * $results_per_page}]

if {[lsearch im_document $type] >= 0} {
    ad_return_complaint 1 "<h3>Not implemented yet</h3>
    Sorry, searching for documents has not been implemented yet."
    return
}

# Normalize query - lowercase and without double quotes
set q [string tolower $q]
regsub -all {["']} $q {} q


# Remove accents and other special characters from
# search query. Also remove "@", "-" and "." and 
# convert them to spaces
set q [db_exec_plsql normalize "select norm_text(:q)"]
set query $q
#set q [join $q " & "]

# Determine if there are several parts to the query
set nquery [llength $q]

# Set default values
set high 0
set count 1
set num_results 0
set elapsed 0
set result_page_html ""
set from_result_page ""
set to_result_page ""
set result_html ""
set objects_html ""


# -------------------------------------------------
# Check if it's a simple query...
# -------------------------------------------------

set simple_query 1
if {$nquery > 1} {

    # Check that all keywords are alphanumeric
    foreach keyword $query {

	if {![regexp {^[a-zA-Z0-9]*$} $keyword]} {
	    set simple_query 0
	}
    }

}

# insert "&" between elements of a simple query
if {$simple_query && $nquery > 1} {
    set q [join $query " & "]
}

# -------------------------------------------------
# 
# -------------------------------------------------

set error_message "
	<H2>[lang::message::lookup "" intranet-search-pg.Bad_Query "Bad Query"]</h2>
	[lang::message::lookup "" intranet-search-pg.Bad_Query_Msg "
        The &\#93;po&\#91; search engine is capable of processing complex queries 
	with more then one word. <br>
        However, you need to instruct the search engine how to search:
        <p>
        <ul>
          <li>Keyword1 <b>&</b> Keyword2:<br>
              Searches for objects that contain both keywords.<br>&nbsp;
          <li>Keyword1 <b>|</b> Keyword2:<br>
              Searches for objects that contain either of the two keywords.<br>&nbsp;
          <li><b>!</b>Keyword:<br>
              Searches for all object that DO NOT contain Keyword.<br>&nbsp;
          <li><b>(</b>Query<b>)</b>:<br>
              You can use parentesis to group queries.<br>&nbsp;
        </ul>
        
        <H3>Examples</h3>
	<ul>
	  <li><b>'project & open'</b>:<br>
	      Searches for all objects that contain both 'project' and 'open'.
	      <br>&nbsp;

	  <li><b>'project | open'</b>:<br>
	      Searches for all objects that contain either 'project' or 'open'.
	      <br>&nbsp;

	</ul>
"]"



if {$nquery > 1} {
    
    if {[catch {
	db_string test_query "select to_tsquery(:q)"
    } errmsg]} {
	set result_html $error_message
	ad_return_template
	return
    }

}

set urlencoded_query [ad_urlencode $q]
if { $offset < 0 } { set offset 0 }
set t0 [clock clicks -milliseconds]


# -----------------------------------------------------------
# Prepare the list of searchable object types
# -----------------------------------------------------------

set sql "
	select
		sot.object_type_id,
		aot.object_type,
		aot.pretty_name as object_type_pretty_name,
		aot.pretty_plural as object_type_pretty_plural
	from
		im_search_object_types sot,
		acs_object_types aot
	where
		sot.object_type = aot.object_type
"

db_foreach object_type $sql {
    set checked ""
    if {$type eq "all" || [lsearch $type $object_type] >= 0} {
	set checked " checked"
    }
    regsub -all { } $object_type_pretty_name {_} object_type_pretty_name_sub

    if {"im_invoice" eq $object_type} {
	set object_type_pretty_name  [lang::message::lookup "" intranet-cost.FinancialDocument "Financial Document"]
    } else {
	set object_type_pretty_name [lang::message::lookup "" intranet-core.$object_type_pretty_name_sub $object_type_pretty_name]
    }

    append objects_html "
	<tr>
	  <td>
	    <input type=checkbox name=type value='$object_type' id='type,$object_type' $checked>
	  </td>
	  <td>
	    $object_type_pretty_name
	  </td>
	</tr>
"
}


# -----------------------------------------------------------
# Permissions for different types of business objects
# -----------------------------------------------------------

# --------------------- Project -----------------------------------
set project_perm_sql "
			and p.project_id in (
			        select
			                p.project_id
			        from
			                im_projects p,
			                acs_rels r
			        where
			                r.object_id_one = p.project_id
			                and r.object_id_two = :current_user_id
			)"

if {[im_permission $current_user_id "view_projects_all"]} {
        set project_perm_sql ""
}


# --------------------- Companies ----------------------------------
set company_perm_sql "
			and c.company_id in (
			        select	c.company_id
			        from	im_companies c,
			                acs_rels r
			        where	r.object_id_one = c.company_id
			                and r.object_id_two = :current_user_id
					and c.company_status_id not in ([im_company_status_deleted])
			)"

if {[im_permission $current_user_id "view_companies_all"]} {
        set company_perm_sql "
			and c.company_status_id not in ([im_company_status_deleted])
	"
}



# --------------------- Conf Items ----------------------------------
set conf_item_perm_sql "
			and c.conf_item_id in (
			        select	c.conf_item_id
			        from	im_conf_items c,
			                acs_rels r
			        where	r.object_id_one = c.conf_item_id
			                and r.object_id_two = :current_user_id
					and c.conf_item_status_id not in ([im_conf_item_status_deleted])
			)"

if {[im_permission $current_user_id "view_conf_items_all"]} {
        set conf_item_perm_sql "
			and c.conf_item_status_id not in ([im_conf_item_status_deleted])
	"
}


# --------------------- Events ----------------------------------
set event_perm_sql "
			and e.event_id in (
			        select	c.event_id
			        from	im_events c,
			                acs_rels r
			        where	r.object_id_one = c.event_id
			                and r.object_id_two = :current_user_id
					and c.event_status_id not in (82099) -- 82099=im_event_status_deleted
			)"

if {[im_permission $current_user_id "view_events_all"]} {
        set event_perm_sql "
			and e.event_status_id not in ([im_event_status_deleted])
	"
}




# --------------------- Financial Documents -----------------------------------
# Let a user see the financial document if he can read/admin either the 
# customer or the provider of the financial document
# Include the join with "im_invoices", because it is actually
# very selective (few cost items are financial documents)

set customer_sql "
	select distinct
		c.company_id
	from
		im_companies c,
		acs_rels r
	where
		c.company_type_id in ([join [im_sub_categories [im_company_type_customer]] ","])
		and r.object_id_one = c.company_id
		and r.object_id_two = :current_user_id
		and c.company_path != 'internal'
"
if {![im_user_is_customer_p $current_user_id]} { set customer_sql "select 0 as company_id" }


set provider_sql "
	select distinct
		c.company_id
	from
		im_companies c,
		acs_rels r
	where
		c.company_type_id in ([join [im_sub_categories [im_company_type_provider]] ","])
		and r.object_id_one = c.company_id
		and r.object_id_two = :current_user_id
		and c.company_path != 'internal'
"
if {![im_user_is_freelance_p $current_user_id]} { set provider_sql "select 0 as company_id" }


set invoice_perm_sql "
			and i.invoice_id in (
				select	i.invoice_id
				from	im_invoices i,
					im_costs c
				where	i.invoice_id = c.cost_id
					and (
					    c.customer_id in ($customer_sql)
					OR
					    c.provider_id in ($provider_sql)
					)
			)"

if {[im_permission $current_user_id "view_invoices"]} {
	set invoice_perm_sql ""
}


# --------------------- Users -----------------------------------
# The list of prohibited users: They belong 
# to a group which the current user should not see
set user_perm_sql "
			and person_id not in (
select distinct
	cc.user_id
from
	cc_users cc,
	(
		select  group_id
		from    groups
		where   group_id > 0
			and 'f' = im_object_permission_p(group_id,8849,'read')
	) forbidden_groups,
	group_approved_member_map gamm
where
	cc.user_id = gamm.member_id
	and gamm.group_id = forbidden_groups.group_id
			)"

if {[im_permission $current_user_id "view_users_all"]} {
	set user_perm_sql ""
}

# user_perm_sql is very slow (~20 seconds), so
# just leave the permission check for later...
set user_perm_sql ""

# Don't show deleted users (by default...)
set deleted_users_sql "
	and p.person_id not in (
		select	m.member_id
		from	group_member_map m, 
			membership_rels mr
		where  	m.group_id = acs__magic_object_id('registered_users') 
		  	AND m.rel_id = mr.rel_id 
		  	AND m.container_id = m.group_id 
		  	AND m.rel_type::text = 'membership_rel'
			AND mr.member_state != 'approved'
	)
"
if {1 == $include_deleted_p} {
    set deleted_users_sql ""
}


# --------------------- Files -----------------------------------
set file_perm_sql "
			and p.file_id in (
			        select
			                p.file_id
			        from
			                im_files p,
			                acs_rels r
			        where
			                r.object_id_one = p.file_id
			                and r.object_id_two = :current_user_id
			)"

if {[im_permission $current_user_id "view_projects_all"]} {
        set file_perm_sql ""
}




# --------------------- Forums -----------------------------------
set forum_perm_sql ""



# -----------------------------------------------------------
# Build a suitable select for object types
# -----------------------------------------------------------

foreach t $type {

    # Security check for cross site scripting
    if {![regexp {^[a-zA-Z0-9_]*$} $t]} {
	im_security_alert \
	    -location "/intranet-search-pg/www/search.tcl" \
	    -message "Invalid search object type - SQL injection attempt" \
	    -value [ns_quotehtml $t]
	# Quote the harmful var
	regsub -all {[^a-zA-Z0-9_]} $t "_" t
    }
    
    lappend types "'$t'"
} 

set object_type_where "object_type in ([join $types ","])"
if {"all" eq $type} {
    set object_type_where "1=1"
}

# -----------------------------------------------------------
# Main SQL
# -----------------------------------------------------------

set conf_item_union ""
if {[im_table_exists im_conf_items]} {
    set conf_item_union "
		    UNION
			select	conf_item_id as object_id,
				'im_conf_item' as object_type,
                                0 as object_sub_type_id
			from	im_conf_items c
			where	1=1
				$conf_item_perm_sql
    "
}

set event_union ""
if {[im_table_exists im_events]} {
    set event_union "
		    UNION
			select	event_id as object_id,
				'im_event' as object_type,
                                0 as object_sub_type_id
			from	im_events e
			where	1=1
				$event_perm_sql
    "
}


set invoice_union ""
if {[im_table_exists im_invoices]} {
    set invoice_union "
		    UNION
			select	invoice_id as object_id,
				'im_invoice' as object_type,
                                c.cost_type_id as object_sub_type_id
			from	im_invoices i,
				im_costs c
			where	i.invoice_id = c.cost_id
				$invoice_perm_sql
    "
}

set sql "
	select
		acs_object__name(so.object_id) as name,
		acs_object__name(so.biz_object_id) as biz_object_name,
		(ts_rank(so.fti, :q::tsquery) * sot.rel_weight)::numeric(12,2) as rank,
		fti as full_text_index,
		(select min(url) from im_biz_object_urls where url_type = 'view' and object_type = sot.object_type) as object_url,
		(select min(url) from im_biz_object_urls where url_type = 'view' and object_type = readable_biz_objs.object_type) as biz_object_url,
		so.object_id,
		sot.object_type,
		(select aot.pretty_name from acs_object_types aot where aot.object_type = sot.object_type) as object_type_pretty_name,
		(select aot2.pretty_name from acs_object_types aot2 where aot2.object_type = readable_biz_objs.object_type) as biz_object_type_pretty_name,
		so.biz_object_id,
		so.popularity,
		readable_biz_objs.object_type as biz_object_type,
                readable_biz_objs.object_sub_type_id as object_sub_type_id
	from
		im_search_objects so,
		(	select	*
			from	im_search_object_types 
			where	$object_type_where
		) sot,
		(
			select	project_id as object_id,
				'im_project' as object_type,
				0 as object_sub_type_id
			from	im_projects p
			where	1=1
				$project_perm_sql
		    UNION
			select	company_id as object_id,
				'im_company' as object_type,
                                0 as object_sub_type_id
			from	im_companies c
			where	1=1
				$company_perm_sql
		    $invoice_union
		    UNION
			select	person_id as object_id,
				'user' as object_type,
                                0 as object_sub_type_id
			from	persons p
			where	1=1
				$deleted_users_sql
				$user_perm_sql
                    UNION
                        select  item_id as object_id,
                                'content_item' as object_type,
                                0 as object_sub_type_id
                        from    cr_items c
                        where   1=1
		    $conf_item_union
		    $event_union
		) readable_biz_objs
	where	so.object_type_id = sot.object_type_id and
		so.biz_object_id = readable_biz_objs.object_id and
		so.fti @@ to_tsquery(:q)
	order by
		(ts_rank(so.fti, :q::tsquery) * sot.rel_weight) DESC
	offset :offset
	limit :limit
"

set count 0
db_foreach full_text_query $sql {

    incr count

    # Localize the object type
    regsub -all { } $object_type_pretty_name {_} object_type_pretty_name_sub
    regsub -all { } $biz_object_type_pretty_name {_} biz_object_type_pretty_name_sub
    set object_type_pretty_name [lang::message::lookup "" intranet-core.$object_type_pretty_name_sub $object_type_pretty_name]
    set biz_object_type_pretty_name [lang::message::lookup "" intranet-core.$biz_object_type_pretty_name_sub $biz_object_type_pretty_name]


    # Skip further permissions checking if we reach the
    # maximum number of records. However, keep on counting
    # until "limit" in order to get an idea of the total
    # number of results
    if {$count > $results_per_page} {
	continue
    }

    set name_link $name
    if {"" != $object_url} {
	set name_link "<a href=\"$object_url$object_id\">$name</a>\n"
    }
    
    set text [im_tsvector_to_headline $full_text_index]
    set headline [db_string headline "select ts_headline(:text, :q::tsquery)" -default ""]

    # Final permission test: Make sure no object slips through security
    # even if it's kind of slow to do this iteratively...
    switch $object_type {
	im_project { 
	    im_project_permissions $current_user_id $object_id view read write admin
	    if {!$read} { continue }
	}
	user { 
	    im_user_permissions $current_user_id $object_id view read write admin
	    if {!$read} { continue }
	}
	im_fs_file { 
	    # The file is readable if it's business object is readable
	    # AND if the folder is readable

	    # Very ugly: The biz_object_id is not checked for "user"
	    # because it is very slow... So check it here now.
	    if {"user" == $biz_object_type} {
		im_user_permissions $current_user_id $biz_object_id view read write admin
		if {!$read} { continue }
	    }

	    # Determine the permissions for the file
	    set file_permission_p 0
	    db_0or1row forum_perm "
		select	f.filename,
			'1' as file_permission_p
		from	im_fs_files f
		where	f.file_id = :object_id
	    "
	    if {!$file_permission_p} { continue }

	    set name_link "<a href=\"$object_url$biz_object_id&view_name=files\">$biz_object_name</a>: $filename\n"
	}
	im_forum_topic {
	    # The topic is readable if it's business object is readable
	    # AND if the user belongs to the right "sphere"

	    # Very ugly: The biz_object_id is not checked for "user"
	    # because it is very slow... So check it here now.
	    if {"user" == $biz_object_type} {
		im_user_permissions $current_user_id $biz_object_id view read write admin
		if {!$read} { continue }
	    }

	    # Determine if the current user belongs to the admins of
	    # the "business object". This is necessary, because there
	    # is the forum permission "PM Only" which gives rights only"
	    # to the (project) managers of the of the container biz object
	    set object_admin_sql "
				( select count(*) 
				  from	acs_rels r,
					im_biz_object_members m
				  where	r.object_id_two = :current_user_id
					and r.object_id_one = :biz_object_id
					and r.rel_id = m.rel_id
					and m.object_role_id in (1301, 1302, 1303, 1309)
				)::integer\n"
	    if {$user_is_admin_p} { set object_admin_sql "1::integer\n" }

	    # Determine the permissions for the forum item
	    set forum_permission_p 0
	    db_0or1row forum_perm "
		select	t.subject,
			im_forum_permission(
				:current_user_id::integer,
				t.owner_id,
				t.asignee_id,
				t.object_id,
				t.scope,
				1::integer,
				$object_admin_sql ,
				:user_is_employee_p::integer,
				:user_is_customer_p::integer
			) as forum_permission_p
		from	im_forum_topics t
		where	t.topic_id = :object_id
	    "
	    if {!$forum_permission_p} { continue }
#	    set name_link "<a href=\"$url$object_id\">$biz_object_name: $subject</a>\n"
	    set name_link "<a href=\"$object_url$object_id\">$biz_object_name: $subject</a>\n"
	}
	content_item {
	    db_1row content_item_detail "
               select	name, content_type
               from	cr_items 
               where	item_id = :object_id
            "

	    regsub -all { } $content_type {_} content_type_sub
	    regsub -all {:} $content_type_sub {} content_type_sub
	    set object_type_pretty_name [lang::message::lookup "" intranet-core.ContentItem_$content_type_sub $content_type]

	    switch $content_type {
		"content_revision" {
		    # Wiki
		    set read_p [permission::permission_p \
				    -object_id $object_id \
				    -party_id $current_user_id \
				    -privilege "read" ]

		    if {!$read_p} { continue }
		    set name_link "<a href=\"/wiki/$name\">wiki: $name</a>\n"
		} 
		"workflow_case_log_entry" {
		    # Bug-Tracker
		    set bug_number [db_string bug_from_cr_item "
                        select bug_number from bt_bugs,cr_items where item_id=:object_id and cr_items.parent_id=bug_id
                    "]
		    if {!$bug_number} { continue }
		    set name_link "<a href=\"/bug-tracker/bug?bug_number=$bug_number\">bug: $bug_number $name</a>"
		}
		"::xowiki::Page" {
		    set page_name ""
		    set package_mount ""
		    db_0or1row page_info "
			select	s.name as package_mount,
				i.name as page_name
			from	cr_items i,
				apm_packages p,
				site_nodes s, xowiki_pagex d
			where	i.item_id = :object_id and
				p.package_id = s.object_id and
				p.package_key = 'xowiki' and 
				p.package_id = d.object_package_id and 
				i.item_id = d.item_id and
				i.live_revision = d.revision_id
		    "
		    set name_link "<a href=\"/$package_mount/$page_name\">$page_name</a>"
		}
		"::xowiki::FormPage" {
			# Skip FormPage contents
			continue
		}
		default {
		    set name_link [lang::message::lookup "" intranet-search-pg.Unknown_CI_Type "unknown content_item type: %content_type%"]
		}
	    }
	}
    }

    # Render the object.
    # With some objects we want to show more information...
    switch $object_type {
	im_project - im_ticket - im_timesheet_task {
	    set parent_name ""
	    set parent_id ""
	    db_0or1row parent_info "
		select	parents.project_name as parent_name,
			parents.project_id as parent_id
		from	im_projects parents,
			im_projects children
		where	parents.project_id = children.parent_id and
			children.project_id = :object_id
	    "
	    set parent_html "<font>[lang::message::lookup "" intranet-search-pg.Parent "Parent"]: 
	    	<a href=\"[export_vars -base "/intranet/projects/view" {{project_id $parent_id}}]\">$parent_name</a></font><br>\n"
	    if {"" == $parent_name} { set parent_html "" }
	    append result_html "
	      <tr>
		<td>
		  <font>$object_type_pretty_name: $name_link</font><br>
		  $parent_html
		  $headline
		  <br>&nbsp;
		</td>
	      </tr>
	    "
	}
	im_forum_topic {
	    set parent_name ""
	    set parent_id ""
	    db_0or1row parent_info "
		select	acs_object__name(ft.object_id) as parent_name,
			ft.object_id as parent_id,
			(	select	min(url) from im_biz_object_urls 
				where	object_type = (select object_type from acs_objects where object_id = ft.object_id) and 
					url_type = 'view'
			) as parent_url,
			(	select	min(url) from im_biz_object_urls
				where	object_type = :object_type and url_type = 'view'
			) as object_url
		from	im_forum_topics ft
		where	topic_id = :object_id
	    "
	    set parent_html "<font>[lang::message::lookup "" intranet-search-pg.Parent "Parent"]: <a href=\"$parent_url$parent_id\">$parent_name</a></font><br>\n"
	    if {"" == $parent_name} { set parent_html "" }
	    append result_html "
	      <tr>
		<td>
		  <font>$object_type_pretty_name: $name_link</font><br>
		  $parent_html
		  $headline
		  <br>&nbsp;
		</td>
	      </tr>
	    "
	}
        im_invoice {
	    set l10n_key "intranet-cost.[im_cost_type_short_name $object_sub_type_id]"
            append result_html "
              <tr>
                <td>
                  <font>[lang::message::lookup "" intranet-cost.FinancialDocument "Financial Document"]:
		   ([lang::message::lookup "" $l10n_key "[im_cost_type_short_name $object_sub_type_id]"]): $name_link</font><br>
                  $headline
                  <br>&nbsp;
                </td>
              </tr>
            "
	}
	default {
	    set parent_html ""

	    if {"" ne $biz_object_id && "" ne $biz_object_url && $biz_object_id ne $object_id} {
		set biz_object_name_link "<a href='$biz_object_url$biz_object_id'>$biz_object_name</a>"
		set parent_html "[lang::message::lookup "" intranet-search-pg.Parent "Parent"]: $biz_object_type_pretty_name: $biz_object_name_link<br>"
	    }
	    append result_html "
	      <tr>
		<td>
		  $object_type_pretty_name: $name_link<br>
		  $parent_html
		  $headline
		  <br>&nbsp;
		</td>
	      </tr>
	    "
	}
    }
}


set tend [clock clicks -milliseconds]
set elapsed [format "%.02f" [expr {double(abs($tend - $t0)) / 1000.0}]]

set num_results [expr {$offset + $count}]

set from_result_page 1
set current_result_page [expr ($offset / $results_per_page) + 1]
set to_result_page [expr {ceil(double($num_results) / double($results_per_page))}]


set result_page_html ""

for {set i $from_result_page} {$i <= $to_result_page} { incr i } {
    set page_offset [expr ($i-1) * $results_per_page]
    set url [export_vars -base "/intranet-search/search" {q {offset $page_offset}}]
    foreach t $type {
	append url "&type=$t"
    }
    if {$i == $current_result_page} {
	append result_page_html "$i "
    } else {
	append result_page_html "<a href=\"$url\">$i</a> "
    }
}
