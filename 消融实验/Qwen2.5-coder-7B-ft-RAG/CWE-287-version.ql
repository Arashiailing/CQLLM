/**
 * @name CWE-287: Improper Authentication
 * @description When an actor claims to have a given identity, the product does not prove or insufficiently proves that the claim is correct.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 8.1
 * @precision high
 * @id py/cwe-287
 * @tags security
 *       external/cwe/cwe-287
 */

import python
import PamAuthorizationFlow::PathGraph
import semmle.python.ApiGraphs
import semmle.python.security.dataflow.PamAuthorizationQuery

from PamAuthorizationFlow::PathNode source, PamAuthorizationFlow::PathNode sink
where PamAuthorizationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This authentication mechanism relies on a $@ without verifying its accuracy.", source.getNode(),
  "user-provided value"