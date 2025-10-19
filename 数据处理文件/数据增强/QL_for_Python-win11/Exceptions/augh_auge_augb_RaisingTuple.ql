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
from Raise raiseStmt, DataFlow::LocalSourceNode tupleNode
where
  // Verify the source node represents a tuple expression
  tupleNode.asExpr() instanceof Tuple and
  // Target only Python 2 (Python 3 handles this as a type error)
  major_version() = 2 and
  // Confirm data flow path from tuple to the raised exception
  exists(DataFlow::Node flowTarget | 
    flowTarget.asExpr() = raiseStmt.getException() and
    tupleNode.flowsTo(flowTarget)
  )
/* Note: Python 3 treats tuple raising as a type error, handled by IllegalRaise query */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleNode, "tuple"