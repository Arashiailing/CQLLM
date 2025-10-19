/**
 * @name CWE-287: Improper Authentication
 * @id py/service
 */
import python
import PamAuthorizationFlow::PathGraph
import semmle.python.security.dataflow.PamAuthorizationQuery

from PamAuthorizationFlow::PathNode source, PamAuthorizationFlow::PathNode sink
where PamAuthorizationFlow::flowPath(source, sink)
  and source.getNode().(PamAuthorizationFlow::AuthenticationStep).isAuthenticate()
  and not exists(PamAuthorizationFlow::PathNode n | PamAuthorizationFlow::flowPath(source, n) and n.getNode().(PamAuthorizationFlow::AuthenticationStep).isAccountManagement())
select sink.getNode(), source, sink, "Improper authentication: pam_authenticate used without subsequent pam_acct_mgmt verification.", source.getNode(), "user-provided credential"