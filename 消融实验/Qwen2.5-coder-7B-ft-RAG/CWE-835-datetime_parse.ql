/**
 * @name CWE-835: Loop with Unreachable Exit Condition ('Infinite Loop')
 * @description The product contains an iteration or loop with an exit condition that cannot be reached, i.e., an infinite loop.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       external/cwe/cwe-835
 * @problem.severity error
 * @precision medium
 * @id py/unreachable-loop-condition
 */

import python
import semmle.python.security.dataflow.InfiniteLoopQuery
import InfiniteLoopFlow::PathGraph

from InfiniteLoopFlow::PathNode source, InfiniteLoopFlow::PathNode sink
where InfiniteLoopFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Unreachable loop condition may cause an infinite loop at this point."