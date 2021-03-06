# $Id: custom-field-add.tcl,v 3.0 2000/02/06 03:19:52 ron Exp $
ReturnHeaders

ns_write "[ad_admin_header "Add a Custom Field"]

<h2>Add a Custom Field</h2>

[ad_admin_context_bar [list "../" "Ecommerce"] [list "index.tcl" "Products"] [list "custom-fields.tcl" "Custom Fields"] "Add a Custom Field"]

<hr>

<form method=post action=custom-field-add-2.tcl>

<table noborder>

<tr>
<td>Unique Identifier</td>
<td><input type=text size=15 name=field_identifier maxlength=100></td>
<td>No spaces or special characters (just lowercase letters).  The customers won't see this, but the site
administrator might, so make it indicative of what the field is.</td>
</tr>

<tr>
<td>Field Name</td>
<td><input type=text size=25 name=field_name maxlength=100></td>
<td>This is the name that the customers will see (if you choose to display this field on the site) and
the name you'll see when adding/updating products.</td>
</tr>

<tr>
<td>Default Value (if any)</td>
<td colspan=2><input type=text size=15 name=default_value maxlength=100></td>
</tr>

<tr>
<td>What kind of information will this field hold?</td>
<td colspan=2>
[ec_column_type_widget]
</td>
</tr>
</table>

<p>

<center>
<input type=submit value=\"Submit\">
</center>

</form>

[ad_admin_footer]
"