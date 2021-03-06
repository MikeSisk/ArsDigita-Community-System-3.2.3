# $Id: q-and-a.tcl,v 3.1 2000/02/23 01:49:39 bdolicki Exp $
# q-and-a.tcl
#
# philg@arsdigita.com
# hqm@arsdigita.com
# 
# top-level page for displaying a forum in Q&A format
#

set_the_usual_form_variables

# form vars:
# topic_id, topic

set db [bboard_db_gethandle]
if { $db == "" } {
    bboard_return_error_page
    return
}

if { [bboard_get_topic_info] == -1 } {
    return
}


set menubar_options [list]

set user_id [ad_verify_and_get_user_id]

# see if the user is an admin for any of the groups this topic belongs to
if {[bboard_user_is_admin_for_topic $db $user_id $topic_id]} {
    set administrator_p 1     
} else {
    set administrator_p 0    
}

if $administrator_p {
    lappend menubar_options "<a href=\"admin-home.tcl?[export_url_vars topic_id topic]\">Administer</a>"
}

if { $users_can_initiate_threads_p != "f" } {
    lappend menubar_options "<a href=\"q-and-a-post-new.tcl?[export_url_vars topic_id topic]\">Ask a Question</a>"
}

if { [bboard_pls_blade_installed_p] } {
    lappend menubar_options "<a href=\"q-and-a-search-form.tcl?[export_url_vars topic_id topic]\">Search</a>"
}

lappend menubar_options "<a href=\"q-and-a-unanswered.tcl?[export_url_vars topic_id topic]\">Unanswered Questions</a>"

lappend menubar_options "<a href=\"q-and-a-new-answers.tcl?[export_url_vars topic_id topic]\">New Answers</a>"

if { ![empty_string_p $policy_statement] } {
    lappend menubar_options "<a href=\"policy.tcl?[export_url_vars topic_id topic]\">About</a>"
}



append whole_page "[bboard_header "$topic Top Level"]

<h2>$topic</h2>

[ad_context_bar_ws_or_index [list "index.tcl" [bboard_system_name]] $topic]

<hr>

\[ [join $menubar_options " | "] \]

"

if { $q_and_a_categorized_p == "t" && (![info exists category_centric_p] || $category_centric_p == "f")} {
    append whole_page "

<h3>New Questions</h3>


<ul>

"
} else {
    append whole_page "

<ul>

"
}

# this is not currently used, moderation should be turned on with certain
# moderation_policies in case we add more


set approved_clause ""
if { $q_and_a_categorized_p == "t" } {
    set sql "select urgent_p, msg_id, one_line, sort_key, posting_time, email, first_names || ' ' || last_name as name, users.user_id as poster_id
from bboard, users 
where topic_id = $topic_id $approved_clause
and bboard.user_id = users.user_id 
and refers_to is null
and posting_time > (sysdate - $q_and_a_new_days)
order by sort_key $q_and_a_sort_order"
} elseif { [info exists custom_sort_key_p] && $custom_sort_key_p == "t" } {
    set sql "select urgent_p, msg_id, one_line, sort_key, posting_time, email, first_names || ' ' || last_name as name, custom_sort_key, custom_sort_key_pretty, users.user_id as poster_id
from bboard, users
where topic_id = $topic_id $approved_clause
and refers_to is null
and bboard.user_id = users.user_id 
order by custom_sort_key $custom_sort_order" } else {
    set sql "select urgent_p, msg_id, one_line, sort_key, posting_time, email, first_names || ' ' || last_name as name, users.user_id as poster_id
from bboard, users
where topic_id = $topic_id $approved_clause
and bboard.user_id = users.user_id
and refers_to is null
order by sort_key $q_and_a_sort_order
"
}


if { ![info exists category_centric_p] || $category_centric_p == "f" } {
    # we're not only doing categories
    set selection [ns_db select $db $sql]

    while {[ns_db getrow $db $selection]} {
	set_variables_after_query
	if { [info exists custom_sort_key_p] && $custom_sort_key_p == "t" } {
	    if { $custom_sort_key_pretty != "" } {
		set prefix "${custom_sort_key_pretty}: "
	    } elseif { $custom_sort_key != "" } {
		set prefix "${custom_sort_key}: "
	    } else {
		set prefix ""
	    }
	    append whole_page "<li>${prefix}<a href=\"[bboard_msg_url $presentation_type $msg_id $topic_id $topic]\">$one_line</a> [bboard_one_line_suffix $selection $subject_line_suffix]\n"
	} else {
	    append whole_page "<li><a href=\"[bboard_msg_url $presentation_type $msg_id $topic_id $topic]\">$one_line</a> [bboard_one_line_suffix $selection $subject_line_suffix]\n"
	}

    }
}

append whole_page "

</ul>

"

if { $q_and_a_categorized_p == "t" } {
    if { $q_and_a_show_cats_only_p == "t" } {
	append whole_page "<h3>Older Messages (by category)</h3>\n\n<ul>\n"
 	# this is a safe operation because $topic has already been verified to exist
 	# in the database (i.e., it won't contain anything naughty for the eval in memoize)
	append whole_page [util_memoize "bboard_compute_categories_with_count $topic_id" 300]
	append whole_page "<P>
<li><a href=\"q-and-a-one-category.tcl?[export_url_vars topic_id topic]&category=uncategorized\">Uncategorized</a>
</ul>"
     } elseif { [info exists category_centric_p] && $category_centric_p == "t" } {
	 # this is for 6.001 forums where every message must be under
	 # a category
	 set sql "select category from
bboard_q_and_a_categories
where topic_id = $topic_id
order by 1"
         set selection [ns_db select $db $sql]
         set counter 0
         append whole_page "<ul>"
         while {[ns_db getrow $db $selection]} {
	     set_variables_after_query
             incr counter
	     append whole_page "<li><a href=\"cc.tcl?[export_url_vars topic_id topic]&key=[ns_urlencode $category]\">$category</a>\n"
	 }
         if { $counter == 0 } {
	     append whole_page "nobody is using this forum yet"
         }
         append whole_page "</ul>"
     } else {
    # we now have to present the older messages
    # (if uncategorized, the query above was enough to get everything)
    if { $q_and_a_use_interest_level_p == "t" } {
	set interest_clause "and (interest_level is NULL or interest_level >= [bboard_interest_level_threshold])\n"
    } else {
	# not restricting by interest level
	set interest_clause ""
    }
    set sql "select msg_id, one_line, sort_key, posting_time, email, first_names || ' ' || last_name as name, category, decode(category,null,'t','','t','f') as uncategorized_p, users.user_id as poster_id  
from bboard, users 
where topic_id = $topic_id
and bboard.user_id = users.user_id
and refers_to is null
$interest_clause
and posting_time <= (sysdate - $q_and_a_new_days)
order by uncategorized_p, category, sort_key $q_and_a_sort_order"
    set selection [ns_db select $db $sql]

    set last_category "there ain't no stinkin' category with this name"
    set first_category_flag 1

    while {[ns_db getrow $db $selection]} {
	set_variables_after_query
	if { $category != $last_category } {
	    set last_category $category
	    if { $first_category_flag != 1 } {
		# we have to close out a <ul>
		append whole_page "\n</ul>\n"
	    } else {
		set first_category_flag 0
	    }
	    if { $category == "" } {
		set pretty_category "Uncategorized"
	    } else {
		set pretty_category $category
	    }
	    append whole_page "<h3>$pretty_category</h3>

<ul>
"
       }

       append whole_page "<li><a href=\"[bboard_msg_url $presentation_type $msg_id $topic_id $topic]\">$one_line</a> [bboard_one_line_suffix $selection $subject_line_suffix]\n"
}

# let's assume there was at least one section

append whole_page "\n</ul>\n"

}
# done showing the extra stuff for categorized bboard
}

if { [bboard_pls_blade_installed_p] } {

    set search_submit_button ""
    if { [msie_p] == 1 } {
	set search_submit_button "<input type=submit value=\"Submit Query\">"
    }

    set search_server [ad_parameter BounceQueriesTo site-wide-search ""]

    append whole_page "<form method=GET action=\"$search_server/bboard/q-and-a-search.tcl\" target=\"_top\">
<input type=hidden name=topic value=\"$topic\">
<input type=hidden name=topic_id value=\"$topic_id\">
Full Text Search:  <input type=text name=query_string size=40>
$search_submit_button
</form>"

#     if { $q_and_a_use_interest_level_p == "t" && $q_and_a_show_cats_only_p == "f" } {
# 	append whole_page "Note: the full-text search engine looks through more messages than you see above.  Old postings that have been deemed \"not of general interest\" are not presented above, but they are available to the full text search engine.  If you want to see what you're missing, you can get
# <a href=\"q-and-a-uninteresting.tcl?[export_url_vars topic topic_id]\">a whole page of uninteresting postings</a>.
# <p>
# "
#     }

}

append whole_page "

This forum is maintained by <a href=\"/shared/community-member.tcl?user_id=$primary_maintainer_id\">$maintainer_name</a>.  
You can get a summary of the forum's age and content from
<a href=\"statistics.tcl?[export_url_vars topic topic_id]\">the statistics page</a>.

<p>

If you want to follow this discussion by email, 
<a href=\"add-alert.tcl?[export_url_vars topic topic_id]\">
click here to add an alert</a>.


[bboard_footer]
"

ns_db releasehandle $db 

ns_return 200 text/html $whole_page
