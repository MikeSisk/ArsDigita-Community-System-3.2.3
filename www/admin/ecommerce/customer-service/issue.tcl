# $Id: issue.tcl,v 3.0.4.1 2000/04/28 15:08:40 carsten Exp $
set_the_usual_form_variables
# issue_id

set return_url "[ns_conn url]?[export_entire_form_as_url_vars]"

set customer_service_rep [ad_get_user_id]

if {$customer_service_rep == 0} {
    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    return
}

ReturnHeaders

set page_title "Issue #$issue_id"
ns_write "[ad_admin_header $page_title]
<h2>$page_title</h2>

[ad_admin_context_bar [list "../index.tcl" "Ecommerce"] [list "index.tcl" "Customer Service Administration"] $page_title]

<hr>
"

set db [ns_db gethandle]

set selection [ns_db 1row $db "select i.user_identification_id, i.order_id, i.closed_by, i.deleted_p, i.open_date, i.close_date, to_char(i.open_date,'YYYY-MM-DD HH24:MI:SS') as full_open_date, to_char(i.close_date,'YYYY-MM-DD HH24:MI:SS') as full_close_date, u.first_names || ' ' || u.last_name as closed_rep_name
from ec_customer_service_issues i, users u
where i.closed_by=u.user_id(+)
and issue_id=$issue_id"]

set_variables_after_query

if { [empty_string_p $close_date] } {
    set open_close_link "<a href=\"issue-open-or-close.tcl?close_p=t&[export_url_vars issue_id]\">close</a>"
} else {
    set open_close_link "<a href=\"issue-open-or-close.tcl?close_p=f&[export_url_vars issue_id]\">reopen</a>"
}

ns_write "
\[ <a href=\"issue-edit.tcl?[export_url_vars issue_id]\">edit</a> | $open_close_link | <a href=\"email-send.tcl?[export_url_vars issue_id user_identification_id]\">send email</a> | <a href=\"interaction-add.tcl?[export_url_vars issue_id user_identification_id]\">record an interaction</a> \]

<p>

<blockquote>
<table>
<tr>
<td align=right><b>Customer</td>
<td>[ec_user_identification_summary $db $user_identification_id]</td>
</tr>
"

if { ![empty_string_p $order_id] } {
    ns_write "<tr>
    <td align=right><b>Order #</td>
    <td><a href=\"../orders/one.tcl?order_id=$order_id\">$order_id</a></td>
    </tr>
    "
}

set issue_type_list [database_to_tcl_list $db "select issue_type from ec_cs_issue_type_map where issue_id=$issue_id"]
set issue_type [join $issue_type_list ", "]

if { ![empty_string_p $issue_type] } {
    ns_write "<tr>
    <td align=right><b>Issue Type</td>
    <td>$issue_type</td>
    </tr>
    "
}


ns_write "<tr>
<td align=right><b>Open Date</td>
<td>[util_AnsiDatetoPrettyDate [lindex [split $full_open_date " "] 0]] [lindex [split $full_open_date " "] 1]</td>
</tr>
"

if { ![empty_string_p $close_date] } {
    ns_write "<tr>
    <td align=right><b>Close Date</td>
    <td>[util_AnsiDatetoPrettyDate [lindex [split $full_close_date " "] 0]] [lindex [split $full_close_date " "] 1]</td>
    </tr>
    <tr>
    <td align=right><b>Closed By</td>
    <td><a href=\"/admin/users/one.tcl?user_id=$closed_by\">$closed_rep_name</a></td>
    </tr>
    "
}

ns_write "
</table>
</blockquote>

<p>

<h3>All actions associated with this issue</h3>
<center>
"

set selection [ns_db select $db "select a.action_id, a.interaction_id, a.action_details, a.follow_up_required, i.customer_service_rep, i.interaction_date, to_char(i.interaction_date,'YYYY-MM-DD HH24:MI:SS') as full_interaction_date, i.interaction_originator, i.interaction_type, m.info_used
from ec_customer_service_actions a, ec_customer_serv_interactions i, ec_cs_action_info_used_map m
where a.interaction_id=i.interaction_id
and a.action_id=m.action_id(+)
and a.issue_id=$issue_id
order by a.action_id desc"]


set old_action_id ""
set info_used_list [list]
set action_counter 0
while { [ns_db getrow $db $selection] } {
    incr action_counter
    set_variables_after_query
    if { [string compare $action_id $old_action_id] != 0 } {
	if { [llength $info_used_list] > 0 } {
	    ns_write "<td>[join $info_used_list "<br>"]</td>"
	    set info_used_list [list]
	} else {
	    ns_write "<td>&nbsp;</td>"
	}


	if { ![empty_string_p $old_action_id] } {
	    ns_write "<td><a href=\"interaction.tcl?interaction_id=$old_interaction_id\">$old_interaction_id</a></tr>
	    <tr><td colspan=6><b>Details:</b><br><blockquote>[ec_display_as_html $old_action_details]</blockquote></td></tr>
	    "
	    if { ![empty_string_p $old_follow_up_required] } {
		ns_write "<tr><td colspan=6><b>Follow-up Required:</b><br><blockquote>[ec_display_as_html $old_follow_up_required]</blockquote></td></tr>"
	    }
	    ns_write "</table>
	    <p>
	    "
	}
	ns_write "<table width=90%>
	<tr bgcolor=\"ececec\"><th>Date</th><th>Rep</th><th>Originator</th><th>Inquired Via</th><th>Info Used</th><th>Interaction</th></tr>
	<tr bgcolor=\"ececec\"><td>[util_AnsiDatetoPrettyDate [lindex [split $full_interaction_date " "] 0]] [lindex [split $full_interaction_date " "] 1]</td><td>[ec_decode $customer_service_rep "" "&nbsp;" "<a href=\"/admin/users/one.tcl?user_id=$customer_service_rep\">$customer_service_rep</a>"]</td><td>$interaction_originator</td><td>$interaction_type</td>
	"
    }

    if { ![empty_string_p $info_used] } {
	lappend info_used_list $info_used
    }
    set old_action_id $action_id
    set old_interaction_id $interaction_id
    set old_action_details $action_details
    set old_follow_up_required $follow_up_required
}

if { [llength $info_used_list] > 0 } {
    ns_write "<td>[join $info_used_list "<br>"]</td>"
    set info_used_list [list]
} else {
    ns_write "<td>&nbsp;</td>"
}
if { ![empty_string_p $old_action_id] } {
    ns_write "<td><a href=\"interaction.tcl?interaction_id=$interaction_id\">$interaction_id</a></tr>
    <tr><td colspan=6><b>Details:</b><br><blockquote>[ec_display_as_html $action_details]</blockquote></td></tr>
    "
    if { ![empty_string_p $follow_up_required] } {
	ns_write "<tr><td colspan=6><b>Follow-up Required:</b><br><blockquote>[ec_display_as_html $follow_up_required]</blockquote></td></tr>
	"
    }
    ns_write "</table>
	    "
}

ns_write "</center>
[ad_admin_footer]
"