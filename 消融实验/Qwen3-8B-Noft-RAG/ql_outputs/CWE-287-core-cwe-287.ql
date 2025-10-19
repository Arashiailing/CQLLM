/**
 * @name CWE-287: Improper Authentication
 * @id py/core-cwe-287
 */
import python
import semmle.python.security.dataflow.PamAuthorizationQuery
import PamAuthorizationFlow::PathGraph

from PamAuthorizationFlow::PathNode source, PamAuthorizationFlow::PathNode sink
where
  PamAuthorizationFlow::flowPath(source, sink) and
  source.getNode().(Function).getName() = "pam_authenticate" and
  not exists(Call c | c.getFunction().getName() = "pam_acct_mgmt" and
             PamAuthorizationFlow::flowPath(source, c) and
             PamAuthorizationFlow::flowPath(c, sink))
select sink.getNode(), source, sink, "Improper authentication: pam_acct_mgmt not called after pam_authenticate"