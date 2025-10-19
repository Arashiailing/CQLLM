/**
 * @name Raising a tuple
 * @description In Python 2, raising a tuple causes the first element (recursively) to be raised while discarding other elements.
 *              Note: Python 3 treats this as a type error handled by the IllegalRaise query.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple */

import python
import semmle.python.dataflow.new.DataFlow

from Raise raiseNode, DataFlow::LocalSourceNode tupleSource
where
  // Restrict to Python 2 (Python 3 handles this as a type error)
  major_version() = 2
  and
  // Verify the source is a tuple expression
  tupleSource.asExpr() instanceof Tuple
  and
  // Confirm data flow from tuple to raised exception
  exists(DataFlow::Node exceptionNode |
    exceptionNode.asExpr() = raiseNode.getException()
    and
    tupleSource.flowsTo(exceptionNode)
  )
select raiseNode,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSource, "tuple"