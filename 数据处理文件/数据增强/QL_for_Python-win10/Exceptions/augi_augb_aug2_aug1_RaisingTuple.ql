/**
 * @name Raising a tuple
 * @description Detects code that raises a tuple as an exception in Python 2, 
 *              which causes all elements except the first to be discarded
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

// Identify raise statements that use tuples as exceptions in Python 2
from Raise exceptionRaise, DataFlow::LocalSourceNode tupleExprSource
where
  // This issue only occurs in Python 2; Python 3 raises a TypeError instead
  major_version() = 2 and
  // Confirm the source node represents a tuple expression
  tupleExprSource.asExpr() instanceof Tuple and
  // Establish data flow from the tuple to the exception being raised
  exists(DataFlow::Node exceptionFlowNode | 
    exceptionFlowNode.asExpr() = exceptionRaise.getException() and
    tupleExprSource.flowsTo(exceptionFlowNode)
  )
/* Note: Python 3 handles this differently by raising a TypeError, which is 
 * covered by the IllegalRaise query. This query specifically targets Python 2 
 * behavior where only the first element of the tuple is used as the exception. */
select exceptionRaise,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleExprSource, "tuple"