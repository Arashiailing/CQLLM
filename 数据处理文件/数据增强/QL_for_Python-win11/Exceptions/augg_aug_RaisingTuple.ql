/**
 * @name Raising a tuple
 * @description Raising a tuple will result in all but the first element being discarded
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple */

import python
import semmle.python.dataflow.new.DataFlow

// Identify raise statements where the exception originates from a tuple
from Raise raiseStmt, DataFlow::LocalSourceNode tupleExprSource
where
  // Only applicable in Python 2 (Python 3 handles this as a type error)
  major_version() = 2 and
  // The source node must be a tuple expression
  tupleExprSource.asExpr() instanceof Tuple and
  // Verify data flow from tuple to the exception being raised
  exists(DataFlow::Node raisedExceptionNode |
    raisedExceptionNode.asExpr() = raiseStmt.getException() and
    tupleExprSource.flowsTo(raisedExceptionNode)
  )
/* Raising a tuple is a type error in Python 3, so is handled by the IllegalRaise query. */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleExprSource, "tuple"