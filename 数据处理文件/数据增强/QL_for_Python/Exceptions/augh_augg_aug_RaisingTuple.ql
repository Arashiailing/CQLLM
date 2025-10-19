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
from Raise raiseStatement, DataFlow::LocalSourceNode tupleOrigin
where
  // Restrict analysis to Python 2 (Python 3 handles this as a type error)
  major_version() = 2 and
  // Ensure the source node represents a tuple expression
  tupleOrigin.asExpr() instanceof Tuple and
  // Verify data flow path from tuple to the raised exception
  exists(DataFlow::Node exceptionNode |
    exceptionNode.asExpr() = raiseStatement.getException() and
    tupleOrigin.flowsTo(exceptionNode)
  )
/* Note: Raising a tuple is a type error in Python 3 and is handled by the IllegalRaise query. */
select raiseStatement,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleOrigin, "tuple"