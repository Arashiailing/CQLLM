import python
import semmle.code.cpp.callgraph.CallGraph
import semmle.code.cpp.dataflow.DataFlow

/**
 * @name CWE-254: PamAuthorizationQuery
 * @id py/pam-authorization-query
 */
from Call call
where call.getName() = "pam_authenticate" or call.getName() = "pam_acct_mgmt"
select call, "Potential CWE-254: Improper authorization check using PAM functions."