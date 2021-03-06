# $Id: extras-upload.tcl,v 3.0 2000/02/06 03:20:07 ron Exp $
# This page uploads a CSV file containing client-specific product information into the catalog.  The file format
# should be:
#
# field_name_1, field_name_2, ... field_name_n
# value_1, value_2, ... value_n
#
# where the first line contains the actual names of the columns in ec_custom_product_field_values and the remaining lines contain
# the values for the specified fields, one line per product.
#
# Legal values for field names are site-specific: whatever additional fields the administrator has created prior to
# loading a file can be populated by this script.
#
# Note: last_modified, last_modifying_user and modified_ip_address are set automatically and should not appear in
# the CSV file.

ReturnHeaders

ns_write "[ad_admin_header "Upload Product Extras"]

<h3>Upload Product Extras</h3>

[ad_admin_context_bar [list "../" "Ecommerce"] [list "index.tcl" "Products"] "Upload Product Extras"]

<hr>

<blockquote>

<form enctype=multipart/form-data action=extras-upload-2.tcl method=post>
CSV Filename <input name=csv_file type=file>
<p>
<center>
<input type=submit value=Upload>
</center>
</form>


<p>

<b>Notes:</b>

<blockquote>
<p>

This page uploads a CSV file containing product information into the database.  The file format should be:
<p>
<blockquote>
<code>field_name_1, field_name_2, ... field_name_n<br>
value_1, value_2, ... value_n</code>
</blockquote>
<p>
where the first line contains the actual names of the columns in ec_custom_product_field_values and the remaining lines contain
the values for the specified fields, one line per product.
<p>
Legal values for field names are the columns in ec_custom_product_field_values
(which are set by you when you add custom database fields):
<p>
<blockquote>
<pre>
"

set db [ns_db gethandle]

for {set i 0} {$i < [ns_column count $db ec_custom_product_field_values]} {incr i} {
    set col_to_print [ns_column name $db ec_custom_product_field_values $i]
    set undesirable_cols [list "available_date" "last_modified" "last_modifying_user" "modified_ip_address"]
    set required_cols [list "product_id"]
    if { [lsearch -exact $undesirable_cols $col_to_print] == -1 } {
	ns_write "$col_to_print"
	if { [lsearch -exact $required_cols $col_to_print] != -1 } {
	    ns_write " (required)"
	}
	ns_write "\n"
    }
}

ns_write "</pre>
</blockquote>
<p>
Note: Some of these fields may be inactive, in which case there
might be no good reason for you to include them in the upload.
Additionally, <code>[join $undesirable_cols ", "]</code> are set 
automatically and should not appear in the CSV file.


</blockquote>

</blockquote>

[ad_admin_footer]

"
