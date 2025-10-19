/**
 * @name Raising a tuple
 * @description In Python 2, raising a tuple results in only the first element being raised
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

// Identify Python 2 raise statements where a tuple is raised
from Raise raiseStatement, DataFlow::LocalSourceNode tupleSourceNode
where
  // Target only Python 2 (Python 3 handles this as a type error)
  major_version() = 2 and
  // Verify the source node represents a tuple expression
  tupleSourceNode.asExpr() instanceof Tuple and
  // Confirm data flow path from tuple to the raised exception
  exists(DataFlow::Node exceptionFlowNode | 
    exceptionFlowNode.asExpr() = raiseStatement.getException() and
    tupleSourceNode.flowsTo(exceptionFlowNode)
  )
/* Note: Python 3 treats tuple raising as a type error, handled by IllegalRaise query */
select raiseStatement,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSourceNode, "tuple"