# $Id: delete-room-2.tcl,v 3.0.4.1 2000/04/28 15:08:29 carsten Exp $
# File:     admin/chat/delete-room-2.tcl
# Date:     1998-11-18
# Contact:  aure@arsdigita.com,philg@mit.edu, ahmeds@arsdigita.com
# Purpose:  deletes a chat room

set_the_usual_form_variables

# chat_room_id

ad_maybe_redirect_for_registration

set db [ns_db gethandle]

ns_db dml $db "begin transaction"

# delete the admin group we were using for moderation

set admin_group_id [ad_administration_group_id $db chat $chat_room_id]
if ![empty_string_p $admin_group_id] {
    ns_db dml $db "delete from user_group_map_queue where group_id = $admin_group_id"
    ns_db dml $db "delete from user_group_map where group_id = $admin_group_id"
}

ns_db dml $db "delete from chat_msgs where chat_room_id=$chat_room_id"

ns_db dml $db "delete from chat_rooms where chat_room_id=$chat_room_id"

ns_db dml $db "end transaction"

ad_returnredirect index.tcl
