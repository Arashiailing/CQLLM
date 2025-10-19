/**
 * @name CWE-863: Incorrect Authorization
 * @description The product performs an authorization check when an actor attempts to access a resource or perform an action,
 *              but it does not correctly perform the check.
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @id py/views-cwe-863
 */

import python
import semmle.python.security.dataflow.PamAuthorizationQuery
import PamAuthorizationFlow::PathGraph

from PamAuthorizationFlow::PathNode source, PamAuthorizationFlow::PathNode sink
where PamAuthorizationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This authorization check depends on a $@.", source.getNode(), "user-provided value"