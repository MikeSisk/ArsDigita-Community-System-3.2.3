# $Id: js-message-chat-rows.tcl,v 3.0 2000/02/06 03:36:42 ron Exp $
# File:     /chat/js-message-chat-rows.tcl
# Date:     1998-11-18
# Contact:  aure@arsdigita.com,philg@mit.edu, ahmeds@arsdigita.com

# Note: if page is accessed through /groups pages then group_id and group_vars_set 
#       are already set up in the environment by the ug_serve_section. group_vars_set 
#       contains group related variables (group_id, group_name, group_short_name, 
#       group_admin_email, group_public_url, group_admin_url, group_public_root_url,
#       group_admin_root_url, group_type_url_p, group_context_bar_list and group_navbar_list)

set_the_usual_form_variables

# chatter_id
# maybe scope, maybe scope related variables (owner_id, group_id, on_which_group, on_what_id)
# note that owner_id is the user_id of the user who owns this module (when scope=user)

ad_scope_error_check

set db [ns_db gethandle]
ad_scope_authorize $db $scope registered group_member none
ns_db releasehandle $db

ReturnHeaders

set time_user_id [chat_last_personal_post $chatter_id]
set last_time [lindex $time_user_id 0]
set last_poster [lindex $time_user_id 1]

set html "
<script>
var last_time='$last_time';
var last_poster='$last_poster';
</script>
<body bgcolor=white>
"

if {[ad_parameter MostRecentOnTopP chat]} {
    append html "
    <a name=most_recent></a>
    "
}

append html "
[chat_get_personal_posts $chatter_id]
"

if {![ad_parameter MostRecentOnTopP chat]} {
    append html "
    <a name=most_recent></a>
    "
}
ns_write $html


