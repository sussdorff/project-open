# /packages/intranet-search-pg/tcl/intranet-search-pg-procs.tcl
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

ad_library {
    Procedures for tsearch full text enginge driver

    @author Dave Bauer (dave@thedesignexperience.org)
    @author frank.bergmann@project-open.com
    @creation-date 2004-06-05
    @arch-tag: 49a5102d-7c06-4245-8b8d-15a3b12a8cc5
    @cvs-id $Id: intranet-search-pg-procs.tcl,v 1.8 2016/02/15 16:42:20 cvs Exp $

}


ad_proc -public im_package_search_id { } {
    Returns the ID of the current package. Please
    not that there is no "_pg" in the procedure name.
    This is in order to keep the rest of the system
    identical, no matter whether it's a PostgreSQL
    TSearch2 implementation of search or an Oracle
    Intermedia implementation.
} {
    return [db_string im_package_search_id {
        select package_id from apm_packages
        where package_key = 'intranet-search-pg'
    } -default 0]
}


ad_proc -public im_tsvector_to_headline { 
    tsvector
} {
    Converts a tsvector (or better: its string representation)
    into a text string, obviously without the stop words.

    Example: 'frank':3 'bergmann':4 'www.project-open.com':2
          => "www.project-open.com frank bergmann"

    @author Frank Bergmann (frank.bergmann@project-open.com)
    @creation-date 2005-01-05
} {
    set word ""
    set counters ""
    set result ""
    set ts_list [split $tsvector "'"]

    set ctr 0
    set maxpos 0
    foreach token $ts_list {
	set token [string trim $token]

	if {1 == [expr {$ctr % 2}]} {
	    set word $token
	} else {
	    set token [string range $token 1 end]
	    set positions [split $token ","]

	    foreach pos $positions {
		set res($pos) $word
		
		if {$pos > $maxpos} { set maxpos $pos }
	    }
	}
	incr ctr
    }

    set last_i 0
    for {set i 0} {$i <= $maxpos} {incr i} {
	if {[info exists res($i)]} {
	    append result $res($i)
	    append result " "
	    set last_id $i
	}
	if {1 == [expr {$i - $last_i}]} {
	    append result ".. "
	}
    }

    return $result
}


namespace eval tsearch2 {}

ad_proc -public tsearch2::search {
    query
    offset
    limit
    user_id
    df
    dt
} {
    
    ftsenginedriver search operation implementation for tsearch2
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-06-05

    @param query

    @param offset

    @param limit

    @param user_id

    @param df

    @param dt

    @return

    @error
} {
    # clean up query
    # turn and into &
    # turn or into |
    # turn not into !
    set query [tsearch2::build_query -query $query]

    set limit_clause ""
    set offset_clause ""

    if {[string is integer $limit]} {
	set limit_clause " limit :limit "
    }
    if {[string is integer $offset]} {
	set offset_clause " offset :offset "
    }
    set query_text "select object_id from txt where fti @@ to_tsquery('default',:query) and exists (select 1
                   from acs_object_party_privilege_map m
                   where m.object_id = txt.object_id
                     and m.party_id = :user_id
                     and m.privilege = 'read') order by ts_rank(fti,to_tsquery('default',:query)) desc  ${limit_clause} ${offset_clause}"
    set results_ids [db_list search $query_text]
    set count [db_string count "select count(*) from txt where fti @@ to_tsquery('default',:query)  and exists
                  (select 1 from acs_object_party_privilege_map m
                   where m.object_id = txt.object_id
                     and m.party_id = :user_id
                     and m.privilege = 'read')"]
    set stop_words [list]
    # lovely the search package requires count to be returned but the
    # service contract definition doesn't specify it!
    return [list ids $results_ids stopwords $stop_words count $count]
}




