/**
* @name CWE-287: Improper Authentication
*
@description When an act
    or claims to have a given identity, the product does not prove
    or insufficiently proves that the claim is correct.
* @kind problem
* @problem.severity warning
*
@id py/core-cwe-287
*/
import python
import PamAuthorizationFlow::PathGraph
import semmle.python.ApiGraphs
import semmle.python.security.dataflow.PamAuthorizationQuery
from PamAuthorizationFlow::PathNode source, PamAuthorizationFlow::PathNode sink
    where PamAuthorizationFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This PAM authentication depends on a $@,
    and 'pam_acct_mgmt' is not called afterwards.", source.getNode(), "user-provided value"