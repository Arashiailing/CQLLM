/**
 * @name CWE-287: Improper Authentication
 * @description When an actor claims to have a given identity, the product does not prove or insufficiently proves that the claim is correct.
 * @kind problem
 * @tags correctness
 *       security
 *       external/cwe/cwe-287
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/views-cwe-287
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs
import semmle.python.dataflow.new.TaintTracking
import PamAuthorizationFlow::PathGraph

from PamAuthorizationFlow::PathNode taintedSource, PamAuthorizationFlow::PathNode authSink
where PamAuthorizationFlow::flowPath(taintedSource, authSink)
select authSink.getNode(),
  taintedSource, authSink,
  "This PAM authentication depends on a $@.", taintedSource.getNode(), "user-provided value"