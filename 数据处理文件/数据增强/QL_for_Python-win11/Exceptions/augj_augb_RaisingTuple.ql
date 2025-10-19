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

// Identify raise statements in Python 2 code where a tuple is raised
from Raise raiseStatement, DataFlow::LocalSourceNode tupleSourceNode
where
  // Restrict analysis to Python 2 (Python 3 handles this as a type error)
  major_version() = 2 and
  // Verify the source node represents a tuple expression
  tupleSourceNode.asExpr() instanceof Tuple and
  // Confirm data flow path from tuple to the raised exception
  exists(DataFlow::Node exceptionTargetNode | 
    exceptionTargetNode.asExpr() = raiseStatement.getException() and
    tupleSourceNode.flowsTo(exceptionTargetNode)
  )
/* Raising a tuple is a type error in Python 3, so is handled by the IllegalRaise query. */
select raiseStatement,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSourceNode, "tuple"