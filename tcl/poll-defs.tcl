# $Id: poll-defs.tcl,v 3.0 2000/02/06 03:13:53 ron Exp $
# poll-defs.tcl -- definitions for the opinion polling module

# by markd@arsdigita.com, September 1999

util_report_library_entry



# returns a list of info about the poll:
#   name, description, start_date, end_date, require_registration_p, active_p
# handy for memoization.

proc poll_info_internal { poll_id } {

    set db [ns_db gethandle subquery]

    set info [database_1row_to_tcl_list $db "
select name, description, start_date, end_date, require_registration_p,
       poll_is_active_p(start_date, end_date) as active_p
  from polls
 where poll_id = $poll_id
"]

    ns_db releasehandle $db

    return $info

} ;# poll_info_internal




# returns a list of poll labels:
#   label 1, choice id 1, label 2, choice id 2
# handy for memoization, and handy for passing the result to poll_display

proc poll_labels_internal { poll_id } {
    set db [ns_db gethandle subquery]

    set selection [ns_db select $db "
select choice_id, label
  from poll_choices
 where poll_id = $poll_id
 order by sort_order
"]

    set choices [list]

    while { [ns_db getrow $db $selection] } {
	set_variables_after_query
	lappend choices $label
	lappend choices $choice_id
    }

    ns_db releasehandle $db

    return $choices

} ;# poll_labels_internal



# display the polls on the front page.
# the 'polls' argument should be a tcl list of the form
# poll-link req_registration_p poll-link req_registration_p ...

ad_proc poll_front_page { { -item_start "<li>" -item_end "" -style_start "" -style_end "" -require_registration_start "" -require_registration_end "" -require_registration_text "(registration required)" -no_polls "There are no currently active polls" } polls } "" {

    set result ""

    set user_id [ad_get_user_id]

    set length [llength $polls]

    if { $length == 0 } {
	append result "$item_start $no_polls"
    }

    for { set i 0 } { $i < $length } { incr i 2 } {
	set item [lindex $polls $i]
	set require_registration_p [lindex $polls [expr $i + 1]]

	append result "$item_start $style_start $item $style_end $item_end"

	if { $require_registration_p == "t" && $user_id == 0 } {
	    # this poll requires registration and the user isn't logged in
	    append result "$require_registration_start $require_registration_text $require_registration_end"
	}
	append result "\n"
    }

    return $result

} ;# poll_front_page



# choices is a list of the form
#   choice_label choice_id choice_label choice_id ...

ad_proc poll_display { { -item_start "<br>" -item_end "" -style_start "" -style_end "" -no_choices "No Choices Specified" } choices } "" {

    set result ""

    set length [llength $choices]

    if { $length == 0 } {
	append result "$item_start $no_choices"
    }

    for { set i 0 } { $i < $length } { incr i 2 } {
	set label [lindex $choices $i]
	set choice_id [lindex $choices [expr $i + 1]]

	append result "$item_start <input type=radio name=choice_id value=$choice_id> $style_start $label $style_end $item_end\n"
    }

    return $result

} ;# poll_display



ad_proc poll_results { { -bar_color "blue" -display_values_p "t" -display_scale_p "t" -bar_height "15" } results } "" {

    if { [llength $results] != 0 } {

	set result [gr_sideways_bar_chart -bar_color_list [list $bar_color] -display_values_p $display_values_p -display_scale_p $display_scale_p -bar_height $bar_height $results]

    } else {
	set result ""
    }

    return $result

} ;# poll_results


##################################################################
#
# interface to the ad-user-contributions-summary.tcl system

ns_share ad_user_contributions_summary_proc_list

if { ![info exists ad_user_contributions_summary_proc_list] || [util_search_list_of_lists $ad_user_contributions_summary_proc_list "Poll Choices" 0] == -1 } {
    lappend ad_user_contributions_summary_proc_list [list "Poll Choices" poll_user_contributions 0]
}

proc_doc poll_user_contributions {db user_id purpose} {Returns list items, one for each answer; returns empty list for non-site-admin.} {
    if { $purpose != "site_admin" } {
	return [list]
    }
    set selection [ns_db select $db "select 
  polls.poll_id, 
  polls.name as poll_name,
  pc.label as choice_name,
  puc.choice_date
from polls, poll_choices pc, poll_user_choices puc
where puc.user_id = $user_id
and puc.choice_id = pc.choice_id
and puc.poll_id = polls.poll_id
order by choice_date asc"]

    set items ""
    while { [ns_db getrow $db $selection] } {
	set_variables_after_query
	append items "<li>[util_AnsiDatetoPrettyDate $choice_date]: <a href=\"/admin/poll/one-poll.tcl?[export_url_vars poll_id]\">$poll_name</a>; $choice_name\n"
    }
    if [empty_string_p $items] {
	return [list]
    } else {
	return [list 0 "Poll Choices" "<ul>\n\n$items\n\n</ul>"]
    }
}


util_report_successful_library_load

