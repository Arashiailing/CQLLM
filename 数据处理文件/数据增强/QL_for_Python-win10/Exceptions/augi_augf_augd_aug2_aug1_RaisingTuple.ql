/**
 * @name Raising a tuple
 * @description Detects when a tuple is raised as an exception in Python 2,
 *              which causes all but the first element to be discarded
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple */

import python
import semmle.python.dataflow.new.DataFlow

// Identify raise statements where a tuple is used as the exception object
from Raise raiseStmt, DataFlow::LocalSourceNode tupleSource
where
  // Target Python 2 environment where tuple raising behavior occurs
  major_version() = 2 and
  // Verify the source node represents a tuple expression
  tupleSource.asExpr() instanceof Tuple and
  // Ensure data flows from the tuple to the raised exception
  exists(DataFlow::Node exceptionNode | 
    exceptionNode.asExpr() = raiseStmt.getException() and
    tupleSource.flowsTo(exceptionNode)
  )
/* Note: In Python 3, raising a tuple causes a TypeError, which is handled
   by the IllegalRaise query instead. */
select raiseStmt,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleSource, "tuple"