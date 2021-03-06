# /www/download/admin/view-one-version-report.tcl
#
# Date:     01/04/2000
# Author :  ahmeds@mit.edu
# Purpose:  displays summary of this version ( who downloaded for what reason)
#
# $Id: view-one-version-report.tcl,v 3.1.6.1 2000/04/12 09:00:49 ron Exp $
# -----------------------------------------------------------------------------

set_the_usual_form_variables
# maybe scope, maybe scope related variables (group_id)
# version_id

ad_scope_error_check

set db_pool [ns_db gethandle [philg_server_default_pool] 2]
set db [lindex $db_pool 0]
set db2 [lindex $db_pool 1]

download_version_admin_authorize $db $version_id

set selection [ns_db 1row $db "
select download_name , version, dv.download_id as did
from downloads d, download_versions dv
where d.download_id = dv.download_id
and dv.version_id = $version_id"]

set_variables_after_query

set email_count [database_to_tcl_string $db "
select count(distinct u.email)
from  download_versions dv, download_log dl, users u
where dl.version_id = dv.version_id
and dl.user_id = u.user_id
and dv.version_id = $version_id"]

if { $email_count > 0 } {
    append html "
    <li><a href=\"spam-all-version-downloaders.tcl?[export_url_scope_vars version_id]\">Spam All Downloaders</a>
    "
} 

set reason_count [database_to_tcl_string $db "
select count (*) 
from  download_versions dv, download_log dl
where dl.version_id = dv.version_id
and dv.version_id = $version_id
and download_reasons is not null"]

if { $reason_count > 0 } {
    append html "
    <li><a href=\"view-all-dl-version-reasons.tcl?[export_url_scope_vars version_id]\">View All Download Reasons</a>
    "
}

set selection [ns_db select $db "
select user_id, entry_date, ip_address, version, status, log_id , download_reasons
from  download_versions dv, download_log dl
where dl.version_id = dv.version_id
and dv.version_id = $version_id
order by entry_date desc"]

set counter 0

append table_html "
<p>
<center>
<table cellpadding=3 border=1>
<tr>
<th  align=center>[ad_space 1] User Name [ad_space 1]  </th>
<th  align=center>[ad_space 1] Email [ad_space 1]  </th>
<th  align=center>[ad_space 1] Download Date[ad_space 1]  </th>
<th  align=center>[ad_space 1] IP Address[ad_space 1]  </th>
<th  align=center>[ad_space 1] Version[ad_space 1]  </th>
<th  align=center>[ad_space 1] Status[ad_space 1]  </th>
<th  align=center>[ad_space 1] Download Reason[ad_space 1]  </th>
<th  align=center>Remove </th>
</tr>
"

while { [ns_db getrow $db $selection] } {
    set_variables_after_query

    if { [empty_string_p $user_id] } {
	set email_string "Unavailable"
	set name_string "Anonymous"	
    } else {
	set sub_selection [ns_db 1row $db2 "
	select email, first_names, last_name
	from users
	where user_id = $user_id "]
	
	set_variables_after_subquery
	
	set email_string "<a href=\"mailto:$email\"><address>$email</address></a>"
	set name_string "$first_names $last_name"	
    }
    

    set dl_reason_html [ad_decode $download_reasons "" None "<a href=download-reason-view.tcl?[export_url_scope_vars log_id version_id]>view</a>"]

    set return_url "view-one-version-report.tcl?[export_url_scope_vars version_id]"

    append table_html "
    <tr>
    <td  align=left>$name_string</td>
    <td  align=left>$email_string</td>
    <td  align=center>[util_AnsiDatetoPrettyDate $entry_date]</td>
    <td  align=center>$ip_address</td>
    <td  align=center>$version</td>
    <td  align=left>$status</td>
    <td  align=center>$dl_reason_html</td>
    <td  align=center><a href=log-entry-remove.tcl?[export_url_scope_vars log_id return_url]>remove</a></td>
     </tr>
    "
    incr counter
}

if {$counter >0} {
    append table_html "
    </table>
    </center>
    <p>
    "
    append html $table_html
} else {
    set html "
    There is no log information in the database about this particular download.
    "
}

# -----------------------------------------------------------------------------

set page_title "Download Report of $download_name version $version"

ns_return 200 text/html "
[ad_scope_header $page_title $db]
[ad_scope_page_title $page_title $db]
[ad_scope_context_bar \
	[list "/download/" "Download"] \
	[list "/download/admin/" "Admin"] \
	[list "download-view.tcl?[export_url_scope_vars ]&download_id=$did " "$download_name"] \
	[list "view-versions.tcl?[export_url_scope_vars]&download_id=$did " "Versions"] \
	[list "view-one-version.tcl?[export_url_scope_vars version_id]" "One Version"] \
	"View Report"]

<hr>
[help_upper_right_menu]

<blockquote>
$html
</blockquote>
[ad_scope_footer]
"
