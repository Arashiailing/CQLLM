/**
 * @name Raising a tuple in Python 2
 * @description When raising a tuple in Python 2, only the first element is used and the rest are discarded
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

/* Raising a tuple is a type error in Python 3, so is handled by the IllegalRaise query. */
from Raise raiseStmt, DataFlow::LocalSourceNode sourceNode
where
  // Only applicable to Python 2
  major_version() = 2 and
  // Source expression must be a tuple
  sourceNode.asExpr() instanceof Tuple and
  // Verify data flow from tuple to raise exception
  exists(DataFlow::Node exceptionNode | 
    exceptionNode.asExpr() = raiseStmt.getException() and
    sourceNode.flowsTo(exceptionNode)
  )
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  sourceNode, "tuple"