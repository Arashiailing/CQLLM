/**
 * @name Raising a tuple
 * @description In Python 2, raising a tuple causes all elements except the first to be discarded
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

// This query detects instances in Python 2 code where a tuple is used as the exception object in a raise statement.
// Such usage is problematic because Python 2 only raises the first element of the tuple, discarding the rest.
// This behavior differs from Python 3, where raising a tuple results in a TypeError.
from Raise raiseStmt, DataFlow::LocalSourceNode tupleNode
where
  // Limit the analysis to Python 2 environments
  major_version() = 2
  and
  // Confirm the source node is a tuple expression
  tupleNode.asExpr() instanceof Tuple
  and
  // Check if there's a data flow path from the tuple to the exception part of the raise statement
  exists(DataFlow::Node exceptionNode | 
    exceptionNode.asExpr() = raiseStmt.getException() and
    tupleNode.flowsTo(exceptionNode)
  )
/* Note: The IllegalRaise query handles the case where raising a tuple in Python 3 results in a TypeError. */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleNode, "tuple"