# $Id: query-edit-sql-2.tcl,v 3.0.4.1 2000/04/28 15:09:59 carsten Exp $
set_the_usual_form_variables

# query_id, query_sql 

set db [ns_db gethandle]

ns_db dml $db "update queries set query_sql = '$QQquery_sql' where query_id = $query_id"

ad_returnredirect "query.tcl?[export_url_vars query_id]"

