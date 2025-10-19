import python
import PamAuthorizationFlow::PathGraph
import semmle.python.ApiGraphs
import semmle.python.security.dataflow.PamAuthorizationQuery

from PamAuthorizationFlow::PathNode source, PamAuthorizationFlow::PathNode sink
where PamAuthorizationFlow::flowPath(source, sink)
  and source.getNode().(Call) = API::builtin("pam_authenticate").getACall()
  and not exists(Call call | call = API::builtin("pam_acct_mgmt").getACall() and PamAuthorizationFlow::flowPath(source, call))
select sink.getNode(), source, sink, "Improper authentication: pam_authenticate used without subsequent pam_acct_mgmt check", source.getNode(), "user-provided value"