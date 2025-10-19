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
from Raise raiseNode, DataFlow::LocalSourceNode tupleSource
where
  // Only applicable in Python 2 (Python 3 handles this as a type error)
  major_version() = 2 and
  // The source node must be a tuple expression
  tupleSource.asExpr() instanceof Tuple and
  // Verify data flow from tuple to the exception being raised
  exists(DataFlow::Node exceptionNode |
    exceptionNode.asExpr() = raiseNode.getException() and
    tupleSource.flowsTo(exceptionNode)
  )
/* Raising a tuple is a type error in Python 3, so is handled by the IllegalRaise query. */
select raiseNode,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSource, "tuple"