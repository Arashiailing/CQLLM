python
import semmle.python.security.dataflow.AuthenticationQuery

from AuthenticationQuery::AuthenticationSource auth_source, AuthenticationQuery::AuthenticationSink auth_sink
where AuthenticationQuery::authenticationPath(auth_source, auth_sink)
select auth_sink.getNode(), auth_source, auth_sink, "Improper authentication detected."