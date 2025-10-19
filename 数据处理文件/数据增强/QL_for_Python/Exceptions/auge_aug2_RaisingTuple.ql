/**
 * @name Tuple raised as exception in Python 2
 * @description In Python 2, raising a tuple causes only the first element to be used as the exception, ignoring the rest.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

/* Python 3 treats raising tuples as type errors, handled by IllegalRaise query */
from Raise raiseStatement, DataFlow::LocalSourceNode tupleSourceNode
where
  // Ensure Python 2 environment
  major_version() = 2 and
  // Verify source is a tuple expression
  tupleSourceNode.asExpr() instanceof Tuple and
  // Confirm data flow from tuple to raised exception
  exists(DataFlow::Node exceptionTargetNode | 
    exceptionTargetNode.asExpr() = raiseStatement.getException() and
    tupleSourceNode.flowsTo(exceptionTargetNode)
  )
select raiseStatement,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSourceNode, "tuple"