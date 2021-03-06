# /admin/general-links/index.tcl
#
# Author: tzumainn@arsdigita.com, 2/01/2000
#
# The idea here is to present the newer links, separated by 
# section, with dimensional controls up top to control
# how much is displayed
#
# Notes: adapted from general-comments
#
# $Id: index.tcl,v 3.1 2000/03/09 00:22:04 tzumainn Exp $
#--------------------------------------------------------

# within each section, we sort by date descending

# the dimensions:
#  time (limit to 1 7 30 days or "all")
#  section ("all" or limit to one section), presented as a select box
#  approval ("all" or "approved only" or "unapproved only" or "unexamined only") 

ad_page_variables {{time_dimension_value 30} {section_dimension_value "all"} {approval_dimension_value "unexamined"} {search_query ""}}

set return_url "[ns_urlencode "index.tcl?[export_ns_set_vars "url"]"]"

set db [ns_db gethandle]

### time widget stuff

if { $time_dimension_value == 1 } {
    lappend time_widget_items "last 24 hrs"
} else {
    lappend time_widget_items "<a href=\"index.tcl?time_dimension_value=1&[export_ns_set_vars "url" [list time_dimension_value]]\">last 24 hrs</a>"
}

if { $time_dimension_value == 7 } {
    lappend time_widget_items "last week"
} else {
    lappend time_widget_items "<a href=\"index.tcl?time_dimension_value=7&[export_ns_set_vars "url" [list time_dimension_value]]\">last week</a>"
}

if { $time_dimension_value == 30 } {
    lappend time_widget_items "last month"
} else {
    lappend time_widget_items "<a href=\"index.tcl?time_dimension_value=30&[export_ns_set_vars "url" [list time_dimension_value]]\">last month</a>"
}

if { $time_dimension_value == "all" } {
    lappend time_widget_items "all"
} else {
    lappend time_widget_items "<a href=\"index.tcl?time_dimension_value=all&[export_ns_set_vars "url" [list time_dimension_value]]\">all</a>"
}


set time_widget [join $time_widget_items " | "]



if { [empty_string_p $search_query] } {
    set where_clause_for_search_query ""
} else {
    set QQsearch_query [DoubleApos $search_query]
    set where_clause_for_search_query " 
    and (upper(meta_keywords) like '%[string toupper $QQsearch_query]%' 
         or upper(meta_description) like '%[string toupper $QQsearch_query]%' 
         or upper(link_description) like '%[string toupper $QQsearch_query]%' 
         or upper(link_title) like '%[string toupper $QQsearch_query]%'
    )"
}

if { $approval_dimension_value == "all" } {
    set approval_widget "all | <a href=\"index.tcl?approval_dimension_value=unexamined_only&[export_ns_set_vars "url" [list approval_dimension_value]]\">unexamined only</a> | <a href=\"index.tcl?approval_dimension_value=approved_only&[export_ns_set_vars "url" [list approval_dimension_value]]\">approved only</a> | <a href=\"index.tcl?approval_dimension_value=unapproved_only&[export_ns_set_vars "url" [list approval_dimension_value]]\">unapproved only</a>"

} elseif { $approval_dimension_value == "approved_only" } {
    # we're currently looking at approved
    set approval_widget "<a href=\"index.tcl?approval_dimension_value=all&[export_ns_set_vars "url" [list approval_dimension_value]]\">all</a> | <a href=\"index.tcl?approval_dimension_value=unexamined_only&[export_ns_set_vars "url" [list approval_dimension_value]]\">unexamined only</a> | approved only | <a href=\"index.tcl?approval_dimension_value=unapproved_only&[export_ns_set_vars "url" [list approval_dimension_value]]\">unapproved only</a>"

} elseif { $approval_dimension_value == "unapproved_only" } {
    # we're currently looking at unapproved
    set approval_widget "<a href=\"index.tcl?approval_dimension_value=all&[export_ns_set_vars "url" [list approval_dimension_value]]\">all</a> | <a href=\"index.tcl?approval_dimension_value=unexamined_only&[export_ns_set_vars "url" [list approval_dimension_value]]\">unexamined only</a> | <a href=\"index.tcl?approval_dimension_value=approved_only&[export_ns_set_vars "url" [list approval_dimension_value]]\">approved only</a> | unapproved only"
} else {
    # we're looking at unexamined
    set approval_widget "<a href=\"index.tcl?approval_dimension_value=all&[export_ns_set_vars "url" [list approval_dimension_value]]\">all</a> | unexamined only | <a href=\"index.tcl?approval_dimension_value=approved_only&[export_ns_set_vars "url" [list approval_dimension_value]]\">approved only</a> | <a href=\"index.tcl?approval_dimension_value=unapproved_only&[export_ns_set_vars "url" [list approval_dimension_value]]\">unapproved only</a>"
}

if { $section_dimension_value == "all" } {
    set start_with_clause "start with parent_category_id is null"

    ad_return_top_of_page "
    [ad_header "General Links Administration"]
    
    <h2>General Links Administration</h2>
    
    [ad_admin_context_bar "General Links Administration"]
    
    <hr>
    "

} else {
    set category_select_name [database_to_tcl_string_or_null $db "select category from categories where category_id = '$section_dimension_value'"]
 
    set start_with_clause "start with child_category_id = $section_dimension_value"

    ad_return_top_of_page "
    [ad_header "$category_select_name"]
    
    <h2>$category_select_name</h2>
    
    [ad_admin_context_bar [list "" "General Links Administration"] $category_select_name]
    
    <hr>
    "

}

ns_write "
<p>

<table width=100%>

<tr>
<td colspan=3><form method=post action=\"index.tcl\">Search for a link: <input type=text size=20 name=search_query value=\"$search_query\"><input type=submit value=\"Search\">
[export_form_vars time_dimension_value section_dimension_value approval_dimension_value]
</form></td>
</tr>

<tr>
<th bgcolor=#ECECEC>Approval Status</th>
<th bgcolor=#ECECEC>Creation Time</th>
</tr>

<tr>
<td align=center valign=top>$approval_widget
<td align=center valign=top>$time_widget
</tr>

</table>
<hr>
<center><a href=\"check-all-links.tcl\">check all links</a></center>
<p>
"

if { $approval_dimension_value == "all" } {
    set where_clause_for_approval ""
} elseif { $approval_dimension_value == "approved_only" } {
    set where_clause_for_approval "and gl.approved_p = 't'"
} elseif { $approval_dimension_value == "unapproved_only" } {
    set where_clause_for_approval "and gl.approved_p = 'f'"
} else {
   set where_clause_for_approval "and gl.approved_p is NULL"
}

if { $time_dimension_value == "all" } {
    set where_clause_for_time ""
} else {
    set where_clause_for_time "and gl.creation_time > sysdate - $time_dimension_value"
}

set selection [ns_db select $db "select c.category_id, ch.tree_level - 1 as indent, c.category, c.category_type, link_id, gl.url, link_title, gl.creation_time, gl.last_approval_change, gl.approved_p, u.first_names, u.last_name
from categories c, general_links gl, users u,
(select child_category_id, rownum as tree_rownum, level as tree_level
from category_hierarchy
$start_with_clause
connect by prior child_category_id = parent_category_id) ch
where c.category_id = ch.child_category_id
and exists (select 1 from site_wide_category_map swm
            where gl.link_id = swm.on_what_id
            and swm.on_which_table = 'general_links'
            and swm.category_id = c.category_id)
and u.user_id(+) = gl.approval_change_by
$where_clause_for_approval
$where_clause_for_time
$where_clause_for_search_query
order by ch.tree_rownum, link_title"]

set current_category_name ""
set current_indent 0
set n_links 0
set the_links "<ul>"

while {[ns_db getrow $db $selection]} {

    set_variables_after_query
    incr n_links

    set category_name $category
    if {![empty_string_p $category_type]} {
	append category_name " ($category_type)"
    }

    if { $current_category_name != $category_name } {
	if {![empty_string_p $current_category_name]} {
	    append the_links "</ul>"
	    for {set i 1} {$i <= $current_indent} {incr i} {
		append the_links "\n</ul>"
	    }
	}
	set current_category_name $category_name
	set current_indent $indent

	for {set i 1} {$i <= $current_indent} {incr i} {
	    append the_links "\n<ul>"
	}

	append the_links "<li><a href=\"index.tcl?section_dimension_value=$category_id&time_dimension_value=$time_dimension_value&approval_dimension_value=$approval_dimension_value&search_query=[ns_urlencode $search_query]\"><b>$current_category_name</b></a>\n<ul>"
    }

    append the_links "<li>
    <a href=\"$url\"><b>$link_title</b></a> ($url)<br>Posted on [util_AnsiDatetoPrettyDate $creation_time]; "

    if {![empty_string_p $last_name]} { 
	set approval_user " by $first_names $last_name"
    } else {
	set approval_user ""
    }

    if { $approved_p == "f" } {
	append the_links "
	Rejected on [util_AnsiDatetoPrettyDate $last_approval_change]$approval_user
	<br>
	<a href=\"toggle-link-approved-p.tcl?link_id=$link_id&approved_p=t&return_url=$return_url\">approve</a> | \n"
    } elseif { $approved_p == "t" } {
	append the_links "
	Approved on [util_AnsiDatetoPrettyDate $last_approval_change]$approval_user
	<br>
	<a href=\"toggle-link-approved-p.tcl?link_id=$link_id&approved_p=f&return_url=$return_url\">reject</a> | \n"
    } else {
	append the_links "
	<br>
	<a href=\"toggle-link-approved-p.tcl?link_id=$link_id&approved_p=t&return_url=$return_url\">approve</a> | <a href=\"toggle-link-approved-p.tcl?link_id=$link_id&approved_p=f&return_url=$return_url\">reject</a> | \n"
    }

    append the_links "
    <a href=\"approve-all.tcl?link_id=$link_id\">approve link plus mappings</a>
    |
    <a href=\"view-associations.tcl?link_id=$link_id\">view associations</a>
    |
    <a href=\"edit-link.tcl?link_id=$link_id\">edit</a>
    |
    <a href=\"check-one-link.tcl?link_id=$link_id\">check</a>
    |
    <a href=\"delete-link.tcl?link_id=$link_id\">delete</a>
    \n
    "
}

### wrap up last ul/blockquote
if { $n_links > 0 } {
    append the_links "</ul>"
}

for {set i 1} {$i <= $current_indent} {incr i} {
    append the_links "\n</ul>"
}

### deal with uncategorized links - maybe
set uncategorized_link_list ""
if { $section_dimension_value == "all" } {
    
    set n_uncategorized 0
    set selection [ns_db select $db "select link_id, gl.url, link_title, gl.creation_time, gl.last_approval_change, gl.approved_p, u.first_names, u.last_name
    from general_links gl, users u
    where not exists (select 1 from site_wide_category_map swm
                     where gl.link_id = swm.on_what_id
                     and swm.on_which_table = 'general_links')
    and u.user_id(+) = gl.approval_change_by
    $where_clause_for_approval
    $where_clause_for_time
    $where_clause_for_search_query
    "]
    
    while {[ns_db getrow $db $selection]} {
	set_variables_after_query

	incr n_links
	incr n_uncategorized

	append uncategorized_link_list "<li>
	<a href=\"$url\"><b>$link_title</b></a> ($url)<br>Posted on [util_AnsiDatetoPrettyDate $creation_time]; "

	if {![empty_string_p $last_name]} { 
	    set approval_user " by $first_names $last_name"
	} else {
	    set approval_user ""
	}
	
	if { $approved_p == "f" } {
	    append uncategorized_link_list "
	    Rejected on [util_AnsiDatetoPrettyDate $last_approval_change]$approval_user
	    <br>
	    <a href=\"toggle-link-approved-p.tcl?link_id=$link_id&approved_p=t&return_url=$return_url\">approve</a> | \n"
	} elseif { $approved_p == "t" } {
	    append uncategorized_link_list "
	    Approved on [util_AnsiDatetoPrettyDate $last_approval_change]$approval_user
	    <br>
	    <a href=\"toggle-link-approved-p.tcl?link_id=$link_id&approved_p=f&return_url=$return_url\">reject</a> | \n"
	} else {
	    append uncategorized_link_list "
	    <br>
	    <a href=\"toggle-link-approved-p.tcl?link_id=$link_id&approved_p=t&return_url=$return_url\">approve</a> | <a href=\"toggle-link-approved-p.tcl?link_id=$link_id&approved_p=f&return_url=$return_url\">reject</a> | \n"
	}
	
	append uncategorized_link_list "
	<a href=\"approve-all.tcl?link_id=$link_id\">approve link plus mappings</a>
	|
	<a href=\"view-associations.tcl?link_id=$link_id\">view associations</a>
	|
	<a href=\"edit-link.tcl?link_id=$link_id\">edit</a>
	|
	<a href=\"check-one-link.tcl?link_id=$link_id\">check</a>
	|
	<a href=\"delete-link.tcl?link_id=$link_id\">delete</a>\n
	"
    }
    
    if { $n_uncategorized != 0 } {
	set uncategorized_link_list "<li><b>Uncategorized Links</b><ul>$uncategorized_link_list</ul>"
    }
}

if { $n_links == 0 } {
    append the_links "<li>No links available."
}

ns_db releasehandle $db

append the_links $uncategorized_link_list

append the_links "</ul>"

if { $n_links == 0 } {
    ns_write "Sorry, there aren't any links in this ACS installation that fit your criteria"
} else {
    ns_write $the_links
}

ns_write [ad_admin_footer]


