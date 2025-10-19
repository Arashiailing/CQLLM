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
from Raise raiseStmt, DataFlow::LocalSourceNode tupleNode
where
  // Target Python 2 codebases only
  major_version() = 2 and
  // Verify source is a tuple expression
  tupleNode.asExpr() instanceof Tuple and
  // Establish data flow from tuple to raised exception
  exists(DataFlow::Node excNode |
    excNode.asExpr() = raiseStmt.getException() and
    tupleNode.flowsTo(excNode)
  )
/* Note: Python 3 handles this as a type error (covered by IllegalRaise query),
   making this specific to Python 2 codebases */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleNode, "tuple"