# $Id: search.tcl,v 3.0 2000/02/06 03:34:39 ron Exp $
# this is for the whole frame

set_form_variables

# query_string, topic

ns_return 200 text/html "

<HTML><BASE F0NTSIZE=3>

<HEAD>

<TITLE>$topic Search Results</TITLE>

</HEAD>

<FRAMESET ROWS=\"25%,*\">

<FRAME SCROLLING=\"yes\" NAME=\"subject\" SRC=\"search-subject.tcl?[export_url_vars topic topic_id]&query_string=[ns_urlencode $query_string]\">

<FRAME SCROLLING=\"yes\" NAME=\"main\" SRC=\"search-default-main.tcl?[export_url_vars topic topic_id]&query_string=[ns_urlencode $query_string]\">

</FRAMESET>
<NOFRAME>

<BODY BGCOLOR=\"#FFFFFF\" TEXT=\"#000000\">

This bulletin board system can only be used with a frames-compatible
browser.

<p>

Perhaps you should consider running Netscape 2.0 or later?


</BODY></HTML>

</NOFRAME>

</FRAMESET>


"