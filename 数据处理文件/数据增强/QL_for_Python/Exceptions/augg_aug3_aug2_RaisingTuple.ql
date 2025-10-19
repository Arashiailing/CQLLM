/**
 * @name Python 2 Tuple Raising Issue
 * @description When raising a tuple as an exception in Python 2, only the first element is used and the rest are discarded
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

// This issue is specific to Python 2; Python 3 treats tuple raises as type errors
from Raise raiseStmt, DataFlow::LocalSourceNode tupleExprSource
where
  // Restrict to Python 2 environments
  major_version() = 2 and
  // Identify tuple expressions being raised
  tupleExprSource.asExpr() instanceof Tuple and
  // Verify data flow path from tuple to raise exception
  exists(DataFlow::Node exceptionNode | 
    exceptionNode.asExpr() = raiseStmt.getException() and
    tupleExprSource.flowsTo(exceptionNode)
  )
select raiseStmt,
  "Raising a $@ will only use the first element (recursively) and discard all other elements.",
  tupleExprSource, "tuple"