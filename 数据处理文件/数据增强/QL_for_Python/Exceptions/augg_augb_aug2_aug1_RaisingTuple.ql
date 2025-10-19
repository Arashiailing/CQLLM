/**
 * @name Raising a tuple
 * @description Detects code that raises a tuple in Python 2, which causes all elements except the first to be discarded
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

// Identify raise statements in Python 2 code where a tuple is being raised
from Raise raiseStatement, DataFlow::LocalSourceNode tupleExprNode
where
  // Restrict analysis to Python 2 environments, as this behavior differs in Python 3
  major_version() = 2 and
  // Confirm that the data flow source represents a tuple expression
  tupleExprNode.asExpr() instanceof Tuple and
  // Establish data flow path from the tuple expression to the exception part of the raise statement
  exists(DataFlow::Node exceptionTargetNode | 
    exceptionTargetNode.asExpr() = raiseStatement.getException() and
    tupleExprNode.flowsTo(exceptionTargetNode)
  )
/* Note: In Python 3, raising a tuple results in a TypeError, which is handled by the IllegalRaise query. */
select raiseStatement,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleExprNode, "tuple"