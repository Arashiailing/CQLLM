/**
 * @name Raising a tuple in Python 2
 * @description In Python 2, raising a tuple results in only the first element being used, with subsequent elements ignored
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

/* Note: In Python 3, raising a tuple is a type error, which is detected by the IllegalRaise query. */
from Raise raiseNode, DataFlow::LocalSourceNode tupleOrigin
where
  // This issue only occurs in Python 2
  major_version() = 2 and
  // The source expression must be a tuple
  tupleOrigin.asExpr() instanceof Tuple and
  // Verify data flow from tuple to raised exception
  exists(DataFlow::Node exceptionTarget | 
    exceptionTarget.asExpr() = raiseNode.getException() and
    tupleOrigin.flowsTo(exceptionTarget)
  )
select raiseNode,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleOrigin, "tuple"