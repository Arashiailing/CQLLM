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

// Identify raise statements using tuples as exceptions in Python 2
from Raise raiseStatement, DataFlow::LocalSourceNode tupleExprSource
where
  // Target Python 2 environment where tuple raising behavior occurs
  major_version() = 2 and
  // Confirm source node represents a tuple expression
  tupleExprSource.asExpr() instanceof Tuple and
  // Verify data flow from tuple to raised exception
  exists(DataFlow::Node raisedExceptionNode | 
    raisedExceptionNode.asExpr() = raiseStatement.getException() and
    tupleExprSource.flowsTo(raisedExceptionNode)
  )
/* Note: In Python 3, raising a tuple causes a TypeError, which is handled
   by the IllegalRaise query instead. */
select raiseStatement,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  tupleExprSource, "tuple"