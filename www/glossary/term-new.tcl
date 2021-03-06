# $Id: term-new.tcl,v 3.0.4.1 2000/04/28 15:10:55 carsten Exp $
if {[ad_read_only_p]} {
    ad_return_read_only_maintenance_message
    return
}

set user_id [ad_verify_and_get_user_id]
if { $user_id == 0 } {
    ad_returnredirect "/register/index.tcl?return_url=[ns_urlencode [ns_conn url]]"
    return
}

if { [ad_parameter ApprovalPolicy glossary] == "open"} {
    set verb "Add"
} elseif { [ad_parameter ApprovalPolicy glossary] == "wait"} {
    set verb "Suggest"
} else {
    ad_returnredirect "index.tcl"
    return
}

ReturnHeaders
ns_write "[ad_header "$verb a Term"]
<h2>$verb a Term</h2>
[ad_context_bar_ws_or_index [list "index.tcl" Glossary] "$verb Term"]
<hr>
"

set db [ns_db gethandle]

ns_write "
<form method=post action=\"term-new-2.tcl\">
<table>
<tr><th>Term <td><input type=text size=40 name=term>
<tr><th>Definition <td><textarea cols=60 rows=6 wrap=soft name=definition></textarea>
</tr>
</table>
<br>
<center>
<input type=\"submit\" value=\"Submit\">
</center>
</form>
[ad_footer]
"
 

