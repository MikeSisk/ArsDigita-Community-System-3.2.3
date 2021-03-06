# $Id: ad-widgets.tcl,v 3.1.4.2 2000/05/09 15:40:25 carsten Exp $
proc_doc state_widget {db {default ""} {select_name "usps_abbrev"}} "Returns a state selection box" {

    set widget_value "<select name=\"$select_name\">\n"
    if { $default == "" } {
        append widget_value "<option value=\"\" SELECTED>Choose a State</option>\n"
    }
    set selection [ns_db select $db "select * from states order by state_name"]
    while { [ns_db getrow $db $selection] } {
        set_variables_after_query
        if { $default == $usps_abbrev } {
            append widget_value "<option value=\"$usps_abbrev\" SELECTED>$state_name</option>\n" 
        } else {            
            append widget_value "<option value=\"$usps_abbrev\">$state_name</option>\n"
        }
    }
    append widget_value "</select>\n"
    return $widget_value
}


proc_doc country_widget {db {default ""} {select_name "country_code"} {size_subtag "size=4"}} "Returns a country selection box" {

    set widget_value "<select name=\"$select_name\" $size_subtag>\n"
    if { $default == "" } {
        if [ad_parameter SomeAmericanReadersP] {
	    append widget_value "<option value=\"\">Choose a Country</option>
<option value=\"us\" SELECTED>United States</option>\n"
	} else {
	    append widget_value "<option value=\"\" SELECTED>Choose a Country</option>\n"
	}
    }
    set selection [ns_db select $db "select country_name, iso from country_codes order by country_name"]
     while { [ns_db getrow $db $selection] } {
        set_variables_after_query
        if { $default == $iso } {
            append widget_value "<option value=\"$iso\" SELECTED>$country_name</option>\n" 
        } else {            
            append widget_value "<option value=\"$iso\">$country_name</option>\n"
        }
    }
    append widget_value "</select>\n"
    return $widget_value
}


# teadams - It is usually more approprate to use html_select_options or
# html_select_value_options. 

proc_doc ad_generic_optionlist {items values {default ""}} "Use this to build select form fragments.  Given a list of items and a list of values, will return the option tags with default highlighted as appropriate." {

    # items is a list of the items you would like the user to select from
    # values is a list of corresponding option values
    # default is the value of the item to be selected
    set count 0
    set return_string ""
    foreach value $values {
	if {  [string compare $default $value] == 0 } {
	    append return_string "<option SELECTED value=\"$value\">[lindex $items $count]\n"
	} else {
	    append return_string "<option value=\"$value\">[lindex $items $count]\n"
	}
	incr count
   }
    return $return_string
}


# use ad_integer_optionlist instead of day_list
proc day_list {} {
    return  {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31}
}

proc_doc month_list {} "Returns list of month abbreviations" {
    return  {Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec}
}


proc_doc long_month_list {} "Returns list of months" {
    return  {January February March April May Jun July August September October November December}
}

# use ad_integer_optionlist instead of month_value_list
proc month_value_list {} {
    return {1 2 3 4 5 6 7 8 9 10 11 12}
} 

proc_doc future_years_list {{num_year 10}} "Returns a list containing the next num_year years in the future." {
    set year [ns_fmttime [ns_time] %Y] 
    set counter  0
    while {$counter < $num_year } {
	incr counter
	lappend year_list $year    
	incr year    
    }
    return $year_list
}


# produces the optionlist for a range of integers

# if pad_to_two_p is 1, the option values will be 
# padded to 2 digites with a leading 0

proc_doc ad_integer_optionlist {start_value end_value {default ""} { pad_to_two_p 0} } "Produces an optionlist for a range of integers from start_value to end_value. If default matches one of the options, it is selection. If pad_to_two_p is 1, the option values will be padded to 2 digites with a leading 0." {
    # items is a list of the items you would like the user to select from
    # values is a list of corresponding option values
    # default is the value of the item to be selected
    set count 0
    set return_string ""
    
    
    for { set x $start_value } { $x <= $end_value } { incr x } {

	if { $pad_to_two_p && $x >= 0 && $x < 10 } {
	    set value "0$x"
	} else {
	    set value $x
	}

	if { $default == $value } {
	    append return_string "<option SELECTED value=\"$value\">$value\n"
	} else {
	    append return_string "<option value=\"$value\">$value\n"
	}
    }
    return $return_string
}   

## teadams - use dm_html_select_options or db_html_select_value_options
## instead of ad_db_optionlist

proc_doc ad_db_optionlist {db sql {default ""}} "Produces an optionlist using results from a database query. The first selected column should contain the optionlist items.  The second selected column should contain the optionlist values." {
    set retval ""
    set selection [ns_db select $db $sql]
    while { [ns_db getrow $db $selection] } {
        set item [ns_set value $selection 0]
        set value [ns_set value $selection 1]
        if { $value == $default } {
            append retval "<option SELECTED value=\"$value\">$item\n"
        } else {
            append retval "<option value=\"$value\">$item\n"
        }
    }
    return $retval
}


proc_doc ad_dateentrywidget {column { value 0 } } "Returns form pieces for a date entry widget. A null date may be selected." {
    ns_share NS
    # if you would like the default to be null, call with value= ""

    if { $value == 0 } {
	# no default, so use today
	set value  [lindex [split [ns_localsqltimestamp] " "] 0]
    } 

    set date_parts [split $value "-"]
    if { $value == "" } {
	set month ""
	set day ""
	set year ""
    } else {
	set date_parts [split $value "-"]
	set month [lindex $date_parts 1]
	set year [lindex $date_parts 0]
	set day [lindex $date_parts 2]
    }

    set output "<SELECT name=ColValue.[ns_urlencode $column].month>\n"
    append output "<OPTION>\n"
    # take care of cases like 09 for month
    regsub "^0" $month "" month
    for {set i 0} {$i < 12} {incr i} {
	if { $i == [expr $month - 1] } {
	    append output "<OPTION selected> [lindex $NS(months) $i]\n"
	} else {
	    append output "<OPTION>[lindex $NS(months) $i]\n"
	}
    }

    append output \
"</SELECT><INPUT NAME=ColValue.[ns_urlencode $column].day\
TYPE=text SIZE=3 MAXLENGTH=2 value=\"$day\">&nbsp;<INPUT NAME=ColValue.[ns_urlencode $column].year\
TYPE=text SIZE=5 MAXLENGTH=4 value=\"$year\">"

     return $output
}


ad_proc ad_db_select_widget {
    { 
        -size 0
        -multiple 0
        -default {}
        -option_list {}
        -blank_if_no_db 0
        -hidden_if_one_db 0
    } 
    db sql name 
} { 
    given a db handle and sql this generates a select group.  If there is only
    one value it returns the text and a hidden variable setting that value.
    The first selected column should contain the optionlist items. The
    second selected column should contain the optionlist values. 
    <p>
    option_list is a list in the same format (i.e. {{str val} {str2 val2}...})
    which is prepended to the list
    <p>
    if db is null then the list is constructed from option_list only.
    <p> 
    if there is only one item the select is not generated and the value
    is passed in hidden form variable.
    <p> 
    if -multiple is given the a multi select is returned.
    <p>
    if -blank_if_no_db set then do not return a select widget unless 
    there are rows from the database
} { 
    set retval {}
    set count 0
    set dbcount 0
    if {![empty_string_p $option_list]} {
        foreach opt $option_list { 
            incr count
            set item [lindex $opt 1]
            set value [lindex $opt 0]
            if { (!$multiple && [string compare $value $default] == 0) 
                 || ($multiple && [lsearch -exact $default $value] > -1)} {
                append retval "<option SELECTED value=\"$value\">$item\n"
            } else {
                append retval "<option value=\"$value\">$item\n"
            }
        }
    }

    if { $blank_if_no_db} {
        set count 0
    }

    if {! [empty_string_p $db]} {
        set selection [ns_db select $db $sql]
        while { [ns_db getrow $db $selection] } {
            incr count
            incr dbcount
            set item [ns_set value $selection 0]
            set value [ns_set value $selection 1]
            if { (!$multiple && [string compare $value $default] == 0) 
                 || ($multiple && [lsearch -exact $default $value] > -1)} {
                append retval "<option SELECTED value=\"$value\">$item\n"
            } else {
                append retval "<option value=\"$value\">$item\n"
            }
        }
    }
    
    if { $count == 0 } { 
        if {![empty_string_p $default]} { 
            return "<input type=hidden value=\"[philg_quote_double_quotes $default]\" name=$name>\n"
        } else { 
            return {}            
        }
    } elseif { $count == 1 || ($dbcount == 1 && $hidden_if_one_db) } {
        return "$item<input type=hidden value=\"[philg_quote_double_quotes $value]\" name=$name>\n"
    } else { 
        set select "<select name=$name"
        if {$size != 0} { 
            append select " size=$size"
        } 
        if {$multiple} {
            append select " multiple"
        }
        return "$select>\n$retval</select>"
    }
}



proc_doc currency_widget {db {default ""} {select_name "currency_code"} {size_subtag "size=4"}} "Returns a currency selection box" {

    set widget_value "<select name=\"$select_name\" $size_subtag>\n"
    if { $default == "" } {
        if [ad_parameter SomeAmericanReadersP] {
	    append widget_value "<option value=\"\">Currency</option>
<option value=\"USD\" SELECTED>United States Dollar</option>\n"
	} else {
	    append widget_value "<option value=\"\" SELECTED>Currency</option>\n"
	}
    }
    set selection [ns_db select $db "select currency_name, iso 
                                     from currency_codes 
                                     where supported_p='t'
                                     order by currency_name"]
     while { [ns_db getrow $db $selection] } {
        set_variables_after_query
        if { $default == $iso } {
            append widget_value "<option value=\"$iso\" SELECTED>$currency_name</option>\n" 
        } else {            
            append widget_value "<option value=\"$iso\">$currency_name</option>\n"
        }
    }
    append widget_value "</select>\n"
    return $widget_value
}


proc_doc ad_html_colors {} "Returns an array of HTML colors and names." {
    return {
	{ Black 0 0 0 }
	{ Silver 192 192 192 }
	{ Gray 128 128 128 }
	{ White 255 255 255 }
	{ Maroon 128 0 0 }
	{ Red 255 0 0 }
	{ Purple 128 0 128 }
	{ Fuchsia 255 0 255 }
	{ Green 0 128 0 }
	{ Lime 0 255 0 }
	{ Olive 128 128 0 }
	{ Yellow 255 255 0 }
	{ Navy 0 0 128 }
	{ Blue 0 0 255 }
	{ Teal 0 128 128 }
	{ Aqua 0 255 255 }
    }
}

proc_doc ad_color_widget_js {} "Returns JavaScript code necessary to use color widgets." {
    return {

var adHexTupletValues = '0123456789ABCDEF';

function adHexTuplet(val) {
    return adHexTupletValues.charAt(Math.floor(val / 16)) + adHexTupletValues.charAt(Math.floor(val % 16));
}

function adUpdateColorText(field) {
    var form = document.forms[0];
    var element = form[field + ".list"];
    var rgb = element.options[element.selectedIndex].value;
    var r,g,b;
    if (rgb == "" || rgb == "none" || rgb == "custom") {
        r = g = b = "";
    } else {
        var components = rgb.split(",");
        r = components[0];
        g = components[1];
        b = components[2];
    }
    form[field + ".c1"].value = r;
    form[field + ".c2"].value = g;
    form[field + ".c3"].value = b;

    document['color_' + field].src = '/shared/1pixel.tcl?r=' + r + '&g=' + g + '&b=' + b;
}

function adUpdateColorList(field) {
    var form = document.forms[0];
    var element = form[field + ".list"];

    var c1 = form[field + ".c1"].value;
    var c2 = form[field + ".c2"].value;
    var c3 = form[field + ".c3"].value;
    if (c1 != parseInt(c1) || c2 != parseInt(c2) || c3 != parseInt(c3) ||
        c1 < 0 || c2 < 0 || c3 < 0 || c1 > 255 || c2 > 255 || c3 > 255) {
        element.selectedIndex = 1;
        document['color_' + field].src = '/shared/1pixel.tcl?r=255&g=255&b=255';
        return;
    }

    document['color_' + field].src = '/shared/1pixel.tcl?r=' + c1 + '&g=' + c2 + '&b=' + c3;

    var rgb = parseInt(form[field + ".c1"].value) + "," + parseInt(form[field + ".c2"].value) + "," + parseInt(form[field + ".c3"].value);
    var found = 0;
    for (var i = 0; i < element.length; ++i)
        if (element.options[i].value == rgb) {
            element.selectedIndex = i;
	    found = 1;
            break;
        }
    if (!found)
        element.selectedIndex = 0;
}

    }
} 

proc_doc ad_color_widget { name default { use_js 0 } } "Returns a color selection widget, optionally using JavaScript. Default is a string of the form '0,192,255'." {
    set out "<table cellspacing=0 cellpadding=0><tr><td><select name=$name.list"
    if { $use_js != 0 } {
	append out " onChange=\"adUpdateColorText('$name')\""
    }
    append out ">\n"

    set items [list "custom:" "none"]
    set values [list "custom" ""]

    foreach color [ad_html_colors] {
	lappend items [lindex $color 0]
	lappend values "[lindex $color 1],[lindex $color 2],[lindex $color 3]"
    }

    append out "[ad_generic_optionlist $items $values $default]</select>\n"

    if { ![regexp {^([0-9]+),([0-9]+),([0-9]+)$} $default all c1 c2 c3] } {
	set c1 ""
	set c2 ""
	set c3 ""
    }

    foreach component { c1 c2 c3 } {
	append out " <input name=$name.$component size=3 value=\"[set $component]\""
	if { $use_js } {
	    append out " onChange=\"adUpdateColorList('$name')\""
	}
	append out ">"
    }

    if { $use_js == 1 } {
	if { $c1 == "" } {
	    set c1 255
	    set c2 255
	    set c3 255
	}
	append out "</td><td>&nbsp; <img name=color_$name src=\"/shared/1pixel.tcl?r=$c1&g=$c2&b=$c3\" width=26 height=26 border=1>"
    }
    append out "</td></tr></table>\n"
    return $out
}

proc_doc ad_process_color_widgets args { Sets variables corresponding to the color widgets named in $args. } {
    foreach field $args {
	upvar $field var
	set var [ns_queryget "$field.list"]
	if { $var == "custom" } {
	    set var "[ns_queryget "$field.c1"],[ns_queryget "$field.c2"],[ns_queryget "$field.c3"]"
	}
	if { ![regexp {^([0-9]+),([0-9]+),([0-9]+)$} $var "" r g b] || $r > 255 || $g > 255 || $b > 255 } {
	    set var ""
	}
    }
}

proc_doc ad_color_to_hex { triplet } { Converts a string of the form 0,192,255 to a string of the form #00C0FF. } {
    if { [regexp {^([0-9]+),([0-9]+),([0-9]+)$} $triplet all r g b] } {
	return "#[format "%02x%02x%02x" $r $g $b]"
    } else {
	return ""
    }
}

proc_doc ad_choice_bar { items links values {default ""} } "Displays a list of choices (Yahoo style), with the currently selected one highlighted." {

    set count 0
    set return_list [list]

    foreach value $values {
	if { [string compare $default $value] == 0 } {
	    lappend return_list "<strong>[lindex $items $count]</strong>"
	} else {
	    lappend return_list "<a href=\"[lindex $links $count]\">[lindex $items $count]</a>"
	}
	incr count
	
    }
    if { [llength $return_list] > 0 } {
        return "\[[join $return_list " | "]\]"
    } else {
	return ""
    }
    
}
