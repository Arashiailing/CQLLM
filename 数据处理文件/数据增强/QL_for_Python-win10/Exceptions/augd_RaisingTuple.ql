/**
 * @name Raising a tuple
 * @description Raising a tuple will result in all but the first element being discarded
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

// Identify raise statements where the exception originates from a tuple
from Raise raiseStmt, DataFlow::LocalSourceNode sourceNode
where
  // Ensure we're analyzing Python 2 code
  major_version() = 2 and
  // Verify the source node represents a tuple expression
  sourceNode.asExpr() instanceof Tuple and
  // Confirm data flow from the tuple to the raised exception
  exists(DataFlow::Node exceptionNode |
    exceptionNode.asExpr() = raiseStmt.getException() and
    sourceNode.flowsTo(exceptionNode)
  )
/* Raising a tuple is a type error in Python 3, so is handled by the IllegalRaise query. */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  sourceNode, "tuple"