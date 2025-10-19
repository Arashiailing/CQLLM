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
from Raise raiseStmt, DataFlow::LocalSourceNode tupleSrcNode
where
  // Limit analysis to Python 2 environments where this behavior occurs
  major_version() = 2 and
  // Confirm the source node represents a tuple expression
  tupleSrcNode.asExpr() instanceof Tuple and
  // Establish data flow connection from tuple to the raised exception
  exists(DataFlow::Node exceptionDestNode | 
    exceptionDestNode.asExpr() = raiseStmt.getException() and
    tupleSrcNode.flowsTo(exceptionDestNode)
  )
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSrcNode, "tuple"