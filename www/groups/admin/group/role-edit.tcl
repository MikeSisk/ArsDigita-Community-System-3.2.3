# $Id: role-edit.tcl,v 3.0 2000/02/06 03:46:07 ron Exp $
# File:    /groups/admin/group/role-edit.tcl
# Date:    mid-1998
# Contact: tarik@arsdigita.com
# Purpose: edit the role for the user
#
# Note: group_id and group_vars_set are already set up in the environment by the ug_serve_section.
#       group_vars_set contains group related variables (group_id, group_name, group_short_name,
#       group_admin_email, group_public_url, group_admin_url, group_public_root_url, group_admin_root_url, 
#       group_type_url_p, group_context_bar_list and group_navbar_list)

set_the_usual_form_variables
# user_id

set group_name [ns_set get $group_vars_set group_name]
set group_admin_url [ns_set get $group_vars_set group_admin_url]

set db [ns_db gethandle]

if { [ad_user_group_authorized_admin [ad_verify_and_get_user_id] $group_id $db] != 1 } {
    ad_return_error "Not Authorized" "You are not authorized to see this page"
    return
}

set selection [ns_db 1row  $db "
select first_names || ' ' || last_name as name, role, 
       multi_role_p, group_type
from users, user_group_map, user_groups 
where users.user_id = $user_id
and user_group_map.user_id = users.user_id
and user_groups.group_id = user_group_map.group_id
and user_groups.group_id = $group_id"]
set_variables_after_query

ReturnHeaders 

ns_write "
[ad_scope_admin_header "Edit role for $name" $db]
[ad_scope_admin_page_title "Edit role for $name" $db]
[ad_scope_admin_context_bar "Edit Role"]
<hr>
"

append html "
<form method=get action=\"role-edit-2.tcl\">
[export_form_vars user_id]

<table>
<tr>
<td>Set Role
</td><td>
"

# TODO!!!! Have to switch over from STS
# The following is a special case for sts; hospitals have predefined roles

if { [string compare $multi_role_p "t"] == 0 } {
    # all groups must have an administrator role
    set existing_roles [database_to_tcl_list $db "select role from user_group_roles where group_id = $group_id"]
    if {[lsearch $existing_roles "administrator"] == -1 } {
	lappend existing_roles "administrator"
    }
    if { [llength $existing_roles] > 0 } {
	append html "
	<select name=existing_role>
	[ad_generic_optionlist $existing_roles $existing_roles $role]
	</select>
	"
    }
    append html "</tr>"
} else {
    set existing_roles [database_to_tcl_list $db "select distinct role from user_group_map where group_id = $group_id"]
    if {[lsearch $existing_roles "administrator"] == -1 } {
	lappend existing_roles "administrator"
    }
    if {[lsearch $existing_roles "all"] == -1 } {
	lappend existing_roles "all"
    }

    if { [llength $existing_roles] > 0 } {
	append html "
	<select name=existing_role>
	<option value=\"\">choose an existing role
	[ad_generic_optionlist $existing_roles $existing_roles $role]
	</select>
	<tr><td colspan=2 align=center>or</tr>
	<tr>
	<td>
	Define a new role for this group:
	<td>
	<input type=text name=new_role size=30>
	</tr>
	"
    }
}


append html "
</table>
<center>
<input type=submit value=\"Proceed\">
</center>
</form>
"

ns_write "
$html
[ad_scope_admin_footer]
"







