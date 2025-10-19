/**
 * @name Raising a tuple in Python 2
 * @description In Python 2, raising a tuple results in only the first element being raised as an exception,
 *              while all other elements are silently discarded. This can lead to unexpected behavior.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple */

import python
import semmle.python.dataflow.new.DataFlow

// Identifies raise statements where the exception originates from a tuple expression
// In Python 2, this causes only the first element to be raised while discarding others
from Raise raiseStatement, DataFlow::LocalSourceNode tupleSourceNode
where
  // Target Python 2 codebases only
  major_version() = 2 and
  // Source must be a tuple expression
  tupleSourceNode.asExpr() instanceof Tuple and
  // Verify data flow from tuple to raised exception
  exists(DataFlow::Node exceptionNode |
    exceptionNode.asExpr() = raiseStatement.getException() and
    tupleSourceNode.flowsTo(exceptionNode)
  )
/* Note: Python 3 handles this as a type error (covered by IllegalRaise query),
   making this specific to Python 2 codebases */
select raiseStatement,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSourceNode, "tuple"