/**
 * @name Python 2 Tuple Raising Issue
 * @description In Python 2, raising a tuple as an exception only utilizes the first element while discarding all subsequent elements
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

// This analysis is specific to Python 2; Python 3 raises a type error for tuple exceptions
from Raise raiseStatement, DataFlow::LocalSourceNode tupleNode
where
  // Target only Python 2 environments
  major_version() = 2 and
  // Identify tuple expressions used as exception sources
  tupleNode.asExpr() instanceof Tuple and
  // Verify data flow path from tuple to raised exception
  exists(DataFlow::Node exceptionArgNode | 
    exceptionArgNode.asExpr() = raiseStatement.getException() and
    tupleNode.flowsTo(exceptionArgNode)
  )
select raiseStatement,
  "Raising a $@ will only use the first element (recursively) and discard all other elements.",
  tupleNode, "tuple"