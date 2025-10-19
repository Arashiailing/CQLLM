/**
 * @name CWE-863: Incorrect Authorization
 * @description The product performs an authorization check when an actor attempts to access a resource or perform an action, but it does not correctly perform the check.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision medium
 * @id py/views-cwe-863
 * @tags correctness
 *       security
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs
import semmle.python.security.dataflow.PamAuthorizationQuery

from PamAuthorizationFlow::PathNode source, PamAuthorizationFlow::PathNode sink
where PamAuthorizationFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "This PAM authentication depends on a $@, and 'pam_acct_mgmt' is not called afterwards.",
  source.getNode(), "user-provided value"