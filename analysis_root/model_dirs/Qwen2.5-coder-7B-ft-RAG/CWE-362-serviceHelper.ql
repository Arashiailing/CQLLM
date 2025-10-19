/**
 * @name CWE-362: Concurrent Execution using Shared Resource with Improper Synchronization ('Race Condition')
 * @description The product contains a concurrent code sequence that requires temporary, exclusive access to a shared resource,
 *              but a timing window exists in which the shared resource can be modified by another code sequence operating concurrently.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/race-condition
 * @tags security
 *       external/cwe/cwe-362
 */

import python
import semmle.python.security.dataflow.RaceConditionQuery
import RaceConditionFlow::PathGraph

from RaceConditionFlow::PathNode source, RaceConditionFlow::PathNode sink
where RaceConditionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Access to this shared variable depends on a $@", source.getNode(), "concurrent operation"