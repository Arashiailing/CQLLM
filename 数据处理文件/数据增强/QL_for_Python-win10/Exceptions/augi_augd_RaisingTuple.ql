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

// Find raise statements where the exception is derived from a tuple
from Raise raiseStatement, DataFlow::LocalSourceNode tupleSourceNode
where
  // This issue only occurs in Python 2 code
  major_version() = 2 and
  // Ensure the source node represents a tuple expression
  tupleSourceNode.asExpr() instanceof Tuple and
  // Verify data flows from the tuple to the raised exception
  exists(DataFlow::Node raisedExceptionNode |
    raisedExceptionNode.asExpr() = raiseStatement.getException() and
    tupleSourceNode.flowsTo(raisedExceptionNode)
  )
/* Note: In Python 3, raising a tuple is a type error and is caught by the IllegalRaise query. */
select raiseStatement,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSourceNode, "tuple"