/**
 * @name Tuple raised as exception in Python 2
 * @description In Python 2, raising a tuple causes only the first element to be used as the exception, ignoring the rest.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

/* Python 3 handles tuple raises as type errors (covered by IllegalRaise query) */
from Raise raiseStmt, DataFlow::LocalSourceNode tupleSrcNode
where
  // Restrict analysis to Python 2 environments
  major_version() = 2 and
  // Verify the source represents a tuple expression
  tupleSrcNode.asExpr() instanceof Tuple and
  // Confirm data flow from tuple to exception target
  exists(DataFlow::Node exceptionTarget |
    exceptionTarget.asExpr() = raiseStmt.getException() and
    tupleSrcNode.flowsTo(exceptionTarget)
  )
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSrcNode, "tuple"