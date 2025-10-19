/**
 * @name Incorrect authorization when using PAM
 * @description PAM authorization bypass can occur when 'pam_authenticate' is used without 'pam_acct_mgmt'
 *              to verify that a login is valid.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 8.1
 * @precision high
 * @id py/pam-auth-bypass
 * @tags security
 *       external/cwe/cwe-285
 */

import python
import semmle.python.ApiGraphs
import semmle.python.security.dataflow.PamAuthorizationQuery
import PamAuthorizationFlow::PathGraph

from PamAuthorizationFlow::PathNode source, PamAuthorizationFlow::PathNode sink
where PamAuthorizationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This PAM authentication depends on a $@, and 'pam_acct_mgmt' is not called afterwards.", source.getNode(), "user-provided value"