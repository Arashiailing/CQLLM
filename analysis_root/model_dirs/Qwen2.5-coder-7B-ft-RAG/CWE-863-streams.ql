/**
 * @name CWE-863: Incorrect Authorization
 * @description The product performs an authorization check when an actor attempts to access a resource or perform an action, but it does not correctly perform the check.
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @security-severity 7.5
 * @id py/cwe-863
 * @tags correctness
 *       external/cwe/cwe-863
 */

import python
import semmle.python.security.dataflow.AuthorizationFlow
import AuthorizationFlow::PathGraph

from AuthorizationFlow::PathNode source, AuthorizationFlow::PathNode sink
where AuthorizationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "The result of this authorization check depends on a $@.", source.getNode(),
  "user-provided value"