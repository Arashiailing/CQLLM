/**
 * @name Raising a tuple
 * @description In Python 2, raising a tuple causes only the first element (recursively) to be raised while discarding all other elements
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple */

import python
import semmle.python.dataflow.new.DataFlow

// Identify raise statements where the exception originates from a tuple
from Raise raiseStmt, DataFlow::LocalSourceNode tupleSource, DataFlow::Node exceptionFlowNode
where
  // Restrict analysis to Python 2 (Python 3 handles this as a type error)
  major_version() = 2 and
  // Ensure the source node represents a tuple expression
  tupleSource.asExpr() instanceof Tuple and
  // Verify data flow path from tuple to the raised exception
  exceptionFlowNode.asExpr() = raiseStmt.getException() and
  tupleSource.flowsTo(exceptionFlowNode)
/* Note: Raising a tuple is a type error in Python 3 and is handled by the IllegalRaise query. */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSource, "tuple"