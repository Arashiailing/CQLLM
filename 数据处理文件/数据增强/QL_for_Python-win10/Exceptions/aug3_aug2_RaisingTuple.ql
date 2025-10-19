/**
 * @name Raising a tuple in Python 2
 * @description In Python 2, raising a tuple only uses the first element and discards the rest
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

/* This issue is specific to Python 2; Python 3 treats tuple raises as type errors */
from Raise raiseNode, DataFlow::LocalSourceNode tupleSource
where
  // Restrict to Python 2 environments
  major_version() = 2 and
  // Identify tuple expressions being raised
  tupleSource.asExpr() instanceof Tuple and
  // Verify data flow path from tuple to raise exception
  exists(DataFlow::Node exceptionExprNode | 
    exceptionExprNode.asExpr() = raiseNode.getException() and
    tupleSource.flowsTo(exceptionExprNode)
  )
select raiseNode,
  "Raising a $@ will only use the first element (recursively) and discard all other elements.",
  tupleSource, "tuple"