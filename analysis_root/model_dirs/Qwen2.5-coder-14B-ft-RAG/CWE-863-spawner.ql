/**
 * @name PAM授权绕过问题由于不正确使用
 * @description 在`pam_authenticate`之后不使用`pam_acct_mgmt`来检查登录的有效性，可能导致授权绕过。
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 8.1
 * @precision high
 * @id py/pam-auth-bypass
 * @tags security
 *       external/cwe/cwe-285
 */

import python
import PamAuthorizationFlow::PathGraph
import semmle.python.ApiGraphs
import semmle.python.security.dataflow.PamAuthorizationQuery

from PamAuthorizationFlow::PathNode source, PamAuthorizationFlow::PathNode sink
where PamAuthorizationFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "This PAM authentication depends on a $@, and 'pam_acct_mgmt' is not called afterwards.",
  source.getNode(), "user-provided value"